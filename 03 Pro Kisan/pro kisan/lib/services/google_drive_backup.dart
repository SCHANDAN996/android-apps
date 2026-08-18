import 'dart:convert';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

import 'backup_guard.dart';
import 'backup_service.dart';

/// 🛡️ किसान का हिसाब उसके अपने Google खाते में सुरक्षित रखता है।
///
/// ## कहाँ जाता है
///
/// Drive के **appDataFolder** में — यह एक छिपा हुआ फ़ोल्डर है:
///
///  • किसान की Drive में कहीं **दिखता नहीं** (उसकी फ़ाइलें गंदी नहीं होतीं)
///  • सिर्फ़ **यही ऐप** उसे पढ़ सकता है, कोई दूसरा ऐप नहीं
///  • ऐप uninstall करने पर भी **बचा रहता है** — यही असली फ़ायदा है
///
/// ⚠️ इसी वजह से scope `drive.appdata` रखा है, पूरी Drive का नहीं। पूरी
/// Drive का scope माँगने पर Google हर साल महँगा security assessment
/// करवाता है और Play Store की मंज़ूरी में महीनों लगते हैं।
///
/// ## कब चढ़ता है
///
/// **ऐप बंद करते समय** (देखें `main.dart` का lifecycle observer)। हर एंट्री
/// पर नहीं — गाँव के 2G network पर 10 एंट्री = 10 upload बहुत भारी पड़ता,
/// और बैटरी भी खाता।
///
/// साथ में एक सस्ता जाल: ऐप खुलते समय अगर पिछला upload 24 घंटे से पुराना
/// है तो एक बार तभी चढ़ा देते हैं। इससे ऐप crash होने वाली सूरत भी सँभल
/// जाती है, और network का ख़र्च नहीं बढ़ता।
///
/// ## ⚠️ चलने से पहले Google Cloud Console का setup ज़रूरी है
///
/// बिना उसके [signIn] चुपचाप नाकाम होगा और ऐप पहले जैसा (सिर्फ़ फ़ोन में
/// backup) चलता रहेगा — कुछ टूटेगा नहीं। पूरी विधि `GOOGLE_SETUP.md` में है।
class GoogleDriveBackup {
  GoogleDriveBackup._();
  static final GoogleDriveBackup instance = GoogleDriveBackup._();

  /// backup की फ़ाइल का नाम — हर बार यही, ताकि नई फ़ाइलें जमा न होती रहें
  static const String _fileName = 'pro_kisan_backup.json';

  final GoogleSignIn _signIn = GoogleSignIn(
    scopes: <String>[drive.DriveApi.driveAppdataScope],
  );

  GoogleSignInAccount? _account;

  // ── खाता जोड़ना / हटाना ─────────────────────────────────────────

  /// किसान से Google खाता चुनवाओ। जुड़ गया तो उसका ईमेल, वरना null।
  Future<String?> signIn() async {
    try {
      final acc = await _signIn.signIn();
      if (acc == null) return null; // किसान ने रद्द कर दिया
      _account = acc;
      await BackupGuard.instance.setGoogleEmail(acc.email);
      return acc.email;
    } catch (_) {
      // Console का setup न हुआ हो, या net न हो — ऐप पहले जैसा चलता रहे
      return null;
    }
  }

  /// चुपचाप पहले से जुड़े खाते से जुड़ो (किसान को कुछ दिखाए बिना)
  Future<bool> signInSilently() async {
    try {
      _account = await _signIn.signInSilently();
      return _account != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _signIn.signOut();
    } catch (_) {}
    _account = null;
    await BackupGuard.instance.setGoogleEmail(null);
  }

  // ── चढ़ाना ─────────────────────────────────────────────────────

