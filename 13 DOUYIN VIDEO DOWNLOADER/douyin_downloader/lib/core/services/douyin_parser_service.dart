import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class DouyinMediaInfo {
  final String title;
  final String coverUrl;
  final String? videoUrl;
  final List<String> imageUrls;
  final bool isPhotoSlide;
  final String authorName;
  final String authorAvatar;

  DouyinMediaInfo({
    required this.title,
    required this.coverUrl,
    this.videoUrl,
    required this.imageUrls,
    required this.isPhotoSlide,
    required this.authorName,
    required this.authorAvatar,
  });
}

class DouyinParserService {
  // A mobile User-Agent is required — the Douyin share page returns real data
  // (the _ROUTER_DATA blob) only for mobile browsers.
  static const String _mobileUa =
      "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) "
      "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1";

  /// Pulls the first real URL out of pasted share text.
  ///
  /// Douyin's "copy link" text looks like:
  ///   7.65 ... 【...】 https://v.douyin.com/nHUa5MPyb54/ 复制此链接...
  /// so we must (a) find the URL and (b) STOP at spaces / Chinese characters,
  /// which the old `[^\s]+` regex failed to do when there was no space.
  static String? extractUrl(String text) {
    final douyin = RegExp(
        r'https?://[a-zA-Z0-9.\-]*douyin[a-zA-Z0-9.\-]*/[A-Za-z0-9/_\-?=&%.]*');
    final generic = RegExp(r'https?://[A-Za-z0-9._\-]+/[A-Za-z0-9/_\-?=&%.]*');
    final bare = RegExp(r'https?://[A-Za-z0-9._\-]+');

    final match = douyin.firstMatch(text) ??
        generic.firstMatch(text) ??
        bare.firstMatch(text);
    if (match == null) return null;

    var url = match.group(0)!;
    // Trim trailing punctuation that isn't part of the link.
    url = url.replaceAll(RegExp(r'[.,;:!?)\]\}]+$'), '');
    return url;
  }

