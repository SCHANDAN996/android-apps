import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panchang_engine/panchang_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/main.dart';
import 'package:vidhivat/screens/aaj_screen.dart';
import 'package:vidhivat/screens/calendar_screen.dart';
import 'package:vidhivat/screens/muhurta_screen.dart';
import 'package:vidhivat/screens/sankalp_screen.dart';
import 'package:vidhivat/screens/settings_screen.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/widgets/common.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await settings.load();
    await settings.setYajman(name: 'चन्दन', gotra: 'कश्यप');
  });

  Widget app(Widget home, {TextScaler? scaler}) => ListenableBuilder(
        listenable: settings,
        builder: (context, _) => MaterialApp(
          theme: VidhivatTheme.dark(),
          builder: (context, child) => scaler == null
              ? child!
              : MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: scaler),
                  child: child!,
                ),
          home: home,
        ),
      );

  void phone(WidgetTester tester, double width, {double height = 800}) {
    tester.view.physicalSize = Size(width * 3, height * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> scrollTo(WidgetTester tester, Finder finder) =>
      tester.scrollUntilVisible(
        finder,
        160,
        scrollable: find.byType(Scrollable).first,
      );

  testWidgets('Aaj real Panchang values 320dp और 1.5x पर पूरे रहते हैं',
      (tester) async {
    phone(tester, 320);
    final p = settings.panchangFor(DateTime.now());

    await tester.pumpWidget(
      app(const AajScreen(), scaler: const TextScaler.linear(1.5)),
    );
    expect(find.textContaining(p.tithi.name), findsWidgets);
    expect(find.textContaining(p.nakshatra.name), findsWidgets);
    await scrollTo(tester, find.text(hms(p.sunrise)));
    expect(find.text(hms(p.sunrise)), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Calendar grid 320dp/1.5x पर tappable और selected semantic है',
      (tester) async {
    phone(tester, 320);
    final today = DateTime.now();
    final todayFinder = find.byKey(
      Key('calendar_day_${today.year}_${today.month}_${today.day}'),
    );

    await tester.pumpWidget(
      app(const CalendarScreen(), scaler: const TextScaler.linear(1.5)),
    );

    expect(todayFinder, findsOneWidget);
    final size = tester.getSize(todayFinder);
    expect(size.width, greaterThanOrEqualTo(44));
    expect(size.height, greaterThanOrEqualTo(44));
    expect(
      tester.getSemantics(todayFinder).flagsCollection.isSelected ==
          Tristate.isTrue,
      isTrue,
    );

    final anotherDay = today.day == 1 ? 2 : 1;
    final anotherDate = DateTime(today.year, today.month, anotherDay);
    final anotherFinder = find.byKey(
      Key('calendar_day_${today.year}_${today.month}_$anotherDay'),
    );
    await tester.ensureVisible(anotherFinder);
    await tester.tap(anotherFinder);
    await tester.pump();
    expect(
      tester.getSemantics(anotherFinder).flagsCollection.isSelected ==
          Tristate.isTrue,
      isTrue,
    );
    expect(find.text(tarikh(anotherDate)), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Calendar month navigation और real festival semantics सुरक्षित हैं',
      (tester) async {
    phone(tester, 360);
    final now = DateTime.now();
    final festival = festivalsInYear(now.year, settings.place).first;
    final monthOffset =
        (festival.date.year - now.year) * 12 + festival.date.month - now.month;

    await tester.pumpWidget(app(const CalendarScreen()));
    final shift = monthOffset >= 0
        ? find.byKey(const Key('calendar_next_month'))
        : find.byKey(const Key('calendar_previous_month'));
    for (var i = 0; i < monthOffset.abs(); i++) {
      await tester.tap(shift);
      await tester.pump();
    }

    final festivalDay = find.byKey(
      Key(
        'calendar_day_${festival.date.year}_${festival.date.month}_${festival.date.day}',
      ),
    );
    expect(festivalDay, findsOneWidget);
    expect(
        tester.getSemantics(festivalDay).label, contains(festival.rule.name));
    await tester.ensureVisible(festivalDay);
    await tester.tap(festivalDay);
    await tester.pump();
    expect(find.text(festival.rule.name), findsWidgets);

    expect(tester.takeException(), isNull);
  });

  testWidgets('Calendar festival tab actual year list दिखाता है',
      (tester) async {
    phone(tester, 393);
    await tester.pumpWidget(app(const CalendarScreen()));
    await tester.tap(find.text('त्योहार'));
    await tester.pumpAndSettle();
    expect(find.textContaining('के त्योहार'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sankalp purpose बदलने पर exact generated text ही render होता है',
      (tester) async {
    phone(tester, 320);
    await tester.pumpWidget(
      app(const SankalpScreen(), scaler: const TextScaler.linear(1.5)),
    );

    // ⚠️ पहले `ensureVisible`, फिर `tap`. बिना इसके tap चुपचाप ख़ाली
    // जाता है — चिप तह के नीचे होती है और Flutter उसके केंद्र पर tap
    // भेजता है, जो viewport से बाहर पड़ता है। कोई exception नहीं आता,
    // बस purpose नहीं बदलता और टेस्ट भ्रामक तरीक़े से फ़ेल होता है।
    // यह तब टूटा जब `commonPurposes` 12 से 18 का हो गया (छह नई पूजाएँ)।
    // ऐप में बग नहीं है — यूज़र स्क्रॉल करके चिप तक पहुँच जाता है।
    await tester.ensureVisible(find.text('गृह प्रवेश'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('गृह प्रवेश'));
    await tester.pump();
    await scrollTo(tester, find.byType(SelectableText));
    final p = settings.panchangFor(DateTime.now());
    final expected = buildSankalp(
      p,
      SankalpDetails(
        name: settings.name,
        gotra: settings.gotra,
        place: settings.city.name,
        purpose: commonPurposes['गृह प्रवेश']!,
      ),
    );
    final rendered = tester.widget<SelectableText>(find.byType(SelectableText));
    expect(rendered.data, expected.full);
    expect(rendered.maxLines, isNull);

    // "पूरा संकल्प" वाला segment चुनाव-chips के ऊपर होता है। chips की
    // संख्या बढ़ने पर वो तह से बाहर चला जाता है, इसलिए वापस स्क्रॉल करके
    // देखते हैं — जैसे यूज़र करता।
    await tester.scrollUntilVisible(
      find.text('पूरा संकल्प'),
      -160, // ऊपर की तरफ़ — यह segment संकल्प के पाठ से पहले आता है
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('पूरा संकल्प'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sankalp input keyboard के साथ scroll और save करता है',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await settings.load();
    phone(tester, 320, height: 640);
    var completed = false;

    await tester.pumpWidget(
      app(
        NaamPoochho(onDone: () => completed = true),
        scaler: const TextScaler.linear(1.5),
      ),
    );
    await scrollTo(tester, find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'सीमा');
    await tester.showKeyboard(find.byType(TextField));
    await tester.pump();
    // A3/A5/A12 के खाने जुड़ने के बाद पन्ना लंबा है — बटन को पूरी तरह
    // दिखने तक लाओ, वरना 320dp/1.5x पर tap किनारे से छूट जाता है।
    await scrollTo(tester, find.text('संकल्प बनाइए'));
    await tester.ensureVisible(find.text('संकल्प बनाइए'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('संकल्प बनाइए'));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
    expect(settings.name, 'सीमा');
    expect(tester.takeException(), isNull);
  });

  testWidgets('English नाम पर editable हिन्दी संकल्प-सुझाव दिखता है',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await settings.load();
    phone(tester, 393);
    await tester.pumpWidget(app(NaamPoochho(onDone: () {})));

    await tester.enterText(find.byType(TextField), 'Chandan');
    await tester.pump();

    expect(find.byType(TextField), findsNWidgets(2));
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).controller?.text,
      'चन्दन',
    );
    expect(find.text('संकल्प में जाने वाला हिन्दी नाम'), findsOneWidget);
    expect(find.textContaining('spelling देखकर confirm'), findsOneWidget);
    expect(find.text('हिन्दी सुझाव'), findsOneWidget);
    expect(find.text('English नाम'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Choghadiya order/status semantics 360dp/1.3x पर सुरक्षित हैं',
      (tester) async {
    phone(tester, 360);
    final now = DateTime.now();
    final slots = choghadiya(now.year, now.month, now.day, settings.place);

    await tester.pumpWidget(
      app(const MuhurtaScreen(), scaler: const TextScaler.linear(1.3)),
    );
    await scrollTo(tester, find.text('रात की चौघड़िया'));
    final nightIndex = slots.indexWhere((slot) => !slot.isDay);
    final nightFinder = find.byKey(Key('choghadiya_period_$nightIndex'));
    expect(nightFinder, findsOneWidget);
    final semantics = tester.getSemantics(nightFinder).label;
    expect(semantics, contains(slots[nightIndex].name));
    expect(
      semantics,
      contains(slots[nightIndex].auspicious! ? 'शुभ' : 'अशुभ'),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Settings representative persisted interaction बचाता है',
      (tester) async {
    phone(tester, 412);
    await tester.pumpWidget(app(const SettingsScreen()));
    await tester.tap(find.text('अमांत'));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(settings.masaSystem, MasaSystem.amanta);
    expect(preferences.getString('masaSystem'), 'amanta');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Settings में auto-location और manual city search दोनों दिखते हैं',
      (tester) async {
    phone(tester, 412);
    await tester.pumpWidget(app(const SettingsScreen()));

    expect(find.text('मेरी जगह अपने आप पहचानें'), findsOneWidget);
    await tester.tap(find.text('शहर हाथ से चुनें'));
    await tester.pumpAndSettle();
    expect(find.text('शहर खोजें'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Bottom navigation tab और Calendar state सुरक्षित रखता है',
      (tester) async {
    phone(tester, 393);
    await tester.pumpWidget(app(const HomeShell()));

    await tester.tap(find.text('कैलेंडर'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('calendar_next_month')));
    await tester.pump();
    final shifted = DateTime(DateTime.now().year, DateTime.now().month + 1);
    final shiftedHeader = tarikh(shifted).split(' ').skip(1).join(' ');
    expect(find.text(shiftedHeader), findsOneWidget);

    await tester.tap(find.text('अधिक').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('कैलेंडर'));
    await tester.pumpAndSettle();
    expect(find.text(shiftedHeader), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
