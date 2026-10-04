import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mistri_calculator/core/constants/strings.dart';
import 'package:mistri_calculator/core/models/project_item.dart';
import 'package:mistri_calculator/core/services/storage_service.dart';
import 'package:mistri_calculator/core/theme/app_theme.dart';
import 'package:mistri_calculator/screens/project_screen.dart';
import 'package:mistri_calculator/screens/steel_screen.dart';
import 'package:mistri_calculator/widgets/add_to_project_button.dart';
import 'package:mistri_calculator/widgets/length_field.dart';
import 'package:mistri_calculator/widgets/shared_widgets.dart';

/// Takes a picture of the app as it is right now. A no-op on the host.
typedef Shot = Future<void> Function(String name);

/// Walks through every feature of the app the way a user would, checking the
/// numbers against hand calculations.
///
/// Shared by the host widget test and the on-device integration test, so a
/// step is debugged in seconds on the PC before it is run on the phone.
class FullFlow {
  final WidgetTester t;
  final StorageService storage;
  final Shot shot;

  FullFlow(this.t, this.storage, this.shot);

  String s(String key) => AppStrings.get(key);

  Future<void> settle() => t.pumpAndSettle(const Duration(milliseconds: 50));

  // --- Moving around ---

  /// Opens a home-screen card by its title.
  Future<void> openFromHome(String key) async {
    final card = find.text(s(key));
    // Always search from the top — the last visit may have left Home
    // scrolled past the card.
    await t.drag(find.byType(Scrollable).first, const Offset(0, 4000));
    await settle();
    await t.scrollUntilVisible(
      card,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await settle();
    await t.tap(card);
    await settle();
  }

  Future<void> back() async {
    await t.pageBack();
    await settle();
  }

  Future<void> tapOn(Finder finder) async {
    await t.ensureVisible(finder);
    await settle();
    await t.tap(finder);
    await settle();
  }

  // --- Filling a form ---

  /// A plain number box, found by its label.
  Future<void> type(String label, String value) async {
    final field = find.widgetWithText(TextFormField, label);
    await t.ensureVisible(field);
    await t.enterText(field, value);
    await t.pump();
  }

  /// A feet + inch length, found by the label of its feet box.
  Future<void> typeLength(String label, String feet, [String? inches]) async {
    final pair = find.descendant(
      of: find.ancestor(
        of: find.text('$label (ft)').first,
        matching: find.byType(LengthField),
      ),
      matching: find.byType(TextFormField),
    );
    await t.ensureVisible(pair.first);
    await t.enterText(pair.at(0), feet);
    if (inches != null) await t.enterText(pair.at(1), inches);
    await t.pump();
  }

  Future<void> calculate() async {
    FocusManager.instance.primaryFocus?.unfocus();
    await t.pump();
    await tapOn(
      find.descendant(
        of: find.byType(CalculateButton),
        matching: find.byType(ElevatedButton),
      ),
    );
  }

  Future<void> addToProject() async {
    final before = storage.projectItems.length;
    await tapOn(find.byType(AddToProjectButton));
    expect(storage.projectItems, hasLength(before + 1));
  }

  /// The value shown beside [label] in a result card.
  String rowValue(String label) => t
      .widget<ResultRow>(
        find.byWidgetPredicate((w) => w is ResultRow && w.label == label),
      )
      .value;

  String get hero =>
      t.widget<HeroResultCard>(find.byType(HeroResultCard)).value;

  /// Answers the name / amount dialog.
  Future<void> answerDialog(String text) async {
    await t.enterText(find.byType(TextField).last, text);
    await t.tap(find.text(s('save')).last);
    await settle();
  }

  // --- The steps ---

  Future<void> rates() async {
    await openFromHome('myRates');
    const values = {
      'brickRate': '8000',
      'cementRate': '400',
      'sandRate': '60',
      'aggregateRate': '70',
      'steelRate': '65',
      'tileRate': '600',
      'paintRate': '250',
    };
    for (final e in values.entries) {
      await type(s(e.key), e.value);
    }
    await calculate(); // the Save button
    expect(storage.allRates, {
      'brick': 8000,
      'cement': 400,
      'sand': 60,
      'aggregate': 70,
      'steel': 65,
      'tile': 600,
      'paint': 250,
    });
    expect(storage.ratesAgeDays, 0);
    await t.pump(const Duration(seconds: 4)); // let "saved" go away
    await settle();
    await t.drag(find.byType(Scrollable).first, const Offset(0, 2000));
    await settle();
    await shot('07_rates');
    await back();
  }

  Future<void> brick() async {
    await openFromHome('brick');

    // Nothing typed: an error, and no answer.
    await calculate();
    expect(find.text(s('enterValue')), findsOneWidget);
    expect(find.byType(HeroResultCard), findsNothing);
    await t.pump(const Duration(seconds: 4));
    await settle();

    // 10 x 10 ft, 9 inch wall, desi brick, 1:6
    await typeLength(s('wallLength'), '10');
    await typeLength(s('wallHeight'), '10');
    await calculate();
    expect(hero, '974');
    expect(rowValue(s('cementBags')), '3'); // 2.84 bags
    expect(rowValue(s('sandCft')), '21'); // 20.9 cft
    // 974 bricks at 8000/1000 + 3 bags at 400 + 21 cft at 60
    expect(find.text('₹10,252'), findsOneWidget);
    await shot('02_brick');
    await addToProject();

    // The same wall in metres gives the same bricks.
    await tapOn(find.text(s('meter')));
    await type(s('wallLength'), '3.048');
    await type(s('wallHeight'), '3.048');
    await calculate();
    expect(hero, '974');
    await back();
  }

  Future<void> concreteAndSteel() async {
    await openFromHome('concrete');

    // 10 x 10 ft slab, 5 inch thick, M20
    await typeLength(s('length'), '10');
    await typeLength(s('width'), '10');
    await type(s('depth'), '5');
    await calculate();
    expect(hero, '10'); // 9.997 bags
    expect(rowValue(s('sandCft')), '19'); // 18.4 cft
    expect(rowValue(s('aggregateCft')), '37'); // 36.75 cft
    expect(rowValue('${s('volume')} (m³)'), '1.18');
    // 10 x 400 + 19 x 60 + 37 x 70
    expect(find.text('₹7,730'), findsOneWidget);
    await shot('03_concrete');
    await addToProject();

    // The slab's volume goes along to the steel screen.
    await tapOn(find.text(s('steelForThis')));
    expect(find.byType(SteelScreen), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '41.67'), findsOneWidget);
    await calculate();
    expect(hero, '97.2 kg'); // 1.18 m3 x 80 kg x 1.03
    await addToProject();
    await back();

    // Four 9 x 12 inch columns, 10 ft tall
    await tapOn(find.text(s('column')));
    await typeLength(s('length'), '10');
    await type(s('width'), '9');
    await type(s('depth'), '12');
    await type(s('count'), '4');
    await calculate();
    expect(rowValue('${s('volume')} (m³)'), '0.85');
    await back();
  }

