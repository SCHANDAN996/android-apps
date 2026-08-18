import 'package:flutter/material.dart';

import '../../db/dairy_database.dart';
import '../../l10n/app_localizations.dart';
import '../../services/backup_guard.dart';
import '../../services/google_drive_backup.dart';

/// 🛡️ नया फ़ोन: "आपका पुराना हिसाब मिला है — वापस लाएँ?"
///
/// ## यही पूरे Drive वाले काम का असली मक़सद है
///
/// backup चढ़ाना आधा काम है। किसान का फ़ोन टूटा, उसने नया लिया, ऐप लगाया —
/// अब उसका महीनों का हिसाब **वापस आना चाहिए**। वरना backup लेने का कोई
/// मतलब ही नहीं था।
///
/// ## कब पूछते हैं
///
/// तीनों बातें एक साथ सच हों, तभी:
///
///  1. Google खाता जुड़ा हो (चुपचाप जुड़ जाता है, किसान को कुछ करना नहीं पड़ता)
///  2. **फ़ोन का database ख़ाली हो** — कोई ग्राहक, एंट्री या पशु नहीं
///  3. Drive पर backup सचमुच रखा हो
///
/// दूसरी शर्त सबसे ज़रूरी है। अगर किसान के फ़ोन में पहले से हिसाब है और हम
/// Drive वाला डाल दें, तो उसका **आज का काम मिट जाएगा**। इसलिए ख़ाली फ़ोन पर
/// ही पूछते हैं — यानी नया install या नया फ़ोन।
class DriveRestorePrompt {
  DriveRestorePrompt._();

  /// एक ही बार में दो बार न पूछे
  static bool _poochhLiya = false;

  /// फ़ोन का hisaab ख़ाली है या नहीं
  static Future<bool> _phoneKhaaliHai() async {
    try {
      final db = await DairyDatabase.instance.database;
      for (final t in ['customers', 'entries', 'pashu']) {
        final r = await db.rawQuery('SELECT COUNT(*) c FROM $t');
        if (((r.first['c'] as int?) ?? 0) > 0) return false;
      }
      return true;
    } catch (_) {
      // जाँच ही न हो पाए तो पूछो मत — मिटाने का ख़तरा नहीं लेना
      return false;
    }
  }

  /// ऐप खुलने के बाद बुलाइए। ज़रूरत हो तभी कुछ दिखेगा।
  static Future<void> poochhoAgarZaroorat(BuildContext context) async {
    if (_poochhLiya) return;
    _poochhLiya = true;

    try {
      if (await BackupGuard.instance.googleEmail() == null) return;
      if (!await _phoneKhaaliHai()) return;
      if (!await GoogleDriveBackup.instance.kuchRakhaHai()) return;
      if (!context.mounted) return;

      final isHi = AppLocalizations.isHindiLike(context);
      final laayein = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (c) => AlertDialog(
          icon: const Icon(Icons.cloud_download_rounded,
              color: Colors.blue, size: 40),
          title: Text(isHi
              ? 'आपका पुराना हिसाब मिल गया'
              : 'Your old records were found'),
          content: Text(
            isHi
                ? 'आपके Google खाते में पहले का हिसाब रखा है — ग्राहक, दूध की '
                    'एंट्री, पशु, सब कुछ।\n\nवापस ले आएँ?'
                : 'Your Google account has your earlier records — customers, '
                    'milk entries, animals, everything.\n\nBring them back?',
            style: const TextStyle(height: 1.45),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(isHi ? 'अभी नहीं' : 'Not now'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text(isHi ? 'हाँ, ले आइए' : 'Yes, restore'),
            ),
          ],
        ),
      );

      if (laayein != true || !context.mounted) return;

      // ला रहे हैं — किसान को दिखता रहे कि कुछ हो रहा है
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(
          content: Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(children: [
              CircularProgressIndicator(),
              SizedBox(width: 18),
              Expanded(child: Text('ला रहे हैं…')),
            ]),
          ),
        ),
      );

      final kitna = await GoogleDriveBackup.instance.restoreFromDrive();

      if (!context.mounted) return;
      Navigator.pop(context); // ला रहे हैं वाला बंद करो

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: kitna != null ? Colors.green.shade700 : Colors.red.shade700,
        content: Text(kitna != null
            ? (isHi
                ? '✅ आपका हिसाब वापस आ गया ($kitna पंक्तियाँ)'
                : '✅ Restored ($kitna rows)')
            : (isHi
                ? 'वापस नहीं ला पाए। इंटरनेट देखकर सेटिंग से दोबारा कोशिश कीजिए।'
                : 'Could not restore. Check internet and try from Settings.')),
      ));
    } catch (_) {
      // कुछ भी गड़बड़ हो तो चुपचाप — ऐप पहले जैसा चलता रहे
    }
  }
}
