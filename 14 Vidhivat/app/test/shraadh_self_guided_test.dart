import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/vidhi_screen.dart';
import 'package:vidhivat/screens/vidhi_player_screen.dart';
import 'package:vidhivat/screens/pitru_schedule_screen.dart';
import 'package:vidhivat/screens/ancestor_profiles_screen.dart';
import 'package:vidhivat/widgets/jagah_khoj.dart';
import 'package:vidhivat/services/osm_khoj.dart';
import 'package:vidhivat/screens/aaj_screen.dart';
import 'package:vidhivat/screens/festival_destination.dart';
import 'package:vidhivat/state/ancestor_profiles.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/vidhi/vidhi.dart';
import 'package:vidhivat/vidhi/pitru_schedule.dart';
import 'package:vidhivat/widgets/mantra_khand.dart';
import 'package:panchang_engine/panchang_engine.dart';

void main() {
  late Vidhi shraadh;

  setUpAll(() {
    shraadh = Vidhi.parse(
      'assets/vidhi/shraadh.json',
      File('assets/vidhi/shraadh.json').readAsStringSync(),
    );
  });

  setUp(() async {
    // जगह की खोज लिखते ही इंटरनेट पर जाती है (→ D-134) — जाँच में नक़ली सर्वर
    osmKhoj = OsmKhoj(laao: (_) async => const OsmJawab(200, '{"features":[]}'));
    SharedPreferences.setMockInitialValues({});
    await settings.load();
  });

  Widget app(Widget home) => MaterialApp(
        theme: VidhivatTheme.dark(),
        home: home,
      );

  Charan charan(String shirshak) =>
      shraadh.charan.singleWhere((c) => c.shirshak == shirshak);

  test('सरल श्राद्ध खुलता है और तर्पण-पिंडदान के अलग प्रमाणित पाठ हैं', () {
    expect(shraadh.scope, Scope.regionalProfile);
    expect(shraadh.scope.poorViDhiKholSakteHain, isTrue);

    final tarpan = charan('तर्पण').mantra!;
    final pindadan = charan('पिंडदान').mantra!;

    expect(tarpan.devanagari, contains('देवताभ्यः पितृभ्यश्च'));
    expect(pindadan.devanagari, contains('ये पिण्डदानेन मुदं प्रयान्ति'));
    expect(tarpan.devanagari, isNot(equals(pindadan.devanagari)));
    expect(tarpan.chetavni, contains('पूरा वैदिक तर्पण-मंत्र नहीं'));
    expect(pindadan.chetavni, contains('पूरा पिंड-उत्सर्ग मंत्र नहीं'));
  });

  test('पिंड-अर्पण और दान की सामग्री वैकल्पिक है', () {
    final pindSamagri = shraadh.samagri.singleWhere(
      (s) => s.samuh == 'पिंड-अर्पण',
    );
    final daan = shraadh.samagri.singleWhere(
      (s) => s.vastu == 'दान या सहायता',
    );

    expect(pindSamagri.zaruri, isFalse);
    expect(daan.zaruri, isFalse);
    expect(charan('पिंडदान').vivaran, contains('वैकल्पिक'));
    expect(charan('पिंडदान').vaikalpik, isTrue);
    expect(shraadh.zaruriSamagri.length, 3);
    expect(shraadh.samayMinute - charan('पिंडदान').samayMinute, 79);
  });

  test('वैकल्पिक field का गलत type content guard रोकता है', () {
    final raw = File('assets/vidhi/shraadh.json').readAsStringSync();
    expect(
      () => Vidhi.parse('assets/vidhi/shraadh.json',
          raw.replaceFirst('"vaikalpik": true', '"vaikalpik": "हाँ"')),
      throwsA(isA<VidhiFormatException>()),
    );
  });

  test('2026 दिल्ली: पूर्णिमा अलग और कृष्ण पक्ष की 15 तिथियाँ', () {
    final dates = pitruSchedule(2026, Place.delhi);
    expect(dates, hasLength(16));
    expect(dates.first.rule.name, 'पूर्णिमा श्राद्ध');
    expect(dates.first.date, DateTime.utc(2026, 9, 26));
    expect(dates[1].date, DateTime.utc(2026, 9, 27));
    expect(dates.last.rule.name, 'सर्वपितृ अमावस्या');
    expect(dates.last.date, DateTime.utc(2026, 10, 10));
    // Delhi 2026 की पूरी 16-entry सूची: Drik Panchang में चतुर्थी और
    // पंचमी एक ही Gregorian दिन (30 सितम्बर) पर हैं।
    expect(
      dates.map((d) => '${d.date.month}-${d.date.day}').toList(),
      [
        '9-26',
        '9-27',
        '9-28',
        '9-29',
        '9-30',
        '9-30',
        '10-1',
        '10-2',
        '10-3',
        '10-4',
        '10-5',
        '10-6',
        '10-7',
        '10-8',
        '10-9',
        '10-10',
      ],
    );
  });

  test('2024–2030 में तिथि-क्रम शहर के हिसाब से पूरा है', () {
    const locations = [
      Place.delhi,
      Place(
          name: 'लंदन',
          latitude: 51.5072,
          longitude: -0.1276,
          timeZoneOffset: Duration(hours: 1)),
      Place(
          name: 'न्यूयॉर्क',
          latitude: 40.7128,
          longitude: -74.006,
          timeZoneOffset: Duration(hours: -4)),
    ];
    for (final place in locations) {
      for (var year = 2024; year <= 2030; year++) {
        final dates = pitruSchedule(year, place);
        expect(dates.length, 16, reason: '$year ${place.name}');
        for (var i = 1; i < dates.length; i++) {
          expect(dates[i].date.isBefore(dates[i - 1].date), isFalse,
              reason: '$year ${place.name} तिथि $i');
        }
      }
    }
  });

  test('मृत्यु क्षण से तिथि और local profile roundtrip', () {
    final at = DateTime(2026, 10, 10, 15, 30);
    final tithi = AncestorProfile.tithiAtDeath(at, Place.delhi);
    final profile = AncestorProfile(
      id: 'one',
      relation: 'दादी',
      name: '',
      tithi: tithi,
      source: 'calculated',
      deathLocal: at,
      placeName: Place.delhi.name,
      latitude: Place.delhi.latitude,
      longitude: Place.delhi.longitude,
      utcOffsetMinutes: 330,
      reminder: false,
      showNameOnLockScreen: false,
    );
    final restored = AncestorProfile.fromJson(profile.toJson());
    expect(restored.tithi, tithi);
    expect(restored.name, isEmpty);
    expect(restored.placeName, 'दिल्ली');
    expect(restored.nextDay(DateTime(2026, 9, 1)), isNotNull);
  });

  test('कई परिवार-प्रोफ़ाइल फ़ोन पर सहेजें और हटाएँ', () async {
    final first = AncestorProfile(
      id: 'a',
      relation: 'माता',
      name: 'स्मृति',
      tithi: 1,
      source: 'manual',
      deathLocal: null,
      placeName: Place.delhi.name,
      latitude: Place.delhi.latitude,
      longitude: Place.delhi.longitude,
      utcOffsetMinutes: 330,
      reminder: false,
      showNameOnLockScreen: false,
    );
    final second = AncestorProfile.fromJson({
      ...first.toJson(),
      'id': 'b',
      'relation': 'दादी',
      'name': '',
      'tithi': 0
    });
    await ancestorProfiles.load();
    await ancestorProfiles.save(first);
    await ancestorProfiles.save(second);
    await ancestorProfiles.load();
    expect(ancestorProfiles.items.map((p) => p.id), containsAll(['a', 'b']));
    await ancestorProfiles.delete('a');
    await ancestorProfiles.load();
    expect(ancestorProfiles.items.map((p) => p.id), ['b']);
  });

  test('त्योहार route generic व्रत की जगह श्राद्ध विधि खोलता है', () {
    final route = festivalDestination('पितृ पक्ष आरम्भ');
    expect(route, isA<VidhiScreen>());
    expect((route as VidhiScreen).id, 'shraadh');
    expect(festivalDestination('होलिका दहन'), isNull);
  });

  for (final event in [
    (DateTime(2026, 9, 27), 'पितृ पक्ष आरम्भ'),
    (DateTime(2026, 10, 10), 'सर्वपितृ अमावस्या'),
  ]) {
    testWidgets('आज ${event.$2} से सीधे श्राद्ध विधि खुलती है', (tester) async {
      await tester.pumpWidget(app(AajScreen(initialDay: event.$1)));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text(event.$2), 300);
      await tester.tap(find.text(event.$2));
      await tester.pumpAndSettle();
      expect(find.text('श्राद्ध और तर्पण'), findsWidgets);
      expect(find.text('पूजा शुरू करें'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('पिंडदान छोड़ा तो अगला चरण खुलता है', (tester) async {
    await tester.pumpWidget(app(VidhiPlayerScreen(
      vidhi: shraadh,
      initialStepIndex:
          shraadh.charan.indexWhere((c) => c.shirshak == 'पिंडदान'),
    )));
    await tester.pumpAndSettle();
    expect(find.text('पिंडदान'), findsWidgets);
    await tester.tap(find.byKey(const Key('skip_optional_step')));
    await tester.pumpAndSettle();
    expect(find.textContaining('पंचबलि'), findsWidgets);
  });

  testWidgets('320dp और बड़े अक्षरों पर तिथि सूची खुलती है', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app(const MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
      child: PitruScheduleScreen(year: 2026),
    )));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('पूर्णिमा श्राद्ध'), 250);
    expect(find.text('पूर्णिमा श्राद्ध'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('320dp पर निजी तिथि फ़ॉर्म बिना layout overflow खुले',
      (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app(const MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
      child: AncestorProfilesScreen(),
    )));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('परिजन की तिथि जोड़ें'), 200);
    await tester.pumpAndSettle();
    await tester.tap(find.text('परिजन की तिथि जोड़ें'));
    await tester.pumpAndSettle();
    expect(find.text('सम्बन्ध *'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // → D-133: पूर्वज की जगह भी वही खोज-पन्ना — शहर, गाँव, इंटरनेट
  // (गाँव वाली सूची isolate में खुलती है, widget-test में अटकती है — उसकी जाँच gaon_test में)
  testWidgets('मृत्यु की जगह: खोज-पन्ना खुलता है; «Delhi» से दिल्ली चुनी जाती है',
      (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app(const AncestorProfilesScreen()));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('परिजन की तिथि जोड़ें'), 200);
    await tester.pumpAndSettle();
    await tester.tap(find.text('परिजन की तिथि जोड़ें'));
    await tester.pumpAndSettle();

    final khaana = find.byKey(const Key('mrityu_sthan'));
    await tester.scrollUntilVisible(khaana, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(khaana);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('jagah_khoj')), findsOneWidget);
    // पूर्वज की जगह में «फ़ोन की अभी की जगह» नहीं — उसका यहाँ कोई मतलब नहीं
    expect(find.byKey(const Key('phone_ki_jagah')), findsNothing);
    await tester.enterText(find.byKey(const Key('jagah_khoj')), 'Delhi');
    await tester.pump(const Duration(seconds: 1)); // लिखना रुका — इंटरनेट-खोज (नक़ली)
    await tester.pumpAndSettle();

    // फ़ॉर्म का अपना खाना भी पहले से «दिल्ली» दिखाता है — पत्ता पन्ने के अंदर से
    await tester.tap(find
        .descendant(
            of: find.byType(JagahKhojSheet),
            matching: find.widgetWithText(ListTile, 'दिल्ली'))
        .first);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('jagah_khoj')), findsNothing);
    expect(
        find.descendant(
            of: khaana, matching: find.textContaining('बदलने के लिए दबाएँ')),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('सरल स्मरण में generic यजमान-संकल्प को deceased-person संकल्प नहीं कहा',
      () {
    final sankalp = charan('स्मरण का संकल्प');

    expect(sankalp.vishesh, CharanVishesh.saada);
    expect(sankalp.vivaran, contains('गोत्र मालूम न हो'));
    expect(shraadh.sankalpPurpose, isEmpty);
  });

  for (final shirshak in ['तर्पण', 'पिंडदान']) {
    testWidgets('$shirshak की सावधानी सिर्फ़ info button खोलने पर दिखती है',
        (tester) async {
      final mantra = charan(shirshak).mantra!;
      await tester.pumpWidget(app(
        Scaffold(
          body: SingleChildScrollView(child: MantraKhand(mantra: mantra)),
        ),
      ));

      expect(find.text(mantra.devanagari), findsOneWidget);
      expect(find.text(mantra.chetavni), findsNothing);
      expect(find.text('इस पाठ के बारे में · सावधानी'), findsOneWidget);

      final info = find.text('इस पाठ के बारे में · सावधानी');
      await tester.ensureVisible(info);
      await tester.pumpAndSettle();
      await tester.tap(info);
      await tester.pumpAndSettle();

      expect(find.text('सावधानी'), findsOneWidget);
      expect(find.text(mantra.chetavni), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('श्राद्ध पन्ने पर पूजा शुरू करने का रास्ता खुला है',
      (tester) async {
    await tester.pumpWidget(app(const VidhiScreen(id: 'shraadh')));
    await tester.pumpAndSettle();

    expect(find.text('पूजा शुरू करें'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('player से लौटने पर saved चरण तैयारी पन्ने में दिखता है',
      (tester) async {
    await tester.pumpWidget(app(const VidhiScreen(id: 'shraadh')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('पूजा शुरू करें'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('आगे बढ़ें'));
    await tester.pumpAndSettle();
    expect(settings.playerProgressFor('shraadh', 10)?.lastReachedStepIndex, 1);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('चरण 2 से जारी रखें'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('श्राद्ध में साधारण स्मरण आता है, generic मृतक-संकल्प नहीं',
      (tester) async {
    await tester.pumpWidget(app(const VidhiScreen(id: 'shraadh')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('पूजा शुरू करें'));
    await tester.pumpAndSettle();

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('आगे बढ़ें'));
      await tester.pumpAndSettle();
    }

    expect(find.text('चरण 4 / 10'), findsOneWidget);
    expect(find.text('स्मरण का संकल्प'), findsOneWidget);
    expect(find.textContaining('गोत्र मालूम न हो'), findsOneWidget);
    expect(find.text('पूरा संकल्प'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
