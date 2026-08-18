import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import '../db/dao/news_dao.dart';

class NewsService {
  final NewsDao _newsDao = NewsDao();

  /// ⚠️ कोई भी feed जोड़ने से पहले उसे असल में curl करके जाँचो — HTTP 200 आना
  /// काफ़ी नहीं, यह भी देखो कि उसकी सबसे नई खबर कितनी पुरानी है।
  ///
  /// जो हटाए गए और क्यों (23 जुलाई 2026 को जाँचा):
  ///  • livehindustan .../budget/farmers/... → यह *बजट* का feed था। भारत का बजट
  ///    1 फ़रवरी को आता है, इसलिए साल में एक बार भरता है। सबसे नई खबर 1 Feb 2026
  ///    की थी — ऐप में 6 महीने पुरानी खबरें इसी वजह से दिख रही थीं।
  ///  • krishisewa.com → सर्वर ही जवाब नहीं देता (connection fail)।
  static const List<Map<String, String>> _sources = [
    {
      // India Today समूह का कृषि चैनल — रोज़ कई बार अपडेट होता है
      'name': 'Kisan Tak',
      'url': 'https://www.kisantak.in/rss/1.xml',
    },
    {
      // 50 items, रोज़ अपडेट
      'name': 'Krishi Jagran',
      'url': 'https://hindi.krishijagran.com/feeds/rss/',
    },
  ];

  /// इससे पुरानी खबर नहीं दिखाएँगे। बासी खबर दिखाने से अच्छा है कम दिखाना।
  static const int _maxAgeDays = 30;

  /// Fetch all news from multiple RSS feeds, merge, deduplicate, cache, & fallback to SQLite
  Future<List<Map<String, String>>> fetchAllNews() async {
    final List<Map<String, String>> allParsedNews = [];

    // Parallel fetch from all RSS sources
    await Future.wait(_sources.map((src) async {
      try {
        final response = await http
            .get(Uri.parse(src['url']!))
            .timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          final items = _parseRssFeed(response.bodyBytes, src['name']!);
          allParsedNews.addAll(items);
        }
      } catch (_) {
        // Individual feed timeout/fail safe
      }
    }));

    if (allParsedNews.isNotEmpty) {
      // Deduplicate by title/link
      final Map<String, Map<String, String>> uniqueMap = {};
      for (var item in allParsedNews) {
        final key = item['title']?.trim().toLowerCase() ?? item['link'] ?? '';
        if (key.isNotEmpty && !uniqueMap.containsKey(key)) {
          uniqueMap[key] = item;
        }
      }

      final List<Map<String, String>> uniqueList = uniqueMap.values.toList();

      // ── नई से पुरानी के क्रम में लगाओ ──
      // पहले कोई sorting थी ही नहीं — feeds जिस क्रम में लौटते थे उसी क्रम में
      // दिखते थे, इसलिए बासी खबर ऊपर आ जाती थी।
      uniqueList.sort((a, b) {
        final ta = int.tryParse(a['ts'] ?? '') ?? 0;
        final tb = int.tryParse(b['ts'] ?? '') ?? 0;
        return tb.compareTo(ta); // बड़ा timestamp = नई खबर = ऊपर
      });

      // ── बहुत पुरानी खबरें हटाओ ──
      final cutoff = DateTime.now()
          .subtract(const Duration(days: _maxAgeDays))
          .millisecondsSinceEpoch;
      final fresh = uniqueList.where((n) {
        final ts = int.tryParse(n['ts'] ?? '') ?? 0;
        return ts == 0 || ts >= cutoff; // तारीख़ न मिली हो तो रहने दो
      }).toList();

      final result = fresh.isNotEmpty ? fresh : uniqueList;

      // Save fresh news to SQLite cache
      await _newsDao.cacheNews(result);
      return result;
    }

