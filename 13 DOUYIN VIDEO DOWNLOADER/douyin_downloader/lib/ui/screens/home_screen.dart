import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/services/douyin_parser_service.dart';
import '../../core/services/download_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final TextEditingController _urlController = TextEditingController();
  bool _isParsing = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _statusMessage = "";
  DouyinMediaInfo? _parsedMedia;
  List<DownloadItem> _history = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadHistory();
    _checkClipboardForLink();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When the user comes back after copying a link in Douyin, auto-detect it.
    if (state == AppLifecycleState.resumed) {
      _checkClipboardForLink();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _urlController.dispose();
    super.dispose();
  }

  // --- Core Business Logic ---
  Future<void> _loadHistory() async {
    final history = await DownloadService.getHistory();
    setState(() {
      _history = history;
    });
  }

  Future<void> _checkClipboardForLink() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    final text = clipboardData?.text;
    if (text == null || text.isEmpty) return;

    // Pull out ONLY the clean URL, dropping the Chinese share text around it.
    final link = DouyinParserService.extractUrl(text);
    if (link == null || !link.contains('douyin')) return;
    if (_urlController.text.trim() == link) return; // already there

    if (!mounted) return;
    setState(() {
      _urlController.text = link; // auto-fill clean URL, extra text removed
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF1E222B),
        content: Text(
          "Douyin link detected & pasted ✓",
          style: GoogleFonts.outfit(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _parseLink() async {
    final raw = _urlController.text.trim();
    // Strip any extra share text; keep only the clean URL.
    final clean = DouyinParserService.extractUrl(raw) ?? raw;
    if (clean.isEmpty) {
      _showSnackbar("Please paste a Douyin link first.");
      return;
    }
    if (_urlController.text != clean) {
      _urlController.text = clean; // show the cleaned URL in the field
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isParsing = true;
      _parsedMedia = null;
      _statusMessage = "Parsing link from Douyin...";
    });

    try {
      final media = await DouyinParserService.parseMedia(clean);
      if (!mounted) return;
      setState(() {
        _parsedMedia = media;
        _isParsing = false;
        _statusMessage = "Video parsed successfully!";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isParsing = false;
        _statusMessage = "";
      });
      _showSnackbar(e.toString().replaceAll("Exception: ", ""));
    }
  }

  Future<void> _downloadMediaFile() async {
    if (_parsedMedia == null) return;

    // Android 9 and below need storage permission to write to the gallery.
    // On Android 10+ this is effectively a no-op (the permission is not
    // declared there and MediaStore saving works without it).
    if (Platform.isAndroid) {
      await Permission.storage.request();
      if (!mounted) return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _statusMessage = "Downloading media...";
    });

    final media = _parsedMedia!;

    if (media.isPhotoSlide) {
      // Photo slide album download logic
      int downloadedCount = 0;
      bool allSuccessful = true;

      for (int i = 0; i < media.imageUrls.length; i++) {
        if (!mounted) return;
        setState(() {
          _statusMessage = "Downloading slide ${i + 1}/${media.imageUrls.length}...";
        });

        final url = media.imageUrls[i];
        final success = await DownloadService.downloadMedia(
          url: url,
          title: "${media.title} (Slide ${i + 1})",
          coverUrl: media.coverUrl,
          isVideo: false,
          onProgress: (p) {},
        );

        if (success) {
          downloadedCount++;
        } else {
          allSuccessful = false;
        }

        if (!mounted) return;
        setState(() {
          _downloadProgress = (i + 1) / media.imageUrls.length;
        });
      }

      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _statusMessage = allSuccessful
            ? "Downloaded all $downloadedCount slides to gallery!"
            : "Downloaded $downloadedCount slides. Some failed.";
      });

      _loadHistory();
    } else {
      // Single video download logic
      if (media.videoUrl == null) {
        _showSnackbar("No download link available for this video.");
        setState(() {
          _isDownloading = false;
          _statusMessage = "";
        });
        return;
      }

      final success = await DownloadService.downloadMedia(
        url: media.videoUrl!,
        title: media.title,
        coverUrl: media.coverUrl,
        isVideo: true,
        onProgress: (progress) {
          if (!mounted) return;
          setState(() {
            _downloadProgress = progress;
            if (progress >= 0.0) {
              _statusMessage = "Downloading: ${(progress * 100).toStringAsFixed(0)}%";
            } else {
              _statusMessage = "Downloading...";
            }
          });
        },
      );

      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _statusMessage = success
            ? "Saved video successfully to Movies/DouyinDownloader!"
            : "Download failed. Please try again.";
      });

      if (success) {
        _loadHistory();
      }
    }
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFC92A42),
        content: Text(
          msg,
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    final mb = bytes / (1024 * 1024);
    if (mb >= 1.0) {
      return "${mb.toStringAsFixed(2)} MB";
    }
    final kb = bytes / 1024;
    return "${kb.toStringAsFixed(1)} KB";
  }

  // --- UI Building ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: Stack(
        children: [
          // Subtle Glowing Neon Mesh Background
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x22FF004F),
                    blurRadius: 120,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 250,
            right: -120,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x1900F0FF),
                    blurRadius: 130,
                    spreadRadius: 35,
                  ),
                ],
              ),
            ),
          ),

          // Scrollable App Body
          SafeArea(
            child: Column(
              children: [
                // Premium Glassmorphism Header
                _buildHeader(),
                
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        
                        // Input Card
                        _buildInputCard(),

                        const SizedBox(height: 20),

                        // Loading Indicator
                        if (_isParsing || _isDownloading) _buildLoader(),

                        // Status message
                        if (_statusMessage.isNotEmpty && !_isParsing && !_isDownloading) 
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Text(
                              _statusMessage,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                color: _statusMessage.contains("failed") || _statusMessage.contains("Please")
                                    ? Colors.redAccent
                                    : const Color(0xFF00FFB2),
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),

                        // Media Preview Card
                        if (_parsedMedia != null) _buildPreviewCard(),

                        const SizedBox(height: 20),

                        // Download History
                        _buildHistorySection(),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0x0AFFFFFF),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF004F).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_downward_rounded,
                  color: Color(0xFFFF004F),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Douyin Downloader",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white70),
            onPressed: _showAboutDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151821),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                "Paste Douyin Link Here",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  if (data != null && data.text != null) {
                    setState(() {
                      _urlController.text = data.text!;
                    });
                  }
                },
                icon: const Icon(Icons.paste_rounded, size: 16, color: Color(0xFF00F0FF)),
                label: Text(
                  "Paste",
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF00F0FF),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              if (_urlController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Colors.white30, size: 18),
                  onPressed: () {
                    setState(() {
                      _urlController.clear();
                      _parsedMedia = null;
                      _statusMessage = "";
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _urlController,
            onChanged: (val) {
              setState(() {});
            },
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
            maxLines: 2,
            minLines: 1,
            decoration: InputDecoration(
              hintText: "eg. https://v.douyin.com/abc123yz/",
              hintStyle: GoogleFonts.outfit(color: Colors.white24, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFF0F1115),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isParsing || _isDownloading ? null : _parseLink,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF004F),
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: const Color(0xFFFF004F).withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.flash_on_rounded, size: 18),
                const SizedBox(width: 8),
                Text(
                  "Extract Video / Photos",
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151821),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00F0FF)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _statusMessage,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
          if (_isDownloading && _downloadProgress >= 0.0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _downloadProgress,
                backgroundColor: const Color(0xFF0F1115),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF004F)),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    final media = _parsedMedia!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151821),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: media.authorAvatar.isNotEmpty
                    ? NetworkImage(media.authorAvatar)
                    : null,
                backgroundColor: const Color(0xFF0F1115),
                radius: 18,
                child: media.authorAvatar.isEmpty
                    ? const Icon(Icons.person, color: Colors.white30, size: 18)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  media.authorName,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x1100F0FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0x3300F0FF)),
                ),
                child: Text(
                  media.isPhotoSlide ? "PHOTOS" : "VIDEO",
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF00F0FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            media.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, height: 1.3),
          ),
          const SizedBox(height: 12),
          
          // Image / Video Cover Thumbnail
          if (media.coverUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  media.coverUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF0F1115),
                    child: const Icon(Icons.broken_image, color: Colors.white24, size: 30),
                  ),
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isDownloading ? null : _downloadMediaFile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FFB2),
              foregroundColor: const Color(0xFF0F1115),
              elevation: 4,
              shadowColor: const Color(0xFF00FFB2).withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  media.isPhotoSlide ? Icons.photo_library_rounded : Icons.save_alt_rounded,
                  size: 18,
                  color: const Color(0xFF0F1115),
                ),
                const SizedBox(width: 8),
                Text(
                  media.isPhotoSlide
                      ? "Download All Slides (${media.imageUrls.length})"
                      : "Download Watermark-Free Video",
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Download History",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (_history.isNotEmpty)
              TextButton(
                onPressed: () async {
                  await DownloadService.clearHistory();
                  _loadHistory();
                },
                child: Text(
                  "Clear All",
                  style: GoogleFonts.outfit(color: Colors.white30, fontSize: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_history.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            decoration: BoxDecoration(
              color: const Color(0xFF151821).withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.history_toggle_off_rounded, color: Colors.white24, size: 36),
                const SizedBox(height: 8),
                Text(
                  "No downloads yet.",
                  style: GoogleFonts.outfit(color: Colors.white24, fontSize: 13),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _history.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = _history[index];
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF151821),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.04)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 50,
                        height: 50,
                        color: const Color(0xFF0F1115),
                        child: item.coverUrl.isNotEmpty
                            ? Image.network(item.coverUrl, fit: BoxFit.cover,
                                errorBuilder: (c, e, s) =>
                                    const Icon(Icons.videocam_rounded, color: Colors.white30))
                            : Icon(
                                item.type == 'video'
                                    ? Icons.videocam_rounded
                                    : Icons.image_rounded,
                                color: Colors.white30),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                item.date,
                                style: GoogleFonts.outfit(
                                    color: Colors.white38, fontSize: 10),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: const BoxDecoration(
                                    color: Colors.white24, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatFileSize(item.fileSize),
                                style: GoogleFonts.outfit(
                                    color: Colors.white38, fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_rounded, color: Color(0xFF00F0FF), size: 18),
                      onPressed: () {
                        Share.share("Check out this downloaded video: ${item.title}");
                      },
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF151821),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            "About Douyin Downloader",
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Download watermark-free video streams and image collections directly from Douyin in High Quality.\n\nAll downloaded media files are securely stored on your phone's Gallery under 'Movies/DouyinDownloader' and 'Pictures/DouyinDownloader'.\n\n100% Offline-first, secure and light-weight.",
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "CLOSE",
                style: GoogleFonts.outfit(color: const Color(0xFFFF004F), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
