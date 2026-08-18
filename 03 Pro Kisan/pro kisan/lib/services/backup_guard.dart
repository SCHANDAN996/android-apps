import 'package:shared_preferences/shared_preferences.dart';

import 'notification_service.dart';

/// 🛡️ किसान का हिसाब सुरक्षित है या नहीं — इसका ध्यान यहीं रखा जाता है।
///
/// ## दो रास्ते, दोनों ज़रूरी
///
/// **1. Google खाता जुड़ा हो** → ऐप बंद करते समय backup अपने आप Drive पर
///    चढ़ जाता है। किसान को कुछ करना ही नहीं पड़ता।
///
/// **2. Google खाता न हो** → हफ़्ते में एक बार याद दिलाते हैं कि backup
///    फ़ाइल ख़ुद को WhatsApp पर भेज दे।
///
/// दूसरा रास्ता क्यों ज़रूरी है — गाँव के बहुत से फ़ोन में Google खाता होता ही
/// नहीं। ऐसे फ़ोन में Android का auto-backup भी नहीं चलता। यानी फ़ोन खोया,
/// टूटा या बदला तो **महीनों का हिसाब हमेशा के लिए गया** — और किसान को यह
/// तब पता चलता है जब बहुत देर हो चुकी होती है।
///
/// इसलिए ऐप ख़ुद ज़िम्मा लेता है: जब तक कोई एक रास्ता चालू न हो, टोकता रहता है।
class BackupGuard {
  BackupGuard._();
  static final BackupGuard instance = BackupGuard._();

  static const _kLastBackupAt = 'backup_last_at';       // ISO तारीख़
  static const _kGoogleEmail = 'backup_google_email';   // जुड़ा हो तो ईमेल

  /// इतने दिन तक backup न हो तो किसान को याद दिलाओ
  static const int yaadDilaoDin = 7;

  // ── किसका रास्ता चालू है ────────────────────────────────────────

  /// Google खाता जुड़ा है? जुड़ा हो तो उसका ईमेल, वरना null।
  Future<String?> googleEmail() async {
    final sp = await SharedPreferences.getInstance();
    final e = sp.getString(_kGoogleEmail);
    return (e == null || e.isEmpty) ? null : e;
  }

  Future<void> setGoogleEmail(String? email) async {
    final sp = await SharedPreferences.getInstance();
    if (email == null || email.isEmpty) {
      await sp.remove(_kGoogleEmail);
    } else {
      await sp.setString(_kGoogleEmail, email);
    }
    // खाता जुड़ते ही टोकना बंद, हटते ही दोबारा चालू
    await refreshReminder();
  }

  // ── आख़िरी backup कब हुआ ────────────────────────────────────────

  Future<DateTime?> lastBackupAt() async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString(_kLastBackupAt);
    return s == null ? null : DateTime.tryParse(s);
  }

  /// backup सफल होते ही बुलाइए — चाहे Drive पर गया हो या WhatsApp पर।
  Future<void> markBackedUp() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kLastBackupAt, DateTime.now().toIso8601String());
    await refreshReminder();
  }

  /// आख़िरी backup को कितने दिन हुए। कभी हुआ ही नहीं तो `null`।
  Future<int?> dinPurana() async {
    final at = await lastBackupAt();
    if (at == null) return null;
    return DateTime.now().difference(at).inDays;
  }

  /// किसान को अभी टोकना चाहिए या नहीं।
  ///
  /// Google जुड़ा हो तो कभी नहीं — उसका backup अपने आप होता रहता है।
  Future<bool> chetavniDikhani() async {
    if (await googleEmail() != null) return false;
    final din = await dinPurana();
    return din == null || din >= yaadDilaoDin;
  }

  // ── हफ़्ते वाली याद ────────────────────────────────────────────

  /// ऐप शुरू होते समय और हर बदलाव पर बुलाइए।
  ///
  /// Google जुड़ा हो → याद दिलाना बंद।
  /// न जुड़ा हो → हर रविवार सुबह 10 बजे याद।
  Future<void> refreshReminder({String? title, String? body}) async {
    try {
      if (await googleEmail() != null) {
        await NotificationService.instance.cancelWeeklyBackupReminder();
        return;
      }
      await NotificationService.instance.scheduleWeeklyBackupReminder(
        title: title ?? 'अपना हिसाब सुरक्षित कीजिए',
        body: body ??
            'फ़ोन खो जाए या टूट जाए तो सारा हिसाब चला जाएगा। '
                'ऐप खोलकर एक बार backup ख़ुद को WhatsApp पर भेज दीजिए।',
      );
    } catch (_) {
      // सूचना की अनुमति न हो या कोई और अड़चन — ऐप रुकना नहीं चाहिए
    }
  }
}