  /// पूरा backup Drive पर चढ़ा दो। सफल हो तो `true`।
  ///
  /// नाकाम होने पर चुपचाप `false` — किसान को टोकना नहीं है, क्योंकि उसका
  /// data फ़ोन में तो सुरक्षित है ही। अगली बार ऐप बंद करते समय दोबारा
  /// कोशिश हो जाएगी।
  Future<bool> upload() async {
    try {
      if (_account == null && !await signInSilently()) return false;

      final client = await _signIn.authenticatedClient();
      if (client == null) return false;

      final api = drive.DriveApi(client);
      final payload = await BackupService().buildPayload();
      final bytes = utf8.encode(jsonEncode(payload));

      final media = drive.Media(Stream.value(bytes), bytes.length);

      // पहले से फ़ाइल हो तो उसी को बदलो — वरना हर बार नई बनती रहेगी
      final purani = await _dhoondhoFile(api);
      if (purani != null) {
        await api.files.update(drive.File(), purani, uploadMedia: media);
      } else {
        await api.files.create(
          drive.File()
            ..name = _fileName
            ..parents = ['appDataFolder'],
          uploadMedia: media,
        );
      }

      await BackupGuard.instance.markBackedUp();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── वापस लाना ──────────────────────────────────────────────────

  /// Drive पर रखा backup पढ़कर लौटाओ। कुछ न मिले तो null।
  ///
  /// नया फ़ोन लेने पर किसान यहीं से अपना पूरा हिसाब वापस पाता है।
  Future<Map<String, dynamic>?> download() async {
    try {
      if (_account == null && !await signInSilently()) return null;

      final client = await _signIn.authenticatedClient();
      if (client == null) return null;

      final api = drive.DriveApi(client);
      final id = await _dhoondhoFile(api);
      if (id == null) return null;

      final media = await api.files.get(
        id,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final chunks = <int>[];
      await for (final c in media.stream) {
        chunks.addAll(c);
      }
      final decoded = jsonDecode(utf8.decode(chunks));
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  // ── नया फ़ोन: पुराना हिसाब वापस लाना ────────────────────────────

  /// Drive से backup लाकर सीधे database में डाल दो।
  ///
  /// यही वह क़दम है जिसके लिए पूरा Drive वाला काम बना है — नया फ़ोन लेने पर
  /// किसान का महीनों का हिसाब यहीं से वापस आता है।
  ///
  /// लौटाता है: कितनी पंक्तियाँ वापस आईं। कुछ न मिले तो `null`।
  Future<int?> restoreFromDrive() async {
    final data = await download();
    if (data == null) return null;

    final ok = await BackupService().restoreFromDetectedBackup(data);
    if (!ok) return null;

    // किसान को गिनती दिखाने के लिए — "इतना वापस आया"
    final tables = data['tables'];
    if (tables is Map) {
      var kul = 0;
      for (final v in tables.values) {
        if (v is List) kul += v.length;
      }
      return kul;
    }
    // पुरानी 1.0.0 बनावट
    final c = data['customers'];
    final e = data['entries'];
    return (c is List ? c.length : 0) + (e is List ? e.length : 0);
  }

  /// Drive पर कुछ रखा है या नहीं — बिना पूरा उतारे।
  ///
  /// ऐप खुलते समय यही पूछा जाता है: फ़ोन ख़ाली है और Drive पर हिसाब पड़ा है?
  /// तभी किसान से पूछते हैं "वापस लाएँ?"। हर बार पूरी फ़ाइल उतारना बेकार है।
  Future<bool> kuchRakhaHai() async {
    try {
      if (_account == null && !await signInSilently()) return false;
      final client = await _signIn.authenticatedClient();
      if (client == null) return false;
      return await _dhoondhoFile(drive.DriveApi(client)) != null;
    } catch (_) {
      return false;
    }
  }

  /// छिपे फ़ोल्डर में हमारी फ़ाइल की id ढूँढ़ो
  Future<String?> _dhoondhoFile(drive.DriveApi api) async {
    try {
      final list = await api.files.list(
        spaces: 'appDataFolder',
        q: "name = '$_fileName'",
        $fields: 'files(id, name)',
      );
      final files = list.files;
      if (files == null || files.isEmpty) return null;
      return files.first.id;
    } catch (_) {
      return null;
    }
  }
}
