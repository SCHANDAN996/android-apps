import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/main.dart';
import 'package:vidhivat/screens/puja_completion_screen.dart';
import 'package:vidhivat/screens/sankalp_screen.dart';
import 'package:vidhivat/screens/vidhi_list_screen.dart';
import 'package:vidhivat/screens/vidhi_player_screen.dart';
import 'package:vidhivat/screens/vidhi_screen.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/vidhi/bhandar.dart';
import 'package:vidhivat/vidhi/planned_puja_catalog.dart';
import 'package:vidhivat/widgets/design_system.dart';

/// विधि वाली स्क्रीनों की जाँच — **उँगली चलाकर।**
///
/// ## यह जाँच क्यों लिखी गई
///
/// पिछली बार "संकल्प बनाइए" वाला बटन नाम भरने पर भी बंद रहता था।
/// `flutter analyze` साफ़ था, 157 जाँचें पास थीं, और फिर भी कोई यूज़र
/// संकल्प बना ही नहीं पाता। वो बग सिर्फ़ **असली फ़ोन पर** मिला।
///
/// widget जाँच उसी बीच की जगह भरती है — यह सचमुच widget बनाती है, टैप
/// करती है, लिखती है, और देखती है कि हालत बदली या नहीं। वही बग यहाँ
/// पकड़ा जाता (नीचे आख़िरी group देखो)।
///
/// ⚠️ **फिर भी यह फ़ोन की जगह नहीं ले सकती।** देवनागरी का रेंडर, असली
/// नाप, और उँगली की पहुँच — वो सिर्फ़ फ़ोन पर दिखता है।
void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await settings.load();
  });

  Widget app(Widget home, {TextScaler? textScaler}) => MaterialApp(
        // Production defaults to the premium dark theme; responsive checks
        // should exercise the same visual environment.
        theme: VidhivatTheme.dark(),
        builder: (context, child) => textScaler == null
            ? child!
            : MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: textScaler),
                child: child!,
              ),
        home: home,
      );

  /// जाँच की स्क्रीन को असली फ़ोन के नाप पर ले आओ।
  ///
  /// डिफ़ॉल्ट 800×600 है — वो किसी फ़ोन जैसा नहीं। vivo V2553 (जिस पर
  /// ऐप जाँचा जाता है) 1080×2400 का है, यानी 360×800 dp। इसी नाप पर
  /// जाँचने से "बटन तह के नीचे चला गया" जैसी बातें यहीं पकड़ में आती हैं।
  void phoneNaap(
    WidgetTester tester, {
    double width = 360,
    double height = 800,
  }) {
    tester.view.physicalSize = Size(width * 3, height * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  /// किसी चीज़ तक स्क्रॉल करो — जैसे यूज़र उँगली से करता है।
  ///
  /// ⚠️ विधि प्लेयर में **दो** scrollable होते हैं — बाहर का `PageView`
  /// (जो बग़ल में चलता है) और हर पन्ने के अंदर वाली सूची (जो ऊपर-नीचे)।
  /// `find.byType(Scrollable).first` बाहर वाला पकड़ लेता है और ऊपर-नीचे
  /// स्क्रॉल करने पर कुछ होता ही नहीं। इसलिए यहाँ साफ़-साफ़ `ListView`
  /// के अंदर वाला चुना जाता है।
  Future<void> scrollTak(WidgetTester tester, Finder tak) async {
    await tester.scrollUntilVisible(
      tak,
      160,
      scrollable: find
          .descendant(
              of: find.byType(ListView), matching: find.byType(Scrollable))
          .first,
    );
    await tester.pumpAndSettle();
  }

  Future<void> expectPreparationFits(
    WidgetTester tester, {
    required double width,
    required TextScaler textScaler,
  }) async {
    phoneNaap(tester, width: width);
    await tester.pumpWidget(app(
      const VidhiScreen(id: 'satyanarayan'),
      textScaler: textScaler,
    ));
    await tester.pumpAndSettle();

    await scrollTak(tester, find.text('यह विधि कहाँ से आई'));
    expect(find.text('यह विधि कहाँ से आई'), findsOneWidget);
    await tester.tap(find.text('पूजा की तैयारी करें'));
    await tester.pumpAndSettle();
    expect(find.text('सत्यनारायण पूजा की सामग्री'), findsOneWidget);
    expect(tester.takeException(), isNull);
  }

  Future<void> expectVidhiHomeFits(
    WidgetTester tester,
    double width,
  ) async {
    phoneNaap(tester, width: width);
    await tester.pumpWidget(app(const VidhiListScreen()));
    await tester.pumpAndSettle();

    expect(find.text('आज क्या करना चाहते हैं?'), findsOneWidget);
    await scrollTak(tester, find.text('त्योहार'));
    expect(find.text('त्योहार'), findsOneWidget);
    await scrollTak(tester, find.text('विशेष पूजा और संस्कार'));
    expect(tester.takeException(), isNull, reason: '${width}dp पर overflow');
  }

  /// सूची से सत्यनारायण खोलो।
  Future<void> kholoSatyanarayan(WidgetTester tester) async {
    phoneNaap(tester);
    await tester.pumpWidget(app(const VidhiListScreen()));
    await tester.pumpAndSettle();
    await scrollTak(tester, find.text('त्योहार'));
    await tester.tap(find.text('सत्यनारायण पूजा'));
    await tester.pumpAndSettle();
  }

  group('होम पर "आगे क्या आ रहा है"', () {
    // पूरी सूची पंचांग से बनती है — कोई तारीख़ हाथ से नहीं भरी (→ D-038)।
    // गणित की अपनी जाँचें `aane_wale_din_test.dart` में हैं; यहाँ सिर्फ़
    // यह देखना है कि वो होम पर सही दिख रही है और दबने पर खुलती है।

    testWidgets('हिस्सा दिखता है और पंक्तियाँ क्रम में हैं', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const HomeShell()));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.text('आगे क्या आ रहा है'));
      expect(find.text('आगे क्या आ रहा है'), findsOneWidget);
      expect(find.text('तारीख़ें पंचांग से, आपके शहर के हिसाब से'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('जो पूजा खुल सकती है वो दबाने पर खुलती है', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const HomeShell()));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.text('आगे क्या आ रहा है'));

      // सूची में जो पहली पंक्ति खुल सकती है, उसे दबाओ।
      final khulneWali = find.descendant(
        of: find.byType(InkWell),
        matching: find.byIcon(Icons.chevron_right),
      );
      expect(khulneWali, findsWidgets,
          reason: 'कम से कम एक आने वाली पूजा खुलनी चाहिए');

      await tester.tap(khulneWali.first);
      await tester.pumpAndSettle();
      expect(find.byType(VidhiScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('320 dp और 1.5x अक्षर पर भी सुरक्षित है', (tester) async {
      phoneNaap(tester, width: 320);
      await tester.pumpWidget(app(
        const HomeShell(),
        textScaler: const TextScaler.linear(1.5),
      ));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.text('आगे क्या आ रहा है'));
      expect(tester.takeException(), isNull, reason: '320dp/1.5x पर overflow');
    });
  });

  group('वो बग जो सिर्फ़ फ़ोन के logcat में दिखा', () {
    // 26 अगस्त 2026: पहली बार ऐप खोलने पर शहर पूछने वाला dialog
    // `showDialog(context: context)` से खुलता था, जहाँ context
    // `_VidhivatAppState` का था — यानी MaterialApp के *ऊपर*। वहाँ
    // MaterialLocalizations होती ही नहीं।
    //
    // असर: हर launch पर unhandled exception, dialog कभी नहीं दिखा, और
    // "पूछ लिया" वाला निशान भी कभी नहीं लगा — यानी नया यूज़र दिल्ली पर
    // ही अटका रहता।
    //
    // `flutter analyze` साफ़ था और सारी जाँचें पास थीं। यह सिर्फ़ असली
    // फ़ोन के logcat में दिखा।

    testWidgets('पहली बार खुलने पर शहर वाला dialog बिना exception दिखता है',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      await settings.load();
      expect(settings.locationPermissionPromptSeen, isFalse);

      phoneNaap(tester);
      await tester.pumpWidget(const VidhivatApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull,
          reason: 'dialog MaterialApp के नीचे से खुलना चाहिए');
      expect(find.text('अपना स्थान पहचानने दें?'), findsOneWidget);
    });

    testWidgets('"अभी नहीं" दबाने पर निशान लगता है और दोबारा नहीं पूछता',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      await settings.load();

      phoneNaap(tester);
      await tester.pumpWidget(const VidhivatApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('अभी नहीं'));
      await tester.pumpAndSettle();

      expect(find.text('अपना स्थान पहचानने दें?'), findsNothing);
      expect(settings.locationPermissionPromptSeen, isTrue,
          reason: 'वरना हर बार ऐप खुलने पर दोबारा पूछेगा');
      expect(tester.takeException(), isNull);
    });

    testWidgets('निशान लग चुका हो तो dialog नहीं खुलता', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await settings.load();
      await settings.markLocationPermissionPromptSeen();

      phoneNaap(tester);
      await tester.pumpWidget(const VidhivatApp());
      await tester.pumpAndSettle();

      expect(find.text('अपना स्थान पहचानने दें?'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('नीचे की पट्टी — चार मुख्य पन्ने', () {
    testWidgets('चारों पन्ने हैं और होम सबसे पहले है', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const HomeShell()));
      await tester.pumpAndSettle();

      final patti = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(patti.destinations, hasLength(4));
      expect(patti.selectedIndex, 0);

      for (final naam in ['होम', 'पूजा', 'कैलेंडर', 'अधिक']) {
        expect(find.text(naam), findsWidgets, reason: '"$naam" पट्टी में नहीं');
      }
    });

    testWidgets('dashboard सबसे पहले खुलता है और मुख्य रास्ते दिखाता है',
        (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const HomeShell()));
      await tester.pumpAndSettle();

      expect(find.text('जय श्री गणेश 🙏'), findsOneWidget);
      expect(find.text('नित्य पूजा'), findsOneWidget);
      await scrollTak(tester, find.text('जल्दी करें'));
      expect(find.text('जल्दी करें'), findsOneWidget);
    });

    testWidgets('320 dp पर चारों navigation labels सुरक्षित हैं',
        (tester) async {
      phoneNaap(tester, width: 320);
      await tester.pumpWidget(app(const HomeShell()));
      await tester.pumpAndSettle();

      for (final naam in ['होम', 'पूजा', 'कैलेंडर', 'अधिक']) {
        expect(find.text(naam), findsWidgets);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('अधिक से पुराने सहायक साधन और सेटिंग उपलब्ध हैं',
        (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const HomeShell()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('अधिक').last);
      await tester.pumpAndSettle();
      expect(find.text('संकल्प'), findsOneWidget);
      expect(find.text('चौघड़िया और होरा'), findsOneWidget);
      expect(find.text('आज का पूरा पंचांग'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('सेटिंग'),
        160,
        scrollable: find.byType(Scrollable).hitTestable().first,
      );
      expect(find.text('सेटिंग'), findsOneWidget);
    });

    testWidgets('Home quick action से संकल्प खुलता है', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const HomeShell()));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.text('संकल्प'));
      await tester.tap(find.text('संकल्प').hitTestable().first);
      await tester.pumpAndSettle();
      expect(find.byType(SankalpScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('saved app position होने पर Home जारी रखने का रास्ता दिखाता है',
        (tester) async {
      final nitya = await vidhiBhandar.vidhi('nitya_pooja');
      await settings.recordLastReachedStep(
        pujaId: nitya.id,
        stepIndex: 2,
        totalSteps: nitya.charan.length,
      );
      phoneNaap(tester);
      await tester.pumpWidget(app(const HomeShell()));
      await tester.pumpAndSettle();

      expect(find.text('जहाँ छोड़ा था'), findsOneWidget);
      expect(find.text('पूजा जारी रखें'), findsOneWidget);
      expect(find.text('चरण 3'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('320 dp और 1.5x अक्षर में dashboard सुरक्षित है',
        (tester) async {
      phoneNaap(tester, width: 320);
      await tester.pumpWidget(app(
        const HomeShell(),
        textScaler: const TextScaler.linear(1.5),
      ));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.text('लोकप्रिय पूजा'));
      expect(find.text('लोकप्रिय पूजा'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('पूजाओं की सूची', () {
    testWidgets('सूची खुलती है और तैयार पूजा दिखती है', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const VidhiListScreen()));
      await tester.pumpAndSettle();

      expect(find.text('आज क्या करना चाहते हैं?'), findsOneWidget);
      await scrollTak(tester, find.text('त्योहार'));
      expect(find.text('सत्यनारायण पूजा'), findsOneWidget);
    });

    testWidgets('नई खोज-परतें बिना overflow के दिखती हैं', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const VidhiListScreen()));
      await tester.pumpAndSettle();

      expect(find.text('दैनिक पूजा'), findsOneWidget);
      await scrollTak(tester, find.text('त्योहार'));
      expect(find.text('त्योहार'), findsOneWidget);
      await scrollTak(tester, find.text('विशेष पूजा और संस्कार'));
      expect(find.text('विशेष पूजा और संस्कार'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('320 dp पर खोज-परतें सुरक्षित रहती हैं',
        (tester) => expectVidhiHomeFits(tester, 320));

    testWidgets('360 dp पर खोज-परतें सुरक्षित रहती हैं',
        (tester) => expectVidhiHomeFits(tester, 360));

    testWidgets('393 dp पर खोज-परतें सुरक्षित रहती हैं',
        (tester) => expectVidhiHomeFits(tester, 393));

    testWidgets('412 dp पर खोज-परतें सुरक्षित रहती हैं',
        (tester) => expectVidhiHomeFits(tester, 412));

    testWidgets('1.5x अक्षर आकार में पूजा grid और featured CTA सुरक्षित हैं',
        (tester) async {
      phoneNaap(tester, width: 320);
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(app(
        const VidhiListScreen(),
        textScaler: const TextScaler.linear(1.5),
      ));
      await tester.pumpAndSettle();

      final ctaSemantics = tester.getSemantics(find.byType(VidhivatButton));
      expect(ctaSemantics.label, contains('नित्य पूजा की विधि देखें'));
      expect(ctaSemantics.flagsCollection.isButton, isTrue);
      await scrollTak(tester, find.text('त्योहार'));
      expect(find.text('सत्यनारायण पूजा'), findsOneWidget);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    });

    test('आने वाली पूजाओं में वो नहीं जो बन चुकी हैं', () async {
      // Phase A की छह पूजाएँ अब असली विधि हैं, इसलिए वे planned सूची
      // से हट चुकी हैं — वरना एक ही नाम दो जगह दिखता।
      expect(plannedPujaCount, 18);
      expect(
        plannedPujaSections.map((section) => section.title),
        containsAll([
          'त्योहार संग्रह',
          'व्रत और क्षेत्रीय परंपराएँ',
          'विशेषज्ञ सहायता वाली विधियाँ',
        ]),
      );

      final plannedIds = plannedPujaSections
          .expand((section) => section.entries)
          .map((entry) => entry.id)
          .toList(growable: false);
      expect(plannedIds.toSet(), hasLength(18));
      expect(plannedIds, contains('purna_havan'));

      // यही असली रखवाली है — एक भी id दोनों जगह न हो।
      final banChukiIds =
          (await vidhiBhandar.suchi()).map((e) => e.id).toSet();
      expect(banChukiIds.intersection(plannedIds.toSet()), isEmpty,
          reason: 'यह पूजा सूची में भी है और "जल्द आएगी" में भी');
    });

    testWidgets('मौजूदा पूजा खुलती है और आने वाली पूजा बंद रहती है',
        (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const VidhiListScreen()));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.text('गणेश पूजन'));
      await tester.tap(find.text('गणेश पूजन'));
      await tester.pumpAndSettle();
      expect(find.text('पूजा की तैयारी करें'), findsOneWidget);

      Navigator.of(tester.element(find.byType(VidhiScreen))).pop();
      await tester.pumpAndSettle();

      // हनुमान पूजा अब असली विधि है — खुलनी चाहिए।
      await scrollTak(tester, find.text('हनुमान पूजा'));
      await tester.tap(find.text('हनुमान पूजा'));
      await tester.pumpAndSettle();
      expect(find.text('पूजा की तैयारी करें'), findsOneWidget);
      Navigator.of(tester.element(find.byType(VidhiScreen))).pop();
      await tester.pumpAndSettle();

      // जो अब भी सिर्फ़ नाम है वो दबनी नहीं चाहिए।
      await scrollTak(tester, find.text('त्योहार संग्रह'));
      expect(find.text('जल्द आएगी'), findsWidgets);
      await tester.tap(find.text('धनतेरस पूजा'));
      await tester.pumpAndSettle();
      expect(find.byType(VidhiListScreen), findsOneWidget);
      expect(find.byType(VidhiScreen), findsNothing);
    });

    testWidgets('320 dp पर सभी planned sections बिना overflow दिखते हैं',
        (tester) async {
      phoneNaap(tester, width: 320);
      await tester.pumpWidget(app(const VidhiListScreen()));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.text('त्योहार संग्रह'));
      expect(find.text('त्योहार संग्रह'), findsOneWidget);
      await scrollTak(tester, find.text('व्रत और क्षेत्रीय परंपराएँ'));
      expect(find.text('व्रत और क्षेत्रीय परंपराएँ'), findsOneWidget);
      await scrollTak(tester, find.text('विशेषज्ञ सहायता वाली विधियाँ'));
      expect(find.text('पूर्ण हवन'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('चार-tab navigation में चयन सुरक्षित रहता है', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const HomeShell()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('पूजा').last);
      await tester.pumpAndSettle();

      final patti = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(patti.selectedIndex, 1);
    });

    testWidgets('कोई भी पूजा अभी पंडित जी से पास नहीं दिखती', (tester) async {
      // यह गिनती ही असली हालत है — कितनी लिखी गईं वो नहीं (→ D-022)।
      phoneNaap(tester);
      await tester.pumpWidget(app(const VidhiListScreen()));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.textContaining('पंडित जी से जाँची गई हैं'));
      expect(
        find.textContaining('पंडित जी से जाँची गई हैं'),
        findsOneWidget,
      );
    });
  });

  group('पूजा का विवरण', () {
    testWidgets('विवरण खुलता है और ज़रूरी बातें दिखती हैं', (tester) async {
      await kholoSatyanarayan(tester);

      // तैयारी और सीधे विधि शुरू करने के actions हमेशा उपलब्ध हैं।
      expect(find.text('पूजा की तैयारी करें'), findsOneWidget);
      expect(find.text('अभी विधि शुरू करें'), findsOneWidget);
      await scrollTak(tester, find.text('14 चरण'));
      expect(find.text('14 चरण'), findsOneWidget);
      expect(find.text('34 ज़रूरी सामग्री'), findsOneWidget);

      // 360×800 dp पर पहली तह में सिर्फ़ परिचय और पहली चेतावनी आती है —
      // बाक़ी के लिए यूज़र को स्क्रॉल करना पड़ता है, इसलिए जाँच भी करती है।
      await scrollTak(tester, find.text('कब करें'));
      expect(find.text('कब करें'), findsOneWidget);

      await scrollTak(tester, find.text('विधि'));
      expect(find.text('विधि'), findsWidgets);

      await scrollTak(tester, find.text('यह विधि कहाँ से आई'));
      expect(find.text('यह विधि कहाँ से आई'), findsOneWidget);
    });

    testWidgets('पंडित जी से पास न होने की चेतावनी दिखती है', (tester) async {
      // यह चुपचाप ग़ायब नहीं होनी चाहिए — पूरा भरोसा इसी पर टिका है।
      await kholoSatyanarayan(tester);
      await scrollTak(tester, find.text('जाँच बाकी है'));
      expect(
        find.textContaining('पंडित जी से जाँच करवाकर पास नहीं'),
        findsOneWidget,
      );
    });

    testWidgets('अधूरे मंत्रों की गिनती साफ़ लिखी है', (tester) async {
      await kholoSatyanarayan(tester);
      await scrollTak(
          tester, find.textContaining('मंत्रों का पाठ अभी ऐप में जोड़ा नहीं'));
      expect(find.textContaining('मंत्रों का पाठ अभी ऐप में जोड़ा नहीं'),
          findsOneWidget);
    });
  });

  group('सामग्री की सूची', () {
    testWidgets('टिक लगाने पर गिनती बढ़ती है और फ़ोन में याद रहती है',
        (tester) async {
      await kholoSatyanarayan(tester);
      await tester.tap(find.text('पूजा की तैयारी करें'));
      await tester.pumpAndSettle();

      expect(find.textContaining('जुट गईं'), findsOneWidget);
      expect(settings.samagriTicks('satyanarayan'), isEmpty);

      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();

      expect(settings.samagriTicks('satyanarayan'), hasLength(1));
      expect(find.text('1 / 44 जुट गईं'), findsOneWidget);
      expect(
        tester.widget<Checkbox>(find.byType(Checkbox).first).value,
        isTrue,
      );
    });

    testWidgets('"सिर्फ़ ज़रूरी" से वैकल्पिक चीज़ें छँट जाती हैं',
        (tester) async {
      await kholoSatyanarayan(tester);
      await tester.tap(find.text('पूजा की तैयारी करें'));
      await tester.pumpAndSettle();

      // "वैकल्पिक" अक्सर note के साथ एक ही लाइन में जुड़ जाता है
      // ("वैकल्पिक · मंडप बनाने के लिए"), इसलिए textContaining।
      expect(find.textContaining('वैकल्पिक'), findsWidgets);

      await tester.tap(find.text('सिर्फ़ ज़रूरी'));
      await tester.pumpAndSettle();

      expect(find.textContaining('वैकल्पिक'), findsNothing);
    });

    testWidgets('सारी टिक हटाने वाला बटन सचमुच हटाता है', (tester) async {
      await kholoSatyanarayan(tester);
      await tester.tap(find.text('पूजा की तैयारी करें'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();
      expect(settings.samagriTicks('satyanarayan'), hasLength(1));

      await tester.tap(find.byIcon(Icons.restart_alt));
      await tester.pumpAndSettle();
      expect(settings.samagriTicks('satyanarayan'), isEmpty);
    });

    testWidgets('बिना कोई टिक लगाए भी पूजा शुरू की जा सकती है', (tester) async {
      await kholoSatyanarayan(tester);
      await tester.tap(find.text('पूजा की तैयारी करें'));
      await tester.pumpAndSettle();

      expect(settings.samagriTicks('satyanarayan'), isEmpty);
      await tester.tap(find.text('पूजा शुरू करें'));
      await tester.pumpAndSettle();
      expect(find.text('चरण 1 / 14'), findsOneWidget);
    });

    testWidgets('सामग्री से back करने पर वही पूजा detail खुलता है',
        (tester) async {
      await kholoSatyanarayan(tester);
      await tester.tap(find.text('पूजा की तैयारी करें'));
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('सत्यनारायण पूजा'), findsOneWidget);
      expect(find.text('पूजा की तैयारी करें'), findsOneWidget);
    });

    testWidgets('320 dp और 1.5x अक्षर आकार पर तैयारी सुरक्षित है',
        (tester) async {
      phoneNaap(tester, width: 320);
      await tester.pumpWidget(app(
        const VidhiScreen(id: 'satyanarayan'),
        textScaler: const TextScaler.linear(1.5),
      ));
      await tester.pumpAndSettle();

      expect(find.text('सत्यनारायण पूजा'), findsOneWidget);
      expect(find.text('पूजा की तैयारी करें'), findsOneWidget);
      await tester.tap(find.text('पूजा की तैयारी करें'));
      await tester.pumpAndSettle();
      expect(find.text('सत्यनारायण पूजा की सामग्री'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        '360 dp और 1.3x अक्षर आकार पर तैयारी सुरक्षित है',
        (tester) => expectPreparationFits(
              tester,
              width: 360,
              textScaler: const TextScaler.linear(1.3),
            ));

    testWidgets(
        '393 dp और 1.0x अक्षर आकार पर तैयारी सुरक्षित है',
        (tester) => expectPreparationFits(
              tester,
              width: 393,
              textScaler: const TextScaler.linear(1),
            ));

    testWidgets(
        '412 dp और 1.0x अक्षर आकार पर तैयारी सुरक्षित है',
        (tester) => expectPreparationFits(
              tester,
              width: 412,
              textScaler: const TextScaler.linear(1),
            ));
  });

  group('विधि प्लेयर', () {
    void expectStepProgress(WidgetTester tester, int current, int total) {
      final progress = tester
          .widgetList<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .map((indicator) => indicator.value)
          .toList(growable: false);
      expect(progress, isNotEmpty);
      for (final value in progress) {
        expect(value, closeTo(current / total, 0.00001));
      }
    }

    Future<void> kholoPlayer(WidgetTester tester) async {
      await kholoSatyanarayan(tester);
      await tester.tap(find.text('अभी विधि शुरू करें'));
      await tester.pumpAndSettle();
    }

    Future<void> expectPlayerFits(
      WidgetTester tester, {
      required double width,
      required TextScaler textScaler,
    }) async {
      phoneNaap(tester, width: width);
      await tester.pumpWidget(app(
        const VidhiScreen(id: 'satyanarayan'),
        textScaler: textScaler,
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('अभी विधि शुरू करें'));
      await tester.pumpAndSettle();

      expect(find.text('चरण 1 / 14'), findsOneWidget);
      expectStepProgress(tester, 1, 14);
      expect(tester.takeException(), isNull, reason: '${width}dp पर overflow');
    }

    Future<void> expectOverviewFits(
      WidgetTester tester, {
      required double width,
      required TextScaler textScaler,
    }) async {
      phoneNaap(tester, width: width);
      await tester.pumpWidget(app(
        const VidhiScreen(id: 'satyanarayan'),
        textScaler: textScaler,
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('अभी विधि शुरू करें'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('चरणों की सूची'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('प्रसाद वितरण'),
        160,
        scrollable: find.descendant(
          of: find.byKey(const Key('charan_overview_list')),
          matching: find.byType(Scrollable),
        ),
      );

      expect(find.text('प्रसाद वितरण'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: '${width}dp पर overflow');
    }

    testWidgets('पहला कदम खुलता है और गिनती सही दिखती है', (tester) async {
      await kholoPlayer(tester);

      expect(find.text('चरण 1 / 14'), findsOneWidget);
      expect(find.text('तैयारी'), findsOneWidget);
      expect(find.text('आगे बढ़ें'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'चरण 1 में से 14',
        ),
        findsOneWidget,
      );
    });

    testWidgets('पहले कदम पर पीछे का बटन नहीं दिखता', (tester) async {
      await kholoPlayer(tester);
      expect(find.text('पीछे'), findsNothing);
    });

    testWidgets('"आगे बढ़ें" से अगला कदम आता है, "पीछे" से वापस',
        (tester) async {
      await kholoPlayer(tester);

      await tester.tap(find.text('आगे बढ़ें'));
      await tester.pumpAndSettle();
      expect(find.text('चरण 2 / 14'), findsOneWidget);
      expectStepProgress(tester, 2, 14);

      await tester.tap(find.text('पीछे'));
      await tester.pumpAndSettle();
      expect(find.text('चरण 1 / 14'), findsOneWidget);
    });

    testWidgets('चरणों की सूची से किसी भी मौजूदा चरण पर जाया जा सकता है',
        (tester) async {
      await kholoPlayer(tester);

      await tester.tap(find.byTooltip('चरणों की सूची'));
      await tester.pumpAndSettle();

      expect(find.text('पूजा के चरण'), findsOneWidget);
      expect(find.text('अभी यह चरण खुला है'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('संकल्प'),
        160,
        scrollable: find.descendant(
          of: find.byKey(const Key('charan_overview_list')),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.tap(find.text('संकल्प'));
      await tester.pumpAndSettle();

      expect(find.text('चरण 4 / 14'), findsOneWidget);
      expect(find.text('संकल्प'), findsWidgets);
    });

    testWidgets('आख़िरी कदम completion खोलकर active resume हटाता है',
        (tester) async {
      // Detail → Player वाला direct production path भी completion के बाद
      // मुख्य Vidhi home पर लौटना चाहिए।
      await kholoSatyanarayan(tester);
      await settings.recordLastReachedStep(
        pujaId: 'ganesh_poojan',
        stepIndex: 2,
        totalSteps: 11,
      );
      await tester.tap(find.text('अभी विधि शुरू करें'));
      await tester.pumpAndSettle();

      for (var i = 0; i < 13; i++) {
        await tester.tap(find.text('आगे बढ़ें'));
        await tester.pumpAndSettle();
      }

      expect(find.text('चरण 14 / 14'), findsOneWidget);
      expectStepProgress(tester, 14, 14);
      expect(find.text('पूजा पूर्ण करें'), findsOneWidget);
      expect(find.text('आगे बढ़ें'), findsNothing);

      final completion = tester.widget<VidhivatButton>(
        find.ancestor(
          of: find.text('पूजा पूर्ण करें'),
          matching: find.byType(VidhivatButton),
        ),
      );
      completion.onPressed!();
      completion.onPressed!();
      await tester.pumpAndSettle();

      expect(find.text('मार्गदर्शिका पूरी हुई'), findsOneWidget);
      expect(find.text('सत्यनारायण पूजा'), findsOneWidget);
      expect(
        settings.playerProgressFor('satyanarayan', 14),
        isNull,
      );
      expect(
        settings.playerProgressFor('ganesh_poojan', 11)?.lastReachedStepIndex,
        2,
      );

      await tester.tap(find.text('विधि पर लौटें'));
      await tester.pumpAndSettle();
      expect(find.byType(VidhiListScreen), findsOneWidget);

      await scrollTak(tester, find.text('त्योहार'));
      await tester.tap(find.text('सत्यनारायण पूजा'));
      await tester.pumpAndSettle();
      expect(find.text('आप यहाँ तक पहुँचे थे'), findsNothing);
      expect(find.text('अभी विधि शुरू करें'), findsOneWidget);
    });

    testWidgets('ड्राफ़्ट मंत्र source data के exact text के साथ दिखता है',
        (tester) async {
      await kholoPlayer(tester);

      await tester.tap(find.text('आगे बढ़ें')); // 2 — चौकी सजाना
      await tester.pumpAndSettle();
      await tester
          .tap(find.text('आगे बढ़ें')); // 3 — आचमन, यहाँ ड्राफ़्ट मंत्र है
      await tester.pumpAndSettle();

      const devanagari = 'ॐ केशवाय नमः।\nॐ नारायणाय नमः।\nॐ माधवाय नमः।\n'
          'ॐ हृषीकेशाय नमः।\n\nॐ अपवित्रः पवित्रो वा सर्वावस्थां गतोऽपि वा।\n'
          'यः स्मरेत् पुण्डरीकाक्षं स बाह्याभ्यन्तरः शुचिः॥';
      const roman = 'om keshavaya namah | om narayanaya namah | '
          'om madhavaya namah | om hrishikeshaya namah ||\n\n'
          "om apavitrah pavitro va sarvavastham gato'pi va |\n"
          'yah smaret pundarikaksham sa bahyabhyantarah shuchih ||';
      const arth = 'पहले तीन नाम बोलकर तीन बार जल पिया जाता है, चौथा बोलकर '
          'हाथ धोए जाते हैं। दूसरे श्लोक का भाव — चाहे कोई अपवित्र हो, पवित्र '
          'हो, या किसी भी हालत में हो, जो कमलनयन भगवान को याद कर ले वो भीतर '
          'और बाहर दोनों तरफ़ से शुद्ध हो जाता है।';
      const strot = 'स्रोत — sanskritbhasi.blogspot.com — देव पूजा विधि '
          '(आचमन, पवित्रीकरण)। पवित्रीकरण वाला श्लोक webdunia की महालक्ष्मी '
          'पूजन विधि में भी हूबहू यही मिला।';

      expect(find.text('मंत्र'), findsOneWidget);
      expect(find.text(devanagari), findsOneWidget);
      expect(find.text('उच्चारण'), findsOneWidget);
      expect(find.text(roman), findsOneWidget);
      expect(find.text('अर्थ'), findsOneWidget);
      expect(find.text(arth), findsOneWidget);

      // ड्राफ़्ट कभी चुपचाप "तैयार" जैसा नहीं दिखना चाहिए (→ D-022)।
      await scrollTak(tester, find.textContaining('पंडित जी से पास नहीं हुआ'));
      expect(find.textContaining('पंडित जी से पास नहीं हुआ'), findsOneWidget);
      await scrollTak(tester, find.text(strot));
      expect(find.text(strot), findsOneWidget);
    });

    testWidgets('जिस कदम का मंत्र ख़ाली है वहाँ बना हुआ मंत्र नहीं दिखता',
        (tester) async {
      // अंदाज़े से मंत्र लिखना इस प्रोजेक्ट की सबसे बड़ी मनाही है।
      // सातवाँ कदम नवग्रह का है — उसके नौ मंत्र जान-बूझकर नहीं लिखे गए।
      await kholoPlayer(tester);

      for (var i = 0; i < 6; i++) {
        await tester.tap(find.text('आगे बढ़ें'));
        await tester.pumpAndSettle();
      }

      expect(find.text('चरण 7 / 14'), findsOneWidget);
      expect(find.text('मंत्र'), findsNothing);

      await scrollTak(
          tester, find.textContaining('मंत्र अभी ऐप में नहीं जोड़ा गया'));
      expect(
        find.textContaining('मंत्र अभी ऐप में नहीं जोड़ा गया'),
        findsOneWidget,
      );
      // ख़ाली छोड़ने की वजह भी दिखनी चाहिए।
      await scrollTak(tester, find.textContaining('नौ ग्रहों के नौ अलग मंत्र'));
      expect(find.textContaining('नौ ग्रहों के नौ अलग मंत्र'), findsOneWidget);
    });

    testWidgets(
        '320 dp और 1.3x अक्षर आकार पर प्लेयर सुरक्षित है',
        (tester) => expectPlayerFits(
              tester,
              width: 320,
              textScaler: const TextScaler.linear(1.3),
            ));

    testWidgets(
        '393 dp और सामान्य अक्षर आकार पर प्लेयर सुरक्षित है',
        (tester) => expectPlayerFits(
              tester,
              width: 393,
              textScaler: const TextScaler.linear(1),
            ));

    testWidgets(
        '360 dp और 1.5x अक्षर आकार पर प्लेयर सुरक्षित है',
        (tester) => expectPlayerFits(
              tester,
              width: 360,
              textScaler: const TextScaler.linear(1.5),
            ));

    testWidgets(
        '412 dp और सामान्य अक्षर आकार पर प्लेयर सुरक्षित है',
        (tester) => expectPlayerFits(
              tester,
              width: 412,
              textScaler: const TextScaler.linear(1),
            ));

    testWidgets(
        '320 dp और 1.5x पर overview की आख़िरी row पहुँच में है',
        (tester) => expectOverviewFits(
              tester,
              width: 320,
              textScaler: const TextScaler.linear(1.5),
            ));

    testWidgets('materials से player completion और विधि home पर लौटता है',
        (tester) async {
      await kholoSatyanarayan(tester);
      await tester.tap(find.text('पूजा की तैयारी करें'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('पूजा शुरू करें'));
      await tester.pumpAndSettle();

      for (var i = 0; i < 13; i++) {
        await tester.tap(find.text('आगे बढ़ें'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('पूजा पूर्ण करें'));
      await tester.pumpAndSettle();

      expect(find.text('मार्गदर्शिका पूरी हुई'), findsOneWidget);
      await tester.tap(find.text('विधि पर लौटें'));
      await tester.pumpAndSettle();
      expect(find.byType(VidhiListScreen), findsOneWidget);
    });

    testWidgets('overview visited marker केवल इस सत्र में देखे चरण बताता है',
        (tester) async {
      await kholoPlayer(tester);
      await tester.tap(find.text('आगे बढ़ें'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('चरणों की सूची'));
      await tester.pumpAndSettle();

      expect(find.text('इस सत्र में देखा गया'), findsOneWidget);
      expect(find.text('अभी यह चरण खुला है'), findsOneWidget);
      expect(find.text('आगे का चरण'), findsWidgets);
      expect(find.text('पूर्ण'), findsNothing);
    });

    testWidgets('player furthest reached app position सुरक्षित रखता है',
        (tester) async {
      await kholoPlayer(tester);
      await tester.tap(find.text('आगे बढ़ें'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('आगे बढ़ें'));
      await tester.pumpAndSettle();

      expect(
        settings.playerProgressFor('satyanarayan', 14)?.lastReachedStepIndex,
        2,
      );

      await tester.tap(find.text('पीछे'));
      await tester.pumpAndSettle();
      expect(
        settings.playerProgressFor('satyanarayan', 14)?.lastReachedStepIndex,
        2,
      );
    });

    testWidgets('saved app position से सही चरण पर resume होता है',
        (tester) async {
      await settings.recordLastReachedStep(
        pujaId: 'satyanarayan',
        stepIndex: 3,
        totalSteps: 14,
      );
      expect(
        settings.playerProgressFor('satyanarayan', 14)?.lastReachedStepIndex,
        3,
      );
      phoneNaap(tester);
      await tester.pumpWidget(app(const VidhiScreen(id: 'satyanarayan')));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.text('आप यहाँ तक पहुँचे थे'));
      expect(find.text('आप यहाँ तक पहुँचे थे'), findsOneWidget);
      expect(find.text('चरण 4 / 14'), findsOneWidget);
      expect(find.text('संकल्प'), findsOneWidget);
      await tester.tap(find.text('यहीं से जारी रखें'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('चरण 4 / 14'), findsOneWidget);
    });

    testWidgets('शुरू से करें Step 1 खोलता और saved app position हटाता है',
        (tester) async {
      await settings.recordLastReachedStep(
        pujaId: 'satyanarayan',
        stepIndex: 3,
        totalSteps: 14,
      );
      phoneNaap(tester);
      await tester.pumpWidget(app(const VidhiScreen(id: 'satyanarayan')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('शुरू से करें'));
      await tester.pumpAndSettle();
      expect(find.text('चरण 1 / 14'), findsOneWidget);
      expect(settings.playerProgressFor('satyanarayan', 14), isNull);
    });

    testWidgets('rapid शुरू से करें केवल एक नया player route खोलता है',
        (tester) async {
      await settings.recordLastReachedStep(
        pujaId: 'satyanarayan',
        stepIndex: 3,
        totalSteps: 14,
      );
      phoneNaap(tester);
      await tester.pumpWidget(app(const VidhiScreen(id: 'satyanarayan')));
      await tester.pumpAndSettle();

      final startOver = tester.widget<VidhivatButton>(
        find.ancestor(
          of: find.text('शुरू से करें'),
          matching: find.byType(VidhivatButton),
        ),
      );
      startOver.onPressed!();
      startOver.onPressed!();
      await tester.pumpAndSettle();

      expect(find.text('चरण 1 / 14'), findsOneWidget);
      expect(
        find.byType(VidhiPlayerScreen, skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('दूसरी पूजा की saved position सत्यनारायण detail पर नहीं दिखती',
        (tester) async {
      await settings.recordLastReachedStep(
        pujaId: 'ganesh_poojan',
        stepIndex: 2,
        totalSteps: 11,
      );
      phoneNaap(tester);
      await tester.pumpWidget(app(const VidhiScreen(id: 'satyanarayan')));
      await tester.pumpAndSettle();

      expect(find.text('आप यहाँ तक पहुँचे थे'), findsNothing);
      expect(find.text('अभी विधि शुरू करें'), findsOneWidget);
    });

    testWidgets('320 dp और 1.5x पर resume panel सुरक्षित है', (tester) async {
      await settings.recordLastReachedStep(
        pujaId: 'satyanarayan',
        stepIndex: 3,
        totalSteps: 14,
      );
      expect(
        settings.playerProgressFor('satyanarayan', 14)?.lastReachedStepIndex,
        3,
      );
      phoneNaap(tester, width: 320);
      await tester.pumpWidget(app(
        const VidhiScreen(id: 'satyanarayan'),
        textScaler: const TextScaler.linear(1.5),
      ));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.text('आप यहाँ तक पहुँचे थे'));
      expect(find.text('आप यहाँ तक पहुँचे थे'), findsOneWidget);
      expect(find.text('यहीं से जारी रखें'), findsOneWidget);
      expect(find.text('शुरू से करें'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('320 dp और 1.5x पर completion सुरक्षित है', (tester) async {
      final vidhi = await vidhiBhandar.vidhi('satyanarayan');
      phoneNaap(tester, width: 320);
      await tester.pumpWidget(app(
        PujaCompletionScreen(vidhi: vidhi),
        textScaler: const TextScaler.linear(1.5),
      ));
      await tester.pumpAndSettle();

      expect(find.text('मार्गदर्शिका पूरी हुई'), findsOneWidget);
      expect(find.text('सत्यनारायण पूजा'), findsOneWidget);
      expect(find.text('विधि पर लौटें'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('संकल्प वाला कदम — ऐप का सबसे बड़ा फ़र्क़', () {
    Future<void> jaoSankalpPar(WidgetTester tester) async {
      await kholoSatyanarayan(tester);
      await tester.tap(find.text('अभी विधि शुरू करें'));
      await tester.pumpAndSettle();
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('आगे बढ़ें'));
        await tester.pumpAndSettle();
      }
    }

    testWidgets('नाम न भरा हो तो भरने का बटन दिखता है', (tester) async {
      await jaoSankalpPar(tester);

      expect(find.text('चरण 4 / 14'), findsOneWidget);
      expect(find.text('संकल्प'), findsOneWidget);
      await scrollTak(tester, find.text('नाम और गोत्र भरिए'));
      expect(find.text('नाम और गोत्र भरिए'), findsOneWidget);
    });

    testWidgets('नाम भरा हो तो पूरा संकल्प पंचांग से बनकर आ जाता है',
        (tester) async {
      await settings.setYajman(name: 'चन्दन सिंह', gotra: 'कश्यप');
      await jaoSankalpPar(tester);

      await scrollTak(tester, find.text('पूरा संकल्प'));
      expect(find.text('नाम और गोत्र भरिए'), findsNothing);
      expect(find.text('पूरा संकल्प'), findsOneWidget);

      // संकल्प में यजमान का नाम और परंपरागत शुरुआत दोनों होनी चाहिए।
      expect(find.textContaining('चन्दन सिंह'), findsWidgets);
      expect(find.textContaining('जम्बूद्वीपे'), findsOneWidget);

      // और संस्कृत अभी पास नहीं हुई — यह चेतावनी हमेशा दिखेगी (→ D-020)।
      expect(find.textContaining('पंडित जी से पास नहीं'), findsOneWidget);
    });

    testWidgets('"सरल" चुनने पर हिंदी वाला रूप आता है', (tester) async {
      await settings.setYajman(name: 'चन्दन सिंह', gotra: 'कश्यप');
      await jaoSankalpPar(tester);

      await scrollTak(tester, find.text('सरल (हिंदी में)'));
      await tester.tap(find.text('सरल (हिंदी में)'));
      await tester.pumpAndSettle();

      expect(find.textContaining('जम्बूद्वीपे'), findsNothing);
      expect(find.textContaining('चन्दन सिंह'), findsWidgets);
    });
  });

  group('वो बग जो पिछली बार सिर्फ़ फ़ोन पर मिला था', () {
    // 21 अगस्त 2026: `TextEditingController` पर listener न होने से
    // "संकल्प बनाइए" बटन नाम भरने पर भी बंद रहता था। यह जाँच उसी को
    // पकड़ती है — अब वो दोबारा नहीं लौट सकता।

    testWidgets('नाम ख़ाली हो तो बटन बंद, नाम भरते ही चालू', (tester) async {
      await tester.pumpWidget(app(NaamPoochho(onDone: () {})));
      await tester.pumpAndSettle();

      FilledButton button() => tester.widget<FilledButton>(
            find.widgetWithText(FilledButton, 'संकल्प बनाइए'),
          );

      expect(button().onPressed, isNull, reason: 'ख़ाली नाम पर बंद होना चाहिए');

      await tester.enterText(find.byType(TextField), 'चन्दन सिंह');
      await tester.pumpAndSettle();

      expect(button().onPressed, isNotNull,
          reason: 'नाम भरने पर बटन चालू हो जाना चाहिए — यही वो बग था');
    });

    testWidgets('सिर्फ़ खाली जगह भरने से बटन चालू नहीं होता', (tester) async {
      await tester.pumpWidget(app(NaamPoochho(onDone: () {})));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '   ');
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'संकल्प बनाइए'))
            .onPressed,
        isNull,
      );
    });
  });
}
