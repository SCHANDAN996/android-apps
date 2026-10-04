import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mistri_calculator/core/constants/strings.dart';
import 'package:mistri_calculator/core/services/storage_service.dart';
import 'package:mistri_calculator/core/theme/app_theme.dart';
import 'package:mistri_calculator/main.dart';
import 'package:mistri_calculator/screens/project_screen.dart';
import 'package:mistri_calculator/screens/steel_screen.dart';
import 'package:mistri_calculator/widgets/add_to_project_button.dart';
import 'package:mistri_calculator/widgets/shared_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    // No ad SDK in tests — every call to the plugin just answers "null".
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
          'plugins.flutter.io/google_mobile_ads',
          (_) async => const StandardMethodCodec().encodeSuccessEnvelope(null),
        );
  });

  Future<StorageService> pumpApp(WidgetTester tester) async {
    // A tall phone, so a focused field never scrolls the button away.
    await tester.binding.setSurfaceSize(const Size(420, 2800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({'rate_cement': 400.0});
    final storage = StorageService();
    await storage.init();
    AppStrings.setLanguage('en');
    await tester.pumpWidget(MistriCalculatorApp(storage: storage));
    await tester.pumpAndSettle();
    return storage;
  }

  Future<void> tapCalculate(WidgetTester tester) async {
    final button = find.descendant(
      of: find.byType(CalculateButton),
      matching: find.byType(ElevatedButton),
    );
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets('switching to dark recolours the screen that is open', (
    tester,
  ) async {
    await pumpApp(tester);
    addTearDown(() => AppTheme.mode.value = 'system');
    Color background() =>
        tester.widget<Scaffold>(find.byType(Scaffold).first).backgroundColor ??
        Theme.of(
          tester.element(find.byType(Scaffold).first),
        ).scaffoldBackgroundColor;

    AppTheme.mode.value = 'light';
    await tester.pumpAndSettle();
    final light = background();

    AppTheme.mode.value = 'dark';
    await tester.pumpAndSettle();
    expect(AppColors.dark, isTrue);
    expect(background(), isNot(light));
    expect(background().computeLuminance(), lessThan(0.05));
  });

  testWidgets('an empty form shows an error and no result', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text(AppStrings.get('brick')));
    await tester.pumpAndSettle();

    await tapCalculate(tester);

    expect(find.text(AppStrings.get('enterValue')), findsOneWidget);
    expect(find.byType(HeroResultCard), findsNothing);

    // Let the snackbar's timer run out.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('brick wall: calculate, add to My House, see the total', (
    tester,
  ) async {
    final storage = await pumpApp(tester);
    await tester.tap(find.text(AppStrings.get('brick')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), '10');
    await tester.enterText(find.byType(TextFormField).at(2), '10');
    await tapCalculate(tester);

    expect(find.byType(HeroResultCard), findsOneWidget);

    final add = find.byType(AddToProjectButton);
    await tester.ensureVisible(add);
    await tester.pumpAndSettle();
    await tester.tap(add);
    await tester.pumpAndSettle();

    final items = storage.projectItems;
    expect(items, hasLength(1));
    expect(items.single.type, 'brick');
    expect(items.single.detail, startsWith('10 ft × 10 ft'));

    // The button is now a tick — a second tap must not add it again.
    await tester.tap(add, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(storage.projectItems, hasLength(1));

    await tester.tap(find.text(AppStrings.get('view')));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectScreen), findsOneWidget);
    expect(find.text(AppStrings.get('totalMaterial')), findsOneWidget);
    // Cement has a rate, so the bill shows up.
    expect(find.text(AppStrings.get('estimatedCost')), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('a slab result carries its volume over to the steel screen', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text(AppStrings.get('concrete')));
    await tester.pumpAndSettle();

    // 10 x 10 ft slab, 5 inch thick
    await tester.enterText(find.byType(TextFormField).at(0), '10');
    await tester.enterText(find.byType(TextFormField).at(2), '10');
    await tester.enterText(find.byType(TextFormField).at(4), '5');
    await tapCalculate(tester);

    final link = find.text(AppStrings.get('steelForThis'));
    await tester.ensureVisible(link);
    await tester.pumpAndSettle();
    await tester.tap(link);
    await tester.pumpAndSettle();

    // 3.048 x 3.048 x 0.127 m = 1.18 m3 = 41.67 cft, already filled in.
    expect(find.byType(SteelScreen), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '41.67'), findsOneWidget);

    await tapCalculate(tester);

    // 1.18 m3 x 80 kg/m3 x 1.03 wastage
    expect(find.bySemanticsLabel('97.2 kg'), findsOneWidget);
  });
}