  Future<void> steelByRods() async {
    await openFromHome('steel');
    await tapOn(find.text(s('rodCount')).first);
    await type(s('rodCount'), '10');
    await calculate();
    // 10 rods x 12 m x (12 x 12 / 162) kg/m x 1.03
    expect(hero, '109.9 kg');
    await back();
  }

  Future<void> plaster() async {
    await openFromHome('plaster');
    await typeLength(s('length'), '10');
    await typeLength(s('height'), '10');
    await calculate();
    expect(hero, '1'); // 0.73 bags
    expect(rowValue(s('sandCft')), '6'); // 5.4 cft
    await addToProject();
    await back();
  }

  Future<void> tiles() async {
    await openFromHome('tiles');
    await typeLength(s('floorLength'), '10');
    await typeLength(s('floorWidth'), '12');
    await calculate();
    expect(hero, '35'); // 11.15 m2 / 0.36 m2 x 1.10
    expect(rowValue(s('totalBoxes')), '9');
    await addToProject();
    await back();
  }

  Future<void> paint() async {
    await openFromHome('paint');
    await typeLength(s('length'), '12');
    await typeLength(s('width'), '10');
    await typeLength(s('height'), '10');
    await calculate();
    // 2 x (12 + 10) x 10 = 440 sq ft, less 10% = 36.8 m2, two coats
    expect(hero, '7.4 L');
    expect(find.text('2 × 4L'), findsOneWidget);
    expect(rowValue(s('primer')), '3.7 L');
    expect(rowValue(s('putty')), '20 kg');
    await shot('06_paint');
    await addToProject();
    await back();
  }

  Future<void> stairs() async {
    await openFromHome('stairs');
    await typeLength(s('floorHeight'), '10');
    await typeLength(s('stairWidth'), '3');
    await calculate();
    expect(hero, '17'); // 120 inch / 7 inch
    await shot('05_stairs');
    await addToProject();
    await back();
  }

  Future<void> excavation() async {
    await openFromHome('excavation');
    await typeLength(s('length'), '30');
    await typeLength(s('width'), '2');
    await typeLength(s('depth'), '2', '6'); // 2 ft 6 in
    await calculate();
    expect(hero, '150.0 cft');
    await addToProject();
    await back();
  }

  Future<void> waterTank() async {
    await openFromHome('waterTank');
    await typeLength(s('length'), '4');
    await typeLength(s('width'), '4');
    await typeLength(s('height'), '4');
    await calculate();
    expect(hero, '1,812 ${s('litres')}'); // 64 cft

    await tapOn(find.text(s('roundTank')));
    await typeLength(s('tankDiameter'), '4');
    await calculate();
    expect(hero, '1,423 ${s('litres')}');
    await back();
  }