  /// Follows a short link (https://v.douyin.com/xxxxx/) to its real target,
  /// which contains the numeric video id.
  static Future<String> resolveRedirect(String shortUrl) async {
    try {
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 12);
      final request = await client.getUrl(Uri.parse(shortUrl));
      request.followRedirects = false;
      request.headers.set(HttpHeaders.userAgentHeader, _mobileUa);
      final response = await request.close();
      await response.drain();
      client.close();
      if (response.isRedirect || (response.statusCode >= 300 && response.statusCode < 400)) {
        final loc = response.headers.value(HttpHeaders.locationHeader);
        if (loc != null && loc.isNotEmpty) return loc;
      }
      return shortUrl;
    } catch (_) {
      return shortUrl;
    }
  }

  /// Extracts the numeric aweme (video) id from any Douyin URL form.
  static String? _extractAwemeId(String url) {
    final patterns = [
      RegExp(r'/video/(\d+)'),
      RegExp(r'/share/video/(\d+)'),
      RegExp(r'modal_id=(\d+)'),
      RegExp(r'/note/(\d+)'),
    ];
    for (final p in patterns) {
      final m = p.firstMatch(url);
      if (m != null) return m.group(1);
    }
    return null;
  }

  /// Reads a balanced `{...}` JSON object out of [s] starting at [start],
  /// correctly ignoring braces that appear inside strings.
  static String _balancedJson(String s, int start) {
    int depth = 0;
    bool inStr = false;
    bool esc = false;
    for (int i = start; i < s.length; i++) {
      final c = s[i];
      if (inStr) {
        if (esc) {
          esc = false;
        } else if (c == '\\') {
          esc = true;
        } else if (c == '"') {
          inStr = false;
        }
      } else {
        if (c == '"') {
          inStr = true;
        } else if (c == '{') {
          depth++;
        } else if (c == '}') {
          depth--;
          if (depth == 0) return s.substring(start, i + 1);
        }
      }
    }
    return s.substring(start);
  }

  /// Master entry point. Given a pasted link (or share text) returns the media.
  static Future<DouyinMediaInfo> parseMedia(String inputLink) async {
    final cleanUrl = extractUrl(inputLink);
    if (cleanUrl == null) {
      throw Exception("No Douyin link found. Copy the link from Douyin and try again.");
    }

    // 1) Resolve short links to reach the page that carries the video id.
    String resolved = cleanUrl;
    if (cleanUrl.contains('v.douyin.com') || cleanUrl.contains('/share/')) {
      resolved = await resolveRedirect(cleanUrl);
    }

    final awemeId = _extractAwemeId(resolved) ?? _extractAwemeId(cleanUrl);
    if (awemeId == null) {
      throw Exception("Could not read the video id. Make sure it's a Douyin video link.");
    }

    // 2) Fetch the mobile share page — it embeds all data in _ROUTER_DATA.
    late final http.Response response;
    try {
      response = await http.get(
        Uri.parse("https://www.iesdouyin.com/share/video/$awemeId/"),
        headers: {
          "User-Agent": _mobileUa,
          "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
          "Accept-Language": "en-US,en;q=0.8,zh-CN;q=0.5",
        },
      ).timeout(const Duration(seconds: 15));
    } catch (_) {
      throw Exception("Douyin did not respond. Check your internet and try again.");
    }

    if (response.statusCode != 200) {
      throw Exception("Douyin returned an error (${response.statusCode}). Try again later.");
    }

    final media = _parseRouterData(response.body);
    if (media == null) {
      throw Exception(
          "Couldn't read this video (it may be private or region-locked). Try another link.");
    }
    return media;
  }

  /// Parses the `_ROUTER_DATA` JSON out of the share page HTML.
  static DouyinMediaInfo? _parseRouterData(String html) {
    final idx = html.indexOf('_ROUTER_DATA');
    if (idx == -1) return null;
    final braceStart = html.indexOf('{', idx);
    if (braceStart == -1) return null;

    Map<String, dynamic> root;
    try {
      root = jsonDecode(_balancedJson(html, braceStart)) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }

    // Find whichever loaderData page carries videoInfoRes.item_list.
    final loaderData = root['loaderData'];
    Map<String, dynamic>? item;
    if (loaderData is Map) {
      for (final page in loaderData.values) {
        if (page is! Map) continue;
        final vir = page['videoInfoRes'];
        if (vir is! Map) continue;
        final list = vir['item_list'];
        if (list is List && list.isNotEmpty && list.first is Map) {
          item = Map<String, dynamic>.from(list.first as Map);
          break;
        }
      }
    }
    if (item == null) return null;

    String firstUrl(dynamic node) {
      final ul = (node is Map) ? node['url_list'] : null;
      if (ul is List && ul.isNotEmpty) return ul.first.toString();
      return '';
    }

    final title = (item['desc']?.toString().trim().isNotEmpty ?? false)
        ? item['desc'].toString().trim()
        : 'Douyin Video';
    final author = item['author']?['nickname']?.toString() ?? 'Douyin User';
    final avatar = firstUrl(item['author']?['avatar_thumb']);
    final cover = firstUrl(item['video']?['cover']);

    // Photo slide?
    final List<String> images = [];
    final imgs = item['images'];
    if (imgs is List) {
      for (final im in imgs) {
        final u = firstUrl(im);
        if (u.isNotEmpty) images.add(u);
      }
    }

    if (images.isNotEmpty) {
      return DouyinMediaInfo(
        title: title,
        coverUrl: cover,
        videoUrl: null,
        imageUrls: images,
        isPhotoSlide: true,
        authorName: author,
        authorAvatar: avatar,
      );
    }

    // Video: prefer play_addr url (swap playwm->play for no watermark),
    // fall back to building a play URL from the uri.
    String? videoUrl;
    final playAddr = item['video']?['play_addr'];
    final playList = (playAddr is Map) ? playAddr['url_list'] : null;
    if (playList is List && playList.isNotEmpty) {
      videoUrl = playList.first.toString().replaceAll('playwm', 'play');
    }
    final uri = (playAddr is Map) ? playAddr['uri']?.toString() : null;
    if ((videoUrl == null || videoUrl.isEmpty) && uri != null && uri.isNotEmpty) {
      videoUrl = "https://aweme.snssdk.com/aweme/v1/play/?video_id=$uri&ratio=1080p&line=0";
    }
    if (videoUrl != null && videoUrl.startsWith('//')) {
      videoUrl = 'https:$videoUrl';
    }

    if (videoUrl == null || videoUrl.isEmpty) return null;

    return DouyinMediaInfo(
      title: title,
      coverUrl: cover,
      videoUrl: videoUrl,
      imageUrls: const [],
      isPhotoSlide: false,
      authorName: author,
      authorAvatar: avatar,
    );
  }
}
