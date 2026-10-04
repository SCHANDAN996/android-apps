import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mistri_calculator/core/constants/strings.dart';
import 'package:mistri_calculator/core/services/storage_service.dart';
import 'package:mistri_calculator/core/theme/app_theme.dart';
import 'package:mistri_calculator/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'full_flow.dart';

void main() {
  testWidgets('every feature, start to finish', (tester) async {
    // No ad SDK on the host — every call to the plugin just answers "null".
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
          'plugins.flutter.io/google_mobile_ads',
          (_) async => const StandardMethodCodec().encodeSuccessEnvelope(null),
        );
    // The phone's size: 720 x 1600 px at 2x.
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    await storage.init();
    AppStrings.setLanguage('hi');
    AppTheme.mode.value = 'light';
    addTearDown(() => AppTheme.mode.value = 'system');

    await tester.pumpWidget(MistriCalculatorApp(storage: storage));
    await FullFlow(tester, storage, (_) async {}).run();

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}
