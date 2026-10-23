import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/dakshina_screen.dart';
import 'package:vidhivat/services/vinati_service.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/widgets/vinati_sheet.dart';

/// दक्षिणा की विनती — दस बार आने पर, कभी न देने वाले से (→ D-132, `docs/32`)।
void main() {
  final shuru = DateTime(2026, 10, 23, 9);
  late VinatiBahi b;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    b = VinatiBahi();
    await b.load();
  });

  /// [kitne] नई बैठकें, हर एक [har] के अंतर पर; आख़िरी बैठक का समय लौटाता है।
  Future<DateTime> aao(int kitne, {DateTime? se, Duration har = const Duration(hours: 20)}) async {
    var t = se ?? shuru;
    for (var i = 0; i < kitne; i++) {
      if (i > 0) t = t.add(har);
      await b.baithakShuru(t);
    }
    return t;
  }

  test('नौवीं बार तक नहीं; दसवीं पर — पर तभी जब सात दिन हो चुके हों', () async {
    var t = await aao(9);
    expect(b.dakshinaPoochhen(t, kabhiDiThi: false), isFalse);
    t = t.add(const Duration(hours: 20));
    await b.baithakShuru(t); // दसवाँ आना, ~7.5 दिन बाद
    expect(b.ginti, 10);
    expect(b.dakshinaPoochhen(t, kabhiDiThi: false), isTrue);
  });

  test('पहले ही दिन दस बार खोल लिया — तब नहीं, सात दिन बाद', () async {
    final t = await aao(10, har: const Duration(minutes: 40));
    expect(b.dakshinaPoochhen(t, kabhiDiThi: false), isFalse);
    final baad = shuru.add(const Duration(days: 7, hours: 1));
    await b.baithakShuru(baad);
    expect(b.dakshinaPoochhen(baad, kabhiDiThi: false), isTrue);
  });

  test('कभी भी दी हो — कभी नहीं', () async {
    final t = await aao(30);
    expect(b.dakshinaPoochhen(t, kabhiDiThi: true), isFalse);
  });

  test('एक बैठक में एक बार; «अभी नहीं» के बाद 20 आने बाद, फिर 40; कुल तीन', () async {
    var t = await aao(10);
    expect(b.dakshinaPoochhen(t, kabhiDiThi: false), isTrue);
    await b.dakshinaPoochhi(t);
    expect(b.dakshinaPoochhen(t, kabhiDiThi: false), isFalse, reason: 'वही बैठक');

    t = await aao(19, se: t.add(const Duration(hours: 20)));
    expect(b.ginti, 29);
    expect(b.dakshinaPoochhen(t, kabhiDiThi: false), isFalse);
    t = t.add(const Duration(hours: 20));
    await b.baithakShuru(t); // 30वाँ
    expect(b.dakshinaPoochhen(t, kabhiDiThi: false), isTrue);
    await b.dakshinaPoochhi(t);

    t = await aao(40, se: t.add(const Duration(hours: 20)));
    expect(b.ginti, 70);
    expect(b.dakshinaPoochhen(t, kabhiDiThi: false), isTrue);
    await b.dakshinaPoochhi(t);
    expect(b.kitniBaarPoochhi, 3);

    t = await aao(200, se: t.add(const Duration(hours: 20)));
    expect(b.dakshinaPoochhen(t, kabhiDiThi: false), isFalse, reason: 'तीन के बाद कभी नहीं');
  });

  test('दो विनतियों में कम से कम दो दिन', () async {
    var t = await aao(10);
    await b.dakshinaPoochhi(t);
    // अगले 20 आने एक ही दिन में
    t = await aao(20, se: t.add(const Duration(minutes: 40)), har: const Duration(minutes: 40));
    expect(b.dakshinaPoochhen(t, kabhiDiThi: false), isFalse);
    final baad = t.add(const Duration(days: 2));
    await b.baithakShuru(baad);
    expect(b.dakshinaPoochhen(baad, kabhiDiThi: false), isTrue);
  });

  test('notification दबाकर आई बैठक में नहीं — अगली बैठक में फिर', () async {
    final t = await aao(10);
    b.notificationSeAaya(t);
    expect(b.dakshinaPoochhen(t, kabhiDiThi: false), isFalse);
    final agli = t.add(const Duration(hours: 5));
    await b.baithakShuru(agli);
    expect(b.dakshinaPoochhen(agli, kabhiDiThi: false), isTrue);
  });

  test('पूजा-पूर्ण वाला डिब्बा इस बैठक में दिख चुका — तब पट्टी नहीं', () async {
    final t = await aao(10);
    b.dakshinaDibbaDikha();
    expect(b.dakshinaPoochhen(t, kabhiDiThi: false), isFalse);
  });

  test('आधे घंटे से कम पीछे रहकर लौटा — नई बैठक नहीं; ज़्यादा — नई', () async {
    final t = await aao(1);
    b.peechhe(t);
    await b.saamne(t.add(const Duration(minutes: 5)));
    expect(b.ginti, 1);
    b.peechhe(t.add(const Duration(minutes: 6)));
    await b.saamne(t.add(const Duration(minutes: 50)));
    expect(b.ginti, 2);
  });

  test('गिनती फ़ोन में बची रहती है — ऐप दोबारा खुलने पर भी', () async {
    final t = await aao(10);
    await b.dakshinaPoochhi(t);
    final naya = VinatiBahi();
    await naya.load();
    expect(naya.ginti, 10);
    expect(naya.kitniBaarPoochhi, 1);
  });

  testWidgets('पट्टी: शब्द, «अभी नहीं» से बंद, बटन से दक्षिणा का पन्ना', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: VidhivatTheme.dark(),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => dakshinaVinatiDikhao(context),
              child: const Text('खोलो'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('खोलो'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dakshina_vinati')), findsOneWidget);
    expect(find.text('विधिवत को दक्षिणा'), findsOneWidget);
    expect(find.text(VinatiShabd.baat), findsOneWidget);
    expect(find.textContaining('कोई पूजा या सुविधा बंद नहीं होती'), findsOneWidget);

    await tester.tap(find.byKey(const Key('vinati_abhi_nahi')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dakshina_vinati')), findsNothing);

    await tester.tap(find.text('खोलो'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('vinati_kholo')));
    await tester.pumpAndSettle();
    expect(find.byType(DakshinaScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('पट्टी पर पैसा नहीं, और वह सिर्फ़ लौटने पर उठती है — ऐप खुलते ही नहीं', () {
    final sheet = File('lib/widgets/vinati_sheet.dart').readAsStringSync();
    expect(sheet.contains('DakshinaChunav'), isFalse);
    expect(sheet.contains('dakshina.dena'), isFalse);

    final main = File('lib/main.dart').readAsStringSync();
    expect(main.contains('dakshinaVinatiDikhao'), isTrue);
    final lautna = main.indexOf('void didPopNext()');
    expect(lautna, greaterThan(0));
    expect(main.indexOf('dakshinaVinatiDikhao'), greaterThan(lautna),
        reason: 'पट्टी सिर्फ़ didPopNext (किसी पन्ने से लौटने) से');
    expect('dakshinaVinatiDikhao'.allMatches(main).length, 1);
  });
}
