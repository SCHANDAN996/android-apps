import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/paath_list_screen.dart';
import 'package:vidhivat/screens/paath_screen.dart';
import 'package:vidhivat/screens/saptashati_screen.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/widgets/design_system.dart';

/// दुर्गा सप्तशती का पन्ना — उँगली चलाकर (→ D-084)।
void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await settings.load();
  });

  Widget app(Widget home) =>
      MaterialApp(theme: VidhivatTheme.dark(), home: home);

  void phone(WidgetTester tester) {
    tester.view.physicalSize = const Size(360 * 3, 6000 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('पूरा क्रम दिखता है — अंग और तेरहों अध्याय', (tester) async {
    phone(tester);
    await tester.pumpWidget(app(const SaptashatiScreen()));
    await tester.pumpAndSettle();

    expect(find.text('पाठ से पहले'), findsOneWidget);
    expect(find.text('उत्तम चरित्र — महासरस्वती'), findsOneWidget);
    expect(find.text('देवी कवच'), findsOneWidget);
    expect(find.text('अध्याय १ — मधु-कैटभ वध'), findsOneWidget);
    expect(find.text('अध्याय १३ — सुरथ और वैश्य को वरदान'), findsOneWidget);
    // पहली बार — "पिछली बार" वाला कार्ड नहीं
    expect(find.text('पिछली बार यह पाठ खोला था'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('अध्याय में numbered पिछला/अगला navigation चलता है',
      (tester) async {
    phone(tester);
    await tester.pumpWidget(app(const SaptashatiScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('अध्याय ३ — महिषासुर वध'));
    await tester.pumpAndSettle();
    expect(find.byType(PaathScreen), findsOneWidget);
    expect(find.text('सप्तशती · पाठ 7/22'), findsOneWidget);
    expect(find.textContaining('पाठ 1/'), findsOneWidget);
    expect(find.text('पिछला'), findsOneWidget);
    expect(find.text('अगला'), findsOneWidget);
    // हर श्लोक का अर्थ है — बटन दबाने पर पहले श्लोक का अर्थ दिखता है
    await tester.scrollUntilVisible(
      find.text('अर्थ दिखाएँ'),
      500,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('अर्थ दिखाएँ'));
    await tester.pumpAndSettle();
    expect(find.textContaining('चिक्षुर क्रोध से भरकर'), findsOneWidget);

    await tester.tap(find.text('अगला'));
    await tester.pumpAndSettle();
    expect(find.text('अध्याय ४ — इन्द्र आदि देवताओं की स्तुति'), findsWidgets);
    expect(find.text('सप्तशती · पाठ 8/22'), findsOneWidget);

    await tester.tap(find.text('पिछला'));
    await tester.pumpAndSettle();
    expect(find.text('अध्याय ३ — महिषासुर वध'), findsWidgets);

    // Screen back — सीधे सूची पर, और वहीं पिछला खोला हुआ chapter दिखता है।
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(SaptashatiScreen), findsOneWidget);
    expect(find.text('पिछली बार यह पाठ खोला था'), findsOneWidget);
    expect(find.text('वहीं से पढ़ें'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('देवी कवच खोलते ही ऊपर नवदुर्गा के नौ नाम दिखते हैं',
      (tester) async {
    phone(tester);
    await tester.pumpWidget(app(const SaptashatiScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('देवी कवच'));
    await tester.pumpAndSettle();

    expect(find.text('नवदुर्गा के नौ नाम'), findsOneWidget);
    expect(find.textContaining('शैलपुत्री · ब्रह्मचारिणी · चन्द्रघण्टा'),
        findsOneWidget);
    expect(find.textContaining('महागौरी · सिद्धिदात्री'), findsOneWidget);
    expect(find.text('देवी कवच · श्लोक ३–५'), findsOneWidget);
  });

  testWidgets('आख़िरी पाठ (क्षमा प्रार्थना) पर अगला button disabled है',
      (tester) async {
    phone(tester);
    await tester.pumpWidget(app(const SaptashatiScreen()));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('क्षमा प्रार्थना'), 400,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('क्षमा प्रार्थना'));
    await tester.pumpAndSettle();
    expect(find.text('सप्तशती · पाठ 22/22'), findsOneWidget);
    final agla = tester.widget<VidhivatButton>(
      find.widgetWithText(VidhivatButton, 'अगला'),
    );
    expect(agla.onPressed, isNull);
  });

  testWidgets('सप्तशती chapter का आख़िरी पहुँचा पाठ local marker में दिखता है',
      (tester) async {
    SharedPreferences.setMockInitialValues(
      {'saptashati_aakhri_khand_saptashati_03': 3},
    );
    phone(tester);
    await tester.pumpWidget(app(const SaptashatiScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('अध्याय ३ — महिषासुर वध'));
    await tester.pumpAndSettle();

    expect(find.textContaining('पाठ 4/'), findsOneWidget);
    expect(find.textContaining('जहाँ तक पहुँचे'), findsOneWidget);
  });

  // ऊपर वाली जाँचें 6000dp ऊँची स्क्रीन पर चलती हैं, जहाँ पूरा अध्याय एक
  // साथ बन जाता है। असली फ़ोन पर ListView सिर्फ़ दिखने वाले पाठ बनाता है —
  // दूर का पाठ बना ही नहीं होता, इसलिए "जहाँ छोड़ा वहीं से" चुपचाप ऊपर ही
  // रह जाता था। यह जाँच आम फ़ोन की ऊँचाई पर है।
  testWidgets('आम फ़ोन पर भी दूर का आख़िरी पाठ वहीं खुलता है', (tester) async {
    SharedPreferences.setMockInitialValues(
      {'saptashati_aakhri_khand_saptashati_03': 40},
    );
    tester.view.physicalSize = const Size(360 * 3, 740 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(app(const PaathScreen(
      id: 'saptashati_03',
      granth: GranthNavigation(
        granthId: 'saptashati',
        granthNaam: 'सप्तशती',
        ikai: 'पाठ',
        khandIkai: 'पाठ',
        paathId: 'saptashati_03',
        kram: 5,
        kul: 16,
        pichhlaNaam: null,
        aglaNaam: null,
        pichhlaKholo: null,
        aglaKholo: null,
      ),
    )));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 400));

    final scroll = tester.state<ScrollableState>(find
        .descendant(
            of: find.byType(PaathReader), matching: find.byType(Scrollable))
        .first);
    expect(scroll.position.pixels, greaterThan(3000));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('saptashati_aakhri_khand_saptashati_03'),
        greaterThanOrEqualTo(38));
  });

  testWidgets('पढ़ते हुए scroll करने पर आख़िरी पहुँचा पाठ local save होता है',
      (tester) async {
    phone(tester);
    await tester.pumpWidget(app(const SaptashatiScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('अध्याय ३ — महिषासुर वध'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('श्लोक १०'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 400));

    final prefs = await SharedPreferences.getInstance();
    expect(
        prefs.getInt('saptashati_aakhri_khand_saptashati_03'), greaterThan(0));
  });

  testWidgets('320dp और 1.5x अक्षर पर pinned chapter navigator सुरक्षित है',
      (tester) async {
    tester.view.physicalSize = const Size(320 * 3, 800 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: VidhivatTheme.dark(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1.5)),
        child: child!,
      ),
      home: const SaptashatiScreen(),
    ));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('अध्याय ३ — महिषासुर वध'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('अध्याय ३ — महिषासुर वध').hitTestable(), findsOneWidget);
    await tester.tap(find.text('अध्याय ३ — महिषासुर वध'));
    await tester.pumpAndSettle();

    expect(find.text('पिछला'), findsOneWidget);
    expect(find.text('अगला'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('पिछली बार वाला अध्याय फ़ोन में याद रहता है', (tester) async {
    SharedPreferences.setMockInitialValues(
        {SaptashatiScreen.pichhlaKey: 'saptashati_07'});
    phone(tester);
    await tester.pumpWidget(app(const SaptashatiScreen()));
    await tester.pumpAndSettle();
    expect(find.text('पिछली बार यह पाठ खोला था'), findsOneWidget);
    expect(find.text('अध्याय ७ — चण्ड-मुण्ड वध'), findsNWidgets(2));
  });

  testWidgets('"चालीसा और आरती" की सूची में सप्तशती एक ही पंक्ति',
      (tester) async {
    phone(tester);
    await tester.pumpWidget(app(const PaathListScreen()));
    await tester.pumpAndSettle();
    expect(find.text('दुर्गा सप्तशती'), findsOneWidget);
    // सोलह अध्याय अलग-अलग सूची में नहीं भरे
    expect(find.textContaining('अध्याय १ —'), findsNothing);
    await tester.tap(find.text('दुर्गा सप्तशती'));
    await tester.pumpAndSettle();
    expect(find.byType(SaptashatiScreen), findsOneWidget);
  });
}
