import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mistri_calculator/core/constants/strings.dart';
import 'package:mistri_calculator/core/services/storage_service.dart';
import 'package:mistri_calculator/core/theme/app_theme.dart';
import 'package:mistri_calculator/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/full_flow.dart';

/// The whole-app walk-through, on a real phone.
///
/// Run with ads off, so no interstitial can cover the screen mid-test:
///
///   flutter drive --driver=test_driver/integration_test.dart \
///     --target=integration_test/app_test.dart --dart-define=NO_ADS=true
///
/// It never touches what the user has saved on the phone: preferences are
/// swapped for an empty in-memory store before the app starts.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('every feature, start to finish', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    await storage.init();
    AppStrings.setLanguage('hi');
    AppTheme.mode.value = 'light';

    final appKey = GlobalKey();
    final shots = <String, String>{};

    Future<void> shot(String name) async {
      // A leftover "added" message has no place in a store picture.
      for (final m in tester.stateList<ScaffoldMessengerState>(
        find.byType(ScaffoldMessenger),
      )) {
        m.clearSnackBars();
      }
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 400));
      final boundary =
          appKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(
        pixelRatio: tester.view.devicePixelRatio,
      );
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      shots[name] = base64Encode(data!.buffer.asUint8List());
    }

    await tester.pumpWidget(
      RepaintBoundary(key: appKey, child: MistriCalculatorApp(storage: storage)),
    );
    await FullFlow(tester, storage, shot).run();

    // Handed to the driver on the PC, which writes them out as PNG files.
    binding.reportData = {'screenshots': shots};
  });
}
