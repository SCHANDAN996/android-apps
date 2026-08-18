import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geolocator/geolocator.dart';
import '../db/dao/settings_dao.dart';
import '../l10n/app_localizations.dart';
import '../ui/theme/dairy_theme.dart';
import 'notification_service.dart';

/// ऐप की शुरुआत में सारी runtime permissions एक साथ माँगना —
/// पर **पहले साफ़-साफ़ बताकर** कि कौन सी अनुमति किस काम आती है।
///
/// ⚠️ यह "prominent disclosure" Google Play की User Data policy की माँग है:
/// लोकेशन/कॉन्टैक्ट जैसी संवेदनशील अनुमति माँगने से पहले, ऐप को अपनी भाषा में
/// बताना होता है कि वह किसलिए ली जा रही है — सिर्फ़ Android का system dialog
/// दिखा देना नियम-विरुद्ध है। इसीलिए पहले अपना dialog, फिर system dialogs।
///
/// नियम:
///  • disclosure सिर्फ़ एक बार — मना करें तो दोबारा तंग नहीं करते
///  • notification हर launch पर जाँच (पहले से मिली हो तो चुपचाप निकल जाता है)
///  • camera upfront नहीं — image_picker उपयोग के समय ख़ुद माँगता है
class PermissionService {
  static final PermissionService instance = PermissionService._();
  PermissionService._();

  static const String _flagKey = 'startup_perms_requested';

  Future<void> requestAllOnStartup(BuildContext context) async {
    final dao = SettingsDao();

    bool alreadyAsked = false;
    try {
      alreadyAsked = await dao.getSetting(_flagKey) == '1';
    } catch (_) {}

    if (alreadyAsked) {
      // सिर्फ़ notification की पुष्टि — यह चुपचाप होती है
      try {
        await NotificationService.instance.requestPermissions();
      } catch (_) {}
      return;
    }

    if (!context.mounted) return;
    final agreed = await _showDisclosure(context);

    // पूछ लिया — जवाब चाहे जो हो, दोबारा नहीं पूछेंगे
    try {
      await dao.setSetting(_flagKey, '1');
    } catch (_) {}

    if (agreed != true) return;

    try {
      await NotificationService.instance.requestPermissions();
    } catch (_) {}

    // location — मौसम अपने-आप सही जगह का दिखे
    try {
      final p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
    } catch (_) {}

    // contacts — "कॉन्टैक्ट से चुनें" तुरंत काम करे
    try {
      await FlutterContacts.requestPermission(readonly: true);
    } catch (_) {}
  }

  /// अनुमति क्यों चाहिए — अपनी भाषा में, system dialog से पहले।
  Future<bool?> _showDisclosure(BuildContext context) {
    String t(String k) => AppLocalizations.get(context, k);
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.shield_rounded, color: DairyTheme.primaryTeal),
            const SizedBox(width: 10),
            Expanded(
              child: Text(t('permTitle'),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t('permIntro'),
                  style: const TextStyle(fontSize: 14, height: 1.4)),
              const SizedBox(height: 12),
              _line(t('permNotif')),
              _line(t('permLoc')),
              _line(t('permContacts')),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: DairyTheme.primaryTeal.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(t('permNote'),
                    style: const TextStyle(fontSize: 12.5, height: 1.4)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t('permLater')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 18)),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t('permAllow')),
          ),
        ],
      ),
    );
  }

  Widget _line(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontSize: 13.5, height: 1.35)),
      );
}