    // Fallback: If offline or all HTTP requests fail, load from SQLite cache
    return await _newsDao.getCachedNews();
  }

  /// Parse XML RSS body bytes into news map items
  List<Map<String, String>> _parseRssFeed(List<int> bodyBytes, String sourceName) {
    final List<Map<String, String>> list = [];
    try {
      final decodedBody = utf8.decode(bodyBytes, allowMalformed: true);
      final document = xml.XmlDocument.parse(decodedBody);
      final items = document.findAllElements('item');

      for (var item in items) {
        final title = item.findElements('title').firstOrNull?.innerText ?? '';
        final description = item.findElements('description').firstOrNull?.innerText ?? '';
        final pubDate = item.findElements('pubDate').firstOrNull?.innerText ?? '';
        final link = item.findElements('link').firstOrNull?.innerText ?? '';

        // Extract image url from media:content or enclosure or img in description
        String imageUrl = '';
        final mediaContent = item.findElements('media:content').firstOrNull;
        if (mediaContent != null) {
          imageUrl = mediaContent.getAttribute('url') ?? '';
        }

        if (imageUrl.isEmpty) {
          final enclosure = item.findElements('enclosure').firstOrNull;
          if (enclosure != null && (enclosure.getAttribute('type')?.contains('image') ?? false)) {
            imageUrl = enclosure.getAttribute('url') ?? '';
          }
        }

        if (imageUrl.isEmpty) {
          final imgMatch = RegExp(r'<img[^>]+src="([^">]+)"', caseSensitive: false).firstMatch(description);
          if (imgMatch != null) {
            imageUrl = imgMatch.group(1) ?? '';
          }
        }

        // Clean HTML tags from description
        final cleanDesc = description.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), '').trim();

        if (title.isNotEmpty) {
          final category = _autoTagCategory(title, cleanDesc);
          list.add({
            'title': title,
            'desc': cleanDesc.length > 150 ? '${cleanDesc.substring(0, 150)}...' : cleanDesc,
            'fullDesc': cleanDesc,
            'date': _formatFeedDate(pubDate),
            // छाँटने के लिए — DAO इसे सहेजता नहीं, सिर्फ़ यहीं काम आता है
            'ts': (_parseRssDate(pubDate)?.millisecondsSinceEpoch ?? 0).toString(),
            'link': link,
            'image': imageUrl,
            'source': sourceName,
            'category': category,
          });
        }
      }
    } catch (_) {}
    return list;
  }

  /// Auto categorize news based on title/description keywords
  String _autoTagCategory(String title, String desc) {
    final text = '$title $desc'.toLowerCase();
    if (text.contains('योजना') || text.contains('सब्सिडी') || text.contains('सरकार') || text.contains('scheme') || text.contains('pm-kisan')) {
      return 'schemes';
    }
    if (text.contains('मंडी') || text.contains('भाव') || text.contains('दर') || text.contains('msp') || text.contains('price') || text.contains('बाजार')) {
      return 'mandi_price';
    }
    if (text.contains('मौसम') || text.contains('बारिश') || text.contains('ओला') || text.contains('मौसम') || text.contains('weather') || text.contains('alert')) {
      return 'weather_alert';
    }
    if (text.contains('पशु') || text.contains('गाय') || text.contains('भैंस') || text.contains('दूध') || text.contains('डेयरी') || text.contains('dairy')) {
      return 'livestock_dairy';
    }
    if (text.contains('तकनीक') || text.contains('यंत्र') || text.contains('ड्रोन') || text.contains('ट्रैक्टर') || text.contains('ड्रिप') || text.contains('जैविक')) {
      return 'tech_innovation';
    }
    return 'all';
  }

  /// RSS की pubDate को DateTime में बदलो — छाँटने और पुरानी खबर हटाने के लिए।
  /// RSS का रूप: "Wed, 22 Jul 2026 17:41:47 +0530"
  static DateTime? _parseRssDate(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;

    // पहले ISO आज़माओ (कुछ feed ISO देते हैं)
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;

    const months = {
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
      'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
    };

    // "Wed, 22 Jul 2026 17:41:47 +0530" → दिन, महीना, साल, समय
    final m = RegExp(
      r'(\d{1,2})\s+([A-Za-z]{3})[a-z]*\s+(\d{4})(?:\s+(\d{2}):(\d{2})(?::(\d{2}))?)?',
    ).firstMatch(s);
    if (m == null) return null;

    final month = months[m.group(2)!.toLowerCase()];
    if (month == null) return null;

    return DateTime(
      int.parse(m.group(3)!),          // साल
      month,
      int.parse(m.group(1)!),          // दिन
      int.tryParse(m.group(4) ?? '') ?? 0,
      int.tryParse(m.group(5) ?? '') ?? 0,
      int.tryParse(m.group(6) ?? '') ?? 0,
    );
  }

  String _formatFeedDate(String rawDate) {
    try {
      final parts = rawDate.split(' ');
      if (parts.length >= 4) {
        return "${parts[1]} ${parts[2]} ${parts[3]}";
      }
      return rawDate;
    } catch (_) {
      return rawDate;
    }
  }
}