  Future<void> project() async {
    await openFromHome('myProject');
    expect(find.byType(ProjectScreen), findsOneWidget);
    // brick, slab, steel, plaster, tiles, paint, stairs, excavation
    expect(storage.projectItems, hasLength(8));

    final totals = ProjectTotals(storage.projectItems);
    expect(totals.bricks, 974);
    expect(totals.tiles, 35);
    expect(totals.tileBoxes, 9);
    expect(totals.excavationCft, 150);
    expect(rowValue(s('brickCount')), '974');
    expect(rowValue(s('cementBags')), '${totals.cementBags}');

    // Name two of the items.
    await tapOn(find.byTooltip(s('rename')).at(0));
    await answerDialog('बेडरूम की दीवार');
    await tapOn(find.byTooltip(s('rename')).at(1));
    await answerDialog('छत की ढलाई');
    expect(storage.projectItems[0].name, 'बेडरूम की दीवार');
    expect(find.text('छत की ढलाई'), findsOneWidget);

    // Labour joins the bill.
    await tapOn(find.text(s('labourCost')).last);
    await answerDialog('15000');
    expect(storage.projectLabour, 15000);
    expect(find.text('₹15,000'), findsWidgets);

    // Remove the excavation.
    await tapOn(find.byTooltip(s('remove')).last);
    expect(storage.projectItems, hasLength(7));

    // A second house starts empty and does not touch the first.
    await t.tap(find.text(s('myProject')).first);
    await settle();
    await t.tap(find.text(s('newProject')));
    await settle();
    await answerDialog('वर्मा जी की दुकान');
    expect(storage.currentProject.name, 'वर्मा जी की दुकान');
    expect(storage.projectItems, isEmpty);
    expect(find.text(s('projectEmpty')), findsOneWidget);

    // Back to the first house, then delete the second.
    await t.tap(find.text('वर्मा जी की दुकान').first);
    await settle();
    await t.tap(find.text(s('myProject')).last);
    await settle();
    expect(storage.projectItems, hasLength(7));
    await t.tap(find.text(s('myProject')).first);
    await settle();
    await t.tap(find.byTooltip(s('deleteProject')).last);
    await settle();
    await t.tap(find.text(s('remove')).last);
    await settle();
    expect(storage.projects, hasLength(1));

    // Give the house its name.
    await t.tap(find.text(s('myProject')).first);
    await settle();
    await t.tap(find.byTooltip(s('rename')).last);
    await settle();
    await answerDialog('शर्मा जी का घर');
    expect(storage.currentProject.name, 'शर्मा जी का घर');
    expect(find.text('शर्मा जी का घर'), findsOneWidget);

    await shot('04_project');
    await t.drag(find.byType(Scrollable).first, const Offset(0, -560));
    await settle();
    await shot('04b_project_bill');
    await back();
  }

  Future<void> settings() async {
    // Dark theme, from the Settings screen.
    await t.drag(find.byType(Scrollable).first, const Offset(0, 4000));
    await settle();
    await t.tap(find.byTooltip(s('settings')));
    await settle();
    await tapOn(find.text(s('themeDark')));
    expect(AppColors.dark, isTrue);
    expect(storage.themeMode, 'dark');
    await back();
    await shot('08_dark');

    await t.tap(find.byTooltip(s('settings')));
    await settle();
    await tapOn(find.text(s('themeLight')));
    expect(AppColors.dark, isFalse);

    // English, and back to Hindi.
    // The list is lazy: the language row at the top may be scrolled away.
    await t.drag(find.byType(Scrollable).first, const Offset(0, 2000));
    await settle();
    await tapOn(find.textContaining(s('language')));
    await t.tap(find.text('English'));
    await settle();
    expect(storage.language, 'en');
    await back();
    expect(find.text('Mistri Calculator'), findsOneWidget);
    expect(find.text('Bricks'), findsOneWidget);

    await t.tap(find.byTooltip('Settings'));
    await settle();
    // The list is lazy: the language row at the top may be scrolled away.
    await t.drag(find.byType(Scrollable).first, const Offset(0, 2000));
    await settle();
    await tapOn(find.textContaining('Language'));
    await t.tap(find.text('हिन्दी (Hindi)'));
    await settle();
    await back();
    expect(find.text('मिस्त्री कैलकुलेटर'), findsOneWidget);
  }

  Future<void> run() async {
    await settle();
    await shot('01_home');
    await rates();
    await brick();
    await concreteAndSteel();
    await steelByRods();
    await plaster();
    await tiles();
    await paint();
    await stairs();
    await excavation();
    await waterTank();
    await project();
    await settings();
  }
}
