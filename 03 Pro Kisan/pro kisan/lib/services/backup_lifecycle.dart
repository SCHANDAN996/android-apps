import 'package:flutter/widgets.dart';

import 'backup_guard.dart';
import 'backup_service.dart';
import 'google_drive_backup.dart';

/// 🛡️ ऐप बंद होते ही किसान का हिसाब Google Drive पर चढ़ा देता है।
///
/// ## हर एंट्री पर क्यों नहीं
///
/// किसान सुबह 10 ग्राहकों की एंट्री करता है। हर एंट्री पर upload करते तो
/// 10 बार network चलता — गाँव के 2G पर वह ज़्यादातर नाकाम होता और बैटरी
/// अलग खाता। इसलिए **ऐप बंद करते समय एक बार** — तब तक सारी एंट्री हो चुकी
/// होती हैं और एक ही upload में सब चढ़ जाता है।
///
/// ## crash होने पर क्या
///
/// ऐप बंद होने से पहले crash हो जाए तो वह मौक़ा निकल जाता है। इसलिए एक सस्ता
/// जाल भी रखा है: **ऐप खुलते समय** अगर पिछला backup 24 घंटे से पुराना है तो
/// एक बार तभी चढ़ा देते हैं। इससे network का ख़र्च नहीं बढ़ता (दिन में
/// ज़्यादा से ज़्यादा एक बार), और crash वाली सूरत भी सँभल जाती है।
///
/// ## Google खाता न जुड़ा हो तो
///
/// तब Drive पर कुछ नहीं जाता। फ़ोन के भीतर वाला backup फिर भी बनता रहता है
/// (`autoSaveToPublicFolder`), और किसान को हफ़्ते में एक बार WhatsApp वाली
/// याद दिलाई जाती है — देखें [BackupGuard]।
class BackupLifecycle with WidgetsBindingObserver {
  BackupLifecycle._();
  static final BackupLifecycle instance = BackupLifecycle._();

  bool _lagaHua = false;
  bool _chalRahaHai = false; // दो upload एक साथ न चलें

  /// ऐप शुरू होते समय एक बार बुलाइए
  void suruKaro() {
    if (_lagaHua) return;
    _lagaHua = true;
    WidgetsBinding.instance.addObserver(this);
    // खुलते ही देख लो — पिछला backup बहुत पुराना तो नहीं
    _agarPuranaHaiToChadhao();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // `paused` = किसान ने ऐप पीछे किया या बंद किया
    // `detached` = ऐप सचमुच बंद हो रहा है
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _chadhao();
    }
  }

  /// फ़ोन के भीतर backup + (खाता जुड़ा हो तो) Drive पर
  Future<void> _chadhao() async {
    if (_chalRahaHai) return;
    _chalRahaHai = true;
    try {
      // 1. फ़ोन के भीतर वाला backup — यह हमेशा होता है, चाहे खाता जुड़ा हो
      //    या नहीं। इंटरनेट न हो तब भी किसान का हिसाब फ़ाइल में सुरक्षित।
      try {
        await BackupService().autoSaveToPublicFolder();
      } catch (_) {}

      // 2. Google खाता जुड़ा हो तभी Drive पर
      if (await BackupGuard.instance.googleEmail() != null) {
        await GoogleDriveBackup.instance.upload();
      }
    } catch (_) {
      // नाकाम हो तो चुपचाप — किसान का data फ़ोन में सुरक्षित है ही,
      // और अगली बार ऐप बंद करते समय दोबारा कोशिश हो जाएगी
    } finally {
      _chalRahaHai = false;
    }
  }

  /// ऐप खुलते समय — पिछला backup 24 घंटे से पुराना हो तभी
  Future<void> _agarPuranaHaiToChadhao() async {
    try {
      if (await BackupGuard.instance.googleEmail() == null) return;
      final at = await BackupGuard.instance.lastBackupAt();
      if (at != null && DateTime.now().difference(at).inHours < 24) return;
      await _chadhao();
    } catch (_) {}
  }
}
