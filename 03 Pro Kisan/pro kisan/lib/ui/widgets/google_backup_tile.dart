import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/backup_guard.dart';
import '../../services/google_drive_backup.dart';

/// 🛡️ सेटिंग में "Google खाते में सुरक्षित रखें" वाली पट्टी।
///
/// किसान की **मर्ज़ी** का काम है — ऐप बिना Google खाते के पूरा चलता है।
/// जो जोड़ लेता है उसका हिसाब ऐप बंद करते ही उसकी अपनी Drive के छिपे फ़ोल्डर
/// में चढ़ जाता है, और नया फ़ोन लेने पर वापस मिल जाता है।
///
/// जो नहीं जोड़ते उन्हें हफ़्ते में एक बार याद दिलाई जाती है कि backup फ़ाइल
/// ख़ुद को WhatsApp पर भेज दें — देखें [BackupGuard]।
class GoogleBackupTile extends StatefulWidget {
  const GoogleBackupTile({super.key});

  @override
  State<GoogleBackupTile> createState() => _GoogleBackupTileState();
}

class _GoogleBackupTileState extends State<GoogleBackupTile> {
  String? _email;
  DateTime? _lastAt;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final e = await BackupGuard.instance.googleEmail();
    final a = await BackupGuard.instance.lastBackupAt();
    if (mounted) setState(() { _email = e; _lastAt = a; });
  }

  Future<void> _jodo() async {
    setState(() => _busy = true);
    final email = await GoogleDriveBackup.instance.signIn();
    if (!mounted) return;
    setState(() => _busy = false);

    if (email == null) {
      // Console का setup न हुआ हो, net न हो, या किसान ने रद्द कर दिया —
      // तीनों में ऐप पहले जैसा चलता रहता है, इसलिए डराना नहीं है
      final isHi = AppLocalizations.isHindiLike(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isHi
            ? 'खाता नहीं जुड़ पाया। आपका हिसाब फ़ोन में सुरक्षित है — '
                'चाहें तो बाद में जोड़ लीजिए।'
            : 'Could not connect. Your data is still safe on the phone — '
                'you can connect later.'),
      ));
      return;
    }

    // जुड़ते ही पहला backup चढ़ा दो, ताकि किसान को तुरंत भरोसा हो
    setState(() => _busy = true);
    await GoogleDriveBackup.instance.upload();
    await _load();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _hatao() async {
    final isHi = AppLocalizations.isHindiLike(context);
    final pakka = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(isHi ? 'खाता हटाएँ?' : 'Disconnect account?'),
        content: Text(isHi
            ? 'इसके बाद आपका हिसाब Google Drive पर अपने आप नहीं चढ़ेगा। '
                'फ़ोन में जो है वह सुरक्षित रहेगा।'
            : 'Your data will no longer be backed up to Google Drive. '
                'What is on the phone stays safe.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(isHi ? 'रहने दें' : 'Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text(isHi ? 'हटाएँ' : 'Disconnect')),
        ],
      ),
    );
    if (pakka != true) return;
    await GoogleDriveBackup.instance.signOut();
    await _load();
  }

  String _kabHua(bool isHi) {
    if (_lastAt == null) return isHi ? 'अभी तक नहीं' : 'not yet';
    final d = DateTime.now().difference(_lastAt!);
    if (d.inMinutes < 60) return isHi ? 'अभी' : 'just now';
    if (d.inHours < 24) {
      return isHi ? '${d.inHours} घंटे पहले' : '${d.inHours}h ago';
    }
    return isHi ? '${d.inDays} दिन पहले' : '${d.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final isHi = AppLocalizations.isHindiLike(context);
    final juda = _email != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: juda ? Colors.blue.shade50 : Colors.orange.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Icon(juda ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
              color: juda ? Colors.blue.shade700 : Colors.deepOrange, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  juda
                      ? (isHi ? 'Google में सुरक्षित' : 'Backed up to Google')
                      : (isHi
                          ? 'Google खाते में सुरक्षित रखें'
                          : 'Keep a copy in your Google account'),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color:
                          juda ? Colors.blue.shade800 : Colors.deepOrange.shade800),
                ),
                const SizedBox(height: 3),
                Text(
                  juda
                      ? '$_email\n${isHi ? "आख़िरी बार" : "last"}: ${_kabHua(isHi)}'
                      : (isHi
                          ? 'फ़ोन खो जाए या टूट जाए तो भी हिसाब वापस मिल जाएगा। '
                              'आपकी अपनी Drive में जाता है — हम उसे देख नहीं सकते।'
                          : 'Get your data back even if the phone is lost. '
                              'It goes to your own Drive — we cannot see it.'),
                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade800, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (_busy)
            const SizedBox(
                width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          else if (!juda)
            TextButton(onPressed: _jodo, child: Text(isHi ? 'जोड़ें' : 'Connect'))
          else
            // जुड़ा हो तो दो काम — वापस लाना और हटाना
            PopupMenuButton<String>(
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'restore',
                  child: Row(children: [
                    const Icon(Icons.cloud_download_rounded, size: 20),
                    const SizedBox(width: 10),
                    Text(isHi ? 'वापस ले आएँ' : 'Restore'),
                  ]),
                ),
                PopupMenuItem(
                  value: 'remove',
                  child: Row(children: [
                    const Icon(Icons.link_off_rounded, size: 20),
                    const SizedBox(width: 10),
                    Text(isHi ? 'खाता हटाएँ' : 'Disconnect'),
                  ]),
                ),
              ],
              onSelected: (v) => v == 'restore' ? _wapasLao() : _hatao(),
            ),
        ],
      ),
    );
  }

  /// Drive पर रखा हिसाब वापस फ़ोन में लाओ।
  ///
  /// ⚠️ यह फ़ोन का मौजूदा हिसाब **बदल देता है**, इसलिए पहले साफ़ पूछते हैं।
  /// (ऐप खुलते समय वाला अपने आप पूछने वाला रास्ता सिर्फ़ ख़ाली फ़ोन पर चलता
  /// है — देखें `DriveRestorePrompt`। यहाँ किसान ख़ुद माँग रहा है, इसलिए
  /// चेतावनी देकर करने देते हैं।)
  Future<void> _wapasLao() async {
    final isHi = AppLocalizations.isHindiLike(context);
    final pakka = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(isHi ? 'वापस ले आएँ?' : 'Restore?'),
        content: Text(isHi
            ? 'Google पर रखा हिसाब फ़ोन में आ जाएगा।\n\n'
                '⚠️ फ़ोन में अभी जो है, वह उससे बदल जाएगा।'
            : 'Records saved on Google will be brought back.\n\n'
                '⚠️ What is on the phone now will be replaced.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(isHi ? 'रहने दें' : 'Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text(isHi ? 'ले आइए' : 'Restore')),
        ],
      ),
    );
    if (pakka != true) return;

    setState(() => _busy = true);
    final kitna = await GoogleDriveBackup.instance.restoreFromDrive();
    if (!mounted) return;
    setState(() => _busy = false);
    await _load();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor:
          kitna != null ? Colors.green.shade700 : Colors.red.shade700,
      content: Text(kitna != null
          ? (isHi ? '✅ हिसाब वापस आ गया ($kitna पंक्तियाँ)' : '✅ Restored ($kitna rows)')
          : (isHi
              ? 'वापस नहीं ला पाए — इंटरनेट देखकर दोबारा कोशिश कीजिए।'
              : 'Could not restore — check internet and try again.')),
    ));
  }
}
