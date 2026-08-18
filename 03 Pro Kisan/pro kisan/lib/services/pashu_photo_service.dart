import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// पशु की फोटो कहाँ रखनी है, कैसे pick करनी है — इसका काम यहीं।
///
/// फ़ाइल app के private documents/pashu_photos/ में जाती है (उपयोगकर्ता की
/// gallery में नहीं — निजी रहती है, uninstall पर हट जाती है)।
///
/// ## ⚠️ DB में सिर्फ़ फ़ाइल का नाम रखते हैं, पूरा रास्ता नहीं
///
/// पहले पूरा रास्ता रखते थे —
///
///     /data/user/0/com.prokisan.app/app_flutter/pashu_photos/pashu_1.jpg
///
/// पर वह रास्ता **उसी फ़ोन का** होता है। Android का auto-backup जब नए फ़ोन पर
/// data लौटाता है, तो पशु तो आ जाते थे पर उनकी फ़ोटो की जगह टूटा हुआ निशान
/// दिखता, क्योंकि वह रास्ता वहाँ होता ही नहीं।
///
/// अब सिर्फ़ `pashu_1.jpg` रखते हैं और दिखाते समय फ़ोल्डर [fullPath] से जोड़
/// लेते हैं। फ़ोन बदले तो भी फ़ोटो मिल जाती है।
///
/// पुराने पूरे रास्ते DB migration (version 8) में छोटे कर दिए गए हैं, और
/// [fullPath] दोनों तरह के मान समझता है — इसलिए कुछ टूटता नहीं।
class PashuPhotoService {
  static final _picker = ImagePicker();
  static const _subdir = 'pashu_photos';

  /// Camera या gallery से एक फोटो लो, अंदर save करो, **फ़ाइल का नाम** लौटाओ।
  /// User ने cancel किया तो null।
  static Future<String?> pickAndSave({required ImageSource source}) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024, // बड़ी फ़ोटो storage खाती हैं — किसान के फ़ोन पर 1024 काफ़ी
      imageQuality: 82,
    );
    if (picked == null) return null;

    final dir = await _pashuDir();
    final ext = p.extension(picked.path).toLowerCase();
    final safeExt = (ext == '.jpg' || ext == '.jpeg' || ext == '.png') ? ext : '.jpg';
    final ts = DateTime.now().millisecondsSinceEpoch;
    final name = 'pashu_$ts$safeExt';

    await File(picked.path).copy(p.join(dir.path, name));
    return name; // ← सिर्फ़ नाम, पूरा रास्ता नहीं
  }

  /// DB में रखे मान से असली फ़ाइल का पूरा रास्ता बनाओ।
  ///
  /// दोनों तरह के मान चलते हैं —
  ///  • नया  : `pashu_1.jpg`      → फ़ोल्डर जोड़कर लौटाता है
  ///  • पुराना: `/data/.../x.jpg` → उसमें से सिर्फ़ नाम लेकर जोड़ता है
  ///
  /// पुराने को भी नाम पर लाना ज़रूरी है: वह रास्ता इसी फ़ोन का हो सकता है, पर
  /// backup से लौटे data में दूसरे फ़ोन का होगा और खुलेगा नहीं।
  static Future<String?> fullPath(String? stored) async {
    if (stored == null || stored.trim().isEmpty) return null;
    final dir = await _pashuDir();
    return p.join(dir.path, p.basename(stored));
  }

  /// फ़ोल्डर का रास्ता, एक बार निकालकर रख लिया।
  ///
  /// UI के `build()` में `await` नहीं कर सकते, इसलिए [fullPathSync] को यह
  /// तैयार चाहिए। ऐप शुरू होते ही [warmUp] इसे भर देता है।
  static String? _dirCache;

  /// ऐप शुरू होते समय एक बार बुलाइए (main.dart में) — ताकि फ़ोटो दिखाते समय
  /// रास्ता तुरंत मिल जाए।
  static Future<void> warmUp() async {
    try {
      _dirCache = (await _pashuDir()).path;
    } catch (_) {}
  }

  /// [fullPath] का वही काम, पर बिना `await` — UI के `build()` के लिए।
  ///
  /// [warmUp] अभी न चला हो तो पुराने पूरे रास्ते को जस का तस लौटा देता है
  /// (उसी फ़ोन पर वह चल जाएगा), और नए नाम पर `null` — यानी icon दिखेगा,
  /// टूटी तस्वीर नहीं।
  static String? fullPathSync(String? stored) {
    if (stored == null || stored.trim().isEmpty) return null;
    final d = _dirCache;
    if (d == null) {
      // warmUp अभी नहीं चला — पुराना पूरा रास्ता जस का तस चल जाएगा,
      // नए नाम पर null (icon दिखेगा, टूटी तस्वीर नहीं)
      return stored.contains('/') ? stored : null;
    }
    return p.join(d, p.basename(stored));
  }

  /// पुरानी फोटो delete करो (best effort — नहीं है तो चुपचाप छोड़ दो)।
  /// नाम और पूरा रास्ता, दोनों चलते हैं।
  static Future<void> deleteIfExists(String? stored) async {
    final path = await fullPath(stored);
    if (path == null) return;
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  static Future<Directory> _pashuDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, _subdir));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }
}
