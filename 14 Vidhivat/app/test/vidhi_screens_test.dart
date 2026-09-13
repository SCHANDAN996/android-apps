import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panchang_engine/panchang_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/main.dart';
import 'package:vidhivat/screens/paath_screen.dart';
import 'package:vidhivat/screens/parv_screen.dart';
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

  /// ℹ बटन तक जाओ और उसकी शीट खोलो (→ D-045, D-056)।
  ///
  /// स्रोत, भरोसा और पद्धति वाली हर बात अब एक दबाव पीछे है —
  /// मिटाई नहीं, छिपी भी नहीं। जाँच भी उसी रास्ते से जाएगी।
  Future<void> kholoSrot(WidgetTester tester, String label) async {
    await scrollTak(tester, find.text(label));
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  /// खुली ℹ शीट के अंदर नीचे तक जाओ।
  ///
  /// ⚠ शीट आधी ऊँचाई पर खुलती है (`initialChildSize: 0.5`) और उसकी
  /// `ListView` आलसी है — नीचे की पंक्तियाँ **बनी ही नहीं** होतीं।
  /// इसलिए `findsNothing` वहाँ "नहीं है" नहीं कहता — सिर्फ़ "अभी
  /// बना नहीं" कहता है। नीचे की बात जाँचनी हो तो पहले यहाँ से लाओ।
  Future<void> srotMeinNeeche(WidgetTester tester, Finder tak) async {
    await tester.dragUntilVisible(
      tak,
      find.byType(ListView).last,
      const Offset(0, -80),
    );
    await tester.pumpAndSettle();
  }

  /// सामग्री की सूची खोलो।
  ///
  /// ⚠️ रास्ता बदल गया है (→ D-048)। पहले नीचे की पट्टी में
  /// "सामग्री की सूची देखें" वाला भरा बटन था — पर वही काम "सामग्री"
  /// शीर्षक के "सभी देखें" से भी होता था, यानी एक ही पन्ने पर दो बार।
  /// नीचे अब सिर्फ़ **एक** बटन है, और वो पूजा शुरू करता है।
  Future<void> kholoSamagri(WidgetTester tester) async {
    // ⚠️ पहले ऊपर लौटो। "सभी देखें" पन्ने के **बीच** में है, और
    // `scrollUntilVisible` सिर्फ़ एक दिशा में चलता है — अगर जाँच पहले
    // नीचे तक स्क्रॉल कर चुकी है (जैसे "यह विधि कहाँ से आई" तक), तो
    // आगे ढूँढ़ने पर वो कभी नहीं मिलेगा।
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 4000));
    await tester.pumpAndSettle();
    await scrollTak(tester, find.text('सभी देखें'));
    await tester.tap(find.text('सभी देखें'));
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
    await kholoSamagri(tester);
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

  group('होम की सबसे ऊपर वाली पट्टी (carousel)', () {
    // पूरी सूची पंचांग से बनती है — कोई तारीख़ हाथ से नहीं भरी (→ D-038)।
    // गणित की अपनी जाँचें `aane_wale_din_test.dart` में हैं; यहाँ सिर्फ़
    // यह देखना है कि वो होम पर सही दिख रही है और दबने पर खुलती है।
    //
    // पहले यह एक जमा हुआ hero + नीचे अलग सूची थी। अब एक ही पट्टी है —
    // आज पहला पत्ता, फिर आगे के दिन (→ D-046)।

    testWidgets('सबसे ऊपर है — पंचांग से भी पहले', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const HomeShell()));
      await tester.pumpAndSettle();

      final carousel = find.byKey(const Key('puja_carousel'));
      expect(carousel, findsOneWidget);

      // बिना स्क्रॉल किए दिखना चाहिए — यही पूरी बात है।
      final patti = tester.getTopLeft(carousel).dy;
      final panchang = tester.getTopLeft(find.text('आज का पंचांग')).dy;
      expect(patti, lessThan(panchang));
      expect(tester.takeException(), isNull);
    });

    testWidgets('पहला पत्ता आज का है, या नित्य पूजा', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const HomeShell()));
      await tester.pumpAndSettle();

      // इनमें से कोई एक पहला पत्ता बनेगा — कौन सा, वो दिन पर निर्भर है।
      final pehleWale = ['आज', 'आज की सरल शुरुआत', 'जहाँ छोड़ा था'];
      expect(
        pehleWale.any((upar) => find.text(upar).evaluate().isNotEmpty),
        isTrue,
        reason: 'पहला पत्ता आज से जुड़ा होना चाहिए',
      );
    });

    testWidgets('auto-swipe नहीं है — बिना छुए पत्ता वहीं रहता है',
        (tester) async {
      // ⚠️ यह जाँच जान-बूझकर है। carousel में auto-advance **नहीं**
      // डालना — वजहें `_PujaCarousel` के ऊपर लिखी हैं (→ D-046)।
      // सबसे बड़ी: आदमी बटन दबाने जा रहा हो और पत्ता खिसक जाए।
      phoneNaap(tester);
      await tester.pumpWidget(app(const HomeShell()));
      await tester.pumpAndSettle();

      final pehla = tester
          .widget<PageView>(find.byKey(const Key('puja_carousel')))
          .controller!
          .page;

      await tester.pump(const Duration(seconds: 12));
      await tester.pump(const Duration(seconds: 12));

      expect(
        tester
            .widget<PageView>(find.byKey(const Key('puja_carousel')))
            .controller!
            .page,
        pehla,
        reason: 'बिना उँगली लगे पत्ता बदलना नहीं चाहिए',
      );
    });

    testWidgets('स्वाइप करने पर अगला पत्ता आता है', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const HomeShell()));
      await tester.pumpAndSettle();

      final carousel = find.byKey(const Key('puja_carousel'));
      await tester.drag(carousel, const Offset(-300, 0));
      await tester.pumpAndSettle();

      expect(
        tester.widget<PageView>(carousel).controller!.page,
        greaterThan(0),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('जो पूजा खुल सकती है वो दबाने पर खुलती है', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const HomeShell()));
      await tester.pumpAndSettle();

      // पहले पत्ते पर जो बटन है — उनमें से कोई एक होगा।
      final bulawa = [
        find.text('पूजा जारी रखें'),
        find.text('पूजा शुरू करें'),
        find.text('विधि देखें'),
      ].firstWhere((f) => f.evaluate().isNotEmpty);

      await tester.tap(bulawa.first);
      await tester.pumpAndSettle();
      expect(find.byType(VidhiScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('पुरानी अलग सूची अब नहीं है — वो दोहराव था', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const HomeShell()));
      await tester.pumpAndSettle();

      expect(find.text('आगे क्या आ रहा है'), findsNothing);
      expect(
          find.text('तारीख़ें पंचांग से, आपके शहर के हिसाब से'), findsNothing);
    });

    testWidgets('320 dp और 1.5x अक्षर पर भी सुरक्षित है', (tester) async {
      phoneNaap(tester, width: 320);
      await tester.pumpWidget(app(
        const HomeShell(),
        textScaler: const TextScaler.linear(1.5),
      ));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('puja_carousel')), findsOneWidget);
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
      // ⚠️ यहाँ पहले `find.text('नित्य पूजा')` लिखा था। carousel आने के
      // बाद वो **तारीख़ पर निर्भर** हो गया — जिस दिन कोई त्योहार पड़ता है
      // उस दिन पहला पत्ता वो होता है, नित्य पूजा नहीं (→ D-046)।
      // जाँच किसी दिन पास और किसी दिन फ़ेल नहीं होनी चाहिए।
      expect(find.byKey(const Key('puja_carousel')), findsOneWidget);
      await scrollTak(tester, find.text('तुरंत खोलें'));
      expect(find.text('तुरंत खोलें'), findsOneWidget);
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

      // अधूरी पूजा हमेशा **पहला** पत्ता बनती है — चाहे आज त्योहार भी हो
      // (→ D-046)। और वो आज की ही होनी चाहिए (→ D-044)।
      expect(find.text('जहाँ छोड़ा था'), findsOneWidget);
      expect(find.text('पूजा जारी रखें'), findsOneWidget);
      expect(find.textContaining('चरण 3'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Home se अधूरी पूजा manually हटाई जा सकती है', (tester) async {
      final nitya = await vidhiBhandar.vidhi('nitya_pooja');
      await settings.recordLastReachedStep(
        pujaId: nitya.id,
        stepIndex: 2,
        totalSteps: nitya.charan.length,
      );
      phoneNaap(tester);
      await tester.pumpWidget(app(const HomeShell()));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('अधूरी पूजा हटाएँ'));
      await tester.pumpAndSettle();
      expect(find.text('अधूरी पूजा हटाएँ?'), findsOneWidget);
      expect(find.textContaining('पूजा की विधि नहीं मिटेगी'), findsOneWidget);

      await tester.tap(find.text('हटाएँ'));
      await tester.pumpAndSettle();

      expect(
        settings.playerProgressFor(nitya.id, nitya.charan.length),
        isNull,
      );
      expect(find.text('जहाँ छोड़ा था'), findsNothing);
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
    testWidgets('नवरात्रि पर्व-card से पूरा पंचांग-आधारित पन्ना खुलता है',
        (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const VidhiListScreen()));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.byKey(const Key('navratri_parv_card')));
      await tester.tap(find.byKey(const Key('navratri_parv_card')));
      await tester.pumpAndSettle();

      expect(find.byType(ParvScreen), findsOneWidget);
      expect(find.text('शारदीय नवरात्रि'), findsWidgets);
      await scrollTak(tester, find.text('संक्षिप्त पूजा'));
      expect(find.text('संक्षिप्त पूजा'), findsOneWidget);
      expect(find.text('पूर्ण नवरात्रि'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

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
      // Phase A की छह पूजाएँ, और अब दीपावली की तिकड़ी (धनतेरस, गोवर्धन,
      // भाई दूज) भी असली विधि बन गईं — इसलिए वे planned सूची से हट चुकी
      // हैं। वरना एक ही नाम दो जगह दिखता।
      expect(plannedPujaCount, 7);
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
      expect(plannedIds.toSet(), hasLength(7));
      expect(plannedIds, contains('purna_havan'));

      // यही असली रखवाली है — एक भी id दोनों जगह न हो।
      final banChukiIds = (await vidhiBhandar.suchi()).map((e) => e.id).toSet();
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
      expect(find.text('पूजा शुरू करें'), findsOneWidget);

      Navigator.of(tester.element(find.byType(VidhiScreen))).pop();
      await tester.pumpAndSettle();

      // हनुमान पूजा अब असली विधि है — खुलनी चाहिए।
      await scrollTak(tester, find.text('हनुमान पूजा'));
      await tester.tap(find.text('हनुमान पूजा'));
      await tester.pumpAndSettle();
      expect(find.text('पूजा शुरू करें'), findsOneWidget);
      Navigator.of(tester.element(find.byType(VidhiScreen))).pop();
      await tester.pumpAndSettle();

      // जो अब भी सिर्फ़ नाम है वो दबनी नहीं चाहिए।
      await scrollTak(tester, find.text('त्योहार संग्रह'));
      expect(find.text('जल्द आएगी'), findsWidgets);
      // रक्षाबंधन भी अब असली विधि है — जो अब भी सिर्फ़ नाम है उस पर टैप करो
      await scrollTak(tester, find.text('राम नवमी'));
      await tester.tap(find.text('राम नवमी'));
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

    testWidgets('नीचे वाली लाइन यूज़र की बात कहती है, हमारी प्रगति नहीं',
        (tester) async {
      // ⚠️ यह जाँच पहले उल्टी थी — "अभी 0 / 28 पंडित जी से जाँची गई हैं"
      // का दिखना ज़रूरी माना गया था। फ़ोन पर वो सूची के ठीक नीचे बैठकर
      // हर पूजा पर शक डाल रहा था, और यूज़र उससे कुछ कर नहीं सकता था।
      //
      // ऐप की अपनी प्रगति `docs/06_CONTENT_TRACKER.md` में रहती है,
      // स्क्रीन पर नहीं (→ D-041)।
      phoneNaap(tester);
      await tester.pumpWidget(app(const VidhiListScreen()));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.textContaining('अभी तैयार हो रही हैं'));
      expect(
        find.textContaining('अभी तैयार हो रही हैं'),
        findsOneWidget,
      );
      // ऐप अपनी गिनती भी नहीं छापता — सूची सामने है (→ D-056)।
      expect(find.textContaining('पूजा-विधियाँ अभी खुली हैं'), findsNothing);
      expect(find.textContaining('पंडित जी से जाँची'), findsNothing);
      expect(find.text('जाँच बाकी'), findsNothing);
    });
  });

  group('पूजा का विवरण', () {
    testWidgets('विवरण खुलता है और ज़रूरी बातें दिखती हैं', (tester) async {
      await kholoSatyanarayan(tester);

      // नीचे अब **एक ही** बटन है, और वो असली काम करता है (→ D-048)।
      // सामग्री का रास्ता "सामग्री" शीर्षक के "सभी देखें" से है।
      expect(find.text('पूजा शुरू करें'), findsOneWidget);
      expect(find.text('सामग्री की सूची देखें'), findsNothing);
      await scrollTak(tester, find.text('16 चरण'));
      expect(find.text('16 चरण'), findsOneWidget);
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

    testWidgets('विधि किस दर्जे की है, यह साफ़ लिखा रहता है', (tester) async {
      // यह चुपचाप ग़ायब नहीं होनी चाहिए — पूरा भरोसा इसी पर टिका है।
      //
      // पहले यहाँ "पंडित जी से पास नहीं हुई" लिखा था और वही वाक्य हर
      // मंत्र पर भी दोहराता था (→ D-042)। अब यह बात **एक ही बार**
      // कही जाती है, और वो कहती है कि ऐप क्या जानता है — स्रोत नीचे
      // मिलेगा, दो चलन हों तो दोनों मिलेंगे।
      await kholoSatyanarayan(tester);
      // यह बात मिटी नहीं — एक दबाव पीछे गई है (→ D-056)।
      //
      // वो **28 में से 28 पूजाओं पर** खुली पड़ी रहती थी, जबकि
      // `jaanch.paas` किसी JSON में `true` है ही नहीं — यानी शर्त
      // नहीं, दीवार थी। अब पहली तह में नहीं आती…
      expect(find.textContaining('घर की सरल पद्धति'), findsNothing);

      // …पर ℹ दबाते ही पूरी मिलती है।
      await kholoSrot(tester, 'यह विधि कहाँ से आई');
      expect(find.text('यह विधि कैसी है'), findsOneWidget);
      expect(find.textContaining('घर की सरल पद्धति'), findsOneWidget);
      expect(find.textContaining('उसका स्रोत लिखा है'), findsOneWidget);
      await srotMeinNeeche(tester, find.textContaining('वही सही है'));
      expect(find.textContaining('वही सही है'), findsOneWidget);

      // और वो पुराना वाक्य कहीं नहीं बचा
      expect(find.textContaining('पंडित जी से जाँच करवाकर पास नहीं'),
          findsNothing);
    });

    testWidgets('अधूरे मंत्रों की गिनती साफ़ लिखी है', (tester) async {
      await kholoSatyanarayan(tester);
      // यह गिनती भी अब उसी ℹ के अंदर है (→ D-056)।
      //
      // ⚠ इससे वो चेतावनी नहीं हटी जो हर ख़ाली कदम पर खुली
      // मिलती है — वहाँ ऐप अपनी कमी मान रहा होता है (→ D-049)।
      await kholoSrot(tester, 'यह विधि कहाँ से आई');
      await srotMeinNeeche(tester, find.text('अभी क्या कम है'));
      expect(find.text('अभी क्या कम है'), findsOneWidget);
      expect(find.textContaining('मंत्रों का पाठ अभी जोड़ा नहीं गया'),
          findsOneWidget);
    });
  });

  group('सामग्री की सूची', () {
    testWidgets('टिक लगाने पर गिनती बढ़ती है और फ़ोन में याद रहती है',
        (tester) async {
      await kholoSatyanarayan(tester);
      await kholoSamagri(tester);

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
      await kholoSamagri(tester);

      // "वैकल्पिक" अक्सर note के साथ एक ही लाइन में जुड़ जाता है
      // ("वैकल्पिक · मंडप बनाने के लिए"), इसलिए textContaining।
      expect(find.textContaining('वैकल्पिक'), findsWidgets);

      await tester.tap(find.text('सिर्फ़ ज़रूरी'));
      await tester.pumpAndSettle();

      expect(find.textContaining('वैकल्पिक'), findsNothing);
    });

    testWidgets('सारी टिक हटाने वाला बटन सचमुच हटाता है', (tester) async {
      await kholoSatyanarayan(tester);
      await kholoSamagri(tester);

      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();
      expect(settings.samagriTicks('satyanarayan'), hasLength(1));

      await tester.tap(find.byIcon(Icons.restart_alt));
      await tester.pumpAndSettle();
      expect(settings.samagriTicks('satyanarayan'), isEmpty);
    });

    // ── A10: क्या नहीं चढ़ाना ─────────────────────────────────────
    // सामग्री जुटाते वक़्त ही आदमी सोचता है "यह भी रख लूँ" — इसलिए यह
    // खाना ठीक इसी पन्ने पर है।

    testWidgets('सत्यनारायण में सिर्फ़ सबके लिए वाली बातें दिखती हैं',
        (tester) async {
      await kholoSatyanarayan(tester);
      await kholoSamagri(tester);

      await scrollTak(tester, find.text('क्या नहीं चढ़ाना'));
      expect(find.text('क्या नहीं चढ़ाना'), findsOneWidget);
      expect(find.textContaining('टूटे हुए चावल'), findsOneWidget);
      // विष्णु-अक्षत वाला विवादित निषेध कहीं नहीं आना चाहिए
      expect(find.textContaining('अक्षत नहीं'), findsNothing);
    });

    testWidgets('गणेश पूजन में तुलसी का निषेध वजह के साथ दिखता है',
        (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const VidhiScreen(id: 'ganesh_poojan')));
      await tester.pumpAndSettle();
      await kholoSamagri(tester);

      await scrollTak(tester, find.text('क्या नहीं चढ़ाना'));
      expect(find.text('• तुलसी'), findsOneWidget);
      expect(find.textContaining('शाप'), findsOneWidget);
      // हवाला अब एक ही ℹ में है, हर चीज़ के नीचे नहीं (→ D-056)।
      expect(find.textContaining('स्रोत:'), findsNothing);
      await kholoSrot(tester, 'ये निषेध कहाँ से आए');
      expect(find.textContaining('स्रोत:'), findsWidgets);
      expect(find.textContaining('भरोसा:'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('शिव अभिषेक में पाँचों निषेध दिखते हैं', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const VidhiScreen(id: 'rudrabhishek')));
      await tester.pumpAndSettle();
      await kholoSamagri(tester);

      await scrollTak(tester, find.text('क्या नहीं चढ़ाना'));
      for (final cheez in [
        '• तुलसी',
        '• केतकी का फूल',
        '• शंख से जल',
        '• हल्दी',
        '• सिंदूर'
      ]) {
        expect(find.text(cheez), findsOneWidget, reason: cheez);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('बिना कोई टिक लगाए भी पूजा शुरू की जा सकती है', (tester) async {
      await kholoSatyanarayan(tester);
      await kholoSamagri(tester);

      expect(settings.samagriTicks('satyanarayan'), isEmpty);
      await tester.tap(find.text('पूजा शुरू करें'));
      await tester.pumpAndSettle();
      expect(find.text('चरण 1 / 16'), findsOneWidget);
    });

    testWidgets('सामग्री से back करने पर वही पूजा detail खुलता है',
        (tester) async {
      await kholoSatyanarayan(tester);
      await kholoSamagri(tester);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // ⚠️ सामग्री तक पहुँचने में पन्ना स्क्रॉल हो चुका है, इसलिए लौटने
      // पर शीर्षक तह से बाहर होता है — और वो **सही** व्यवहार है, यूज़र
      // को वहीं लौटना चाहिए जहाँ वो था। इसलिए जाँच अब यह देखती है कि
      // हम उसी पन्ने पर हैं, न कि यह कि पन्ना ऊपर से शुरू हुआ।
      expect(find.byType(VidhiScreen), findsOneWidget);
      expect(find.text('पूजा शुरू करें'), findsOneWidget);
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
      expect(find.text('पूजा शुरू करें'), findsOneWidget);
      await kholoSamagri(tester);
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
      await tester.tap(find.text('पूजा शुरू करें'));
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
      await tester.tap(find.text('पूजा शुरू करें'));
      await tester.pumpAndSettle();

      expect(find.text('चरण 1 / 16'), findsOneWidget);
      expectStepProgress(tester, 1, 16);
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
      await tester.tap(find.text('पूजा शुरू करें'));
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

      expect(find.text('चरण 1 / 16'), findsOneWidget);
      expect(find.text('तैयारी'), findsOneWidget);
      expect(find.text('आगे बढ़ें'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'चरण 1 में से 16',
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
      expect(find.text('चरण 2 / 16'), findsOneWidget);
      expectStepProgress(tester, 2, 16);

      await tester.tap(find.text('पीछे'));
      await tester.pumpAndSettle();
      expect(find.text('चरण 1 / 16'), findsOneWidget);
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

      expect(find.text('चरण 4 / 16'), findsOneWidget);
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
      await tester.tap(find.text('पूजा शुरू करें'));
      await tester.pumpAndSettle();

      for (var i = 0; i < 15; i++) {
        await tester.tap(find.text('आगे बढ़ें'));
        await tester.pumpAndSettle();
      }

      expect(find.text('चरण 16 / 16'), findsOneWidget);
      expectStepProgress(tester, 16, 16);
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

      await tester.tap(find.text('होम पर लौटें'));
      await tester.pumpAndSettle();
      expect(find.byType(VidhiListScreen), findsOneWidget);

      await scrollTak(tester, find.text('त्योहार'));
      await tester.tap(find.text('सत्यनारायण पूजा'));
      await tester.pumpAndSettle();
      expect(find.text('आप यहाँ तक पहुँचे थे'), findsNothing);
      expect(find.text('पूजा शुरू करें'), findsOneWidget);
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
          'ॐ हृषीकेशाय नमः।\nॐ गोविन्दाय नमः।\n\n'
          'ॐ अपवित्रः पवित्रो वा सर्वावस्थां गतोऽपि वा।\n'
          'यः स्मरेत् पुण्डरीकाक्षं स बाह्याभ्यन्तरः शुचिः॥';
      const roman = 'om keshavaya namah | om narayanaya namah | '
          'om madhavaya namah |\n'
          'om hrishikeshaya namah | om govindaya namah ||\n\n'
          "om apavitrah pavitro va sarvavastham gato'pi va |\n"
          'yah smaret pundarikaksham sa bahyabhyantarah shuchih ||';
      const arth = 'पहले तीन नाम बोलकर तीन बार थोड़ा-थोड़ा जल पिया जाता है। '
          'फिर हृषीकेश का नाम लेकर दाहिने अँगूठे की जड़ से होंठ पोंछे जाते '
          'हैं, और गोविन्द का नाम लेकर हाथ धोए जाते हैं। दूसरे श्लोक का भाव '
          '— चाहे कोई अपवित्र हो, पवित्र हो, या किसी भी हालत में हो, जो '
          'कमलनयन भगवान को याद कर ले वो भीतर और बाहर दोनों तरफ़ से शुद्ध हो '
          'जाता है।';
      // "स्रोत — " उपसर्ग अब नहीं — sheet में सिर्फ़ पाठ दिखता है
      const strot = 'sanskritbhasi.blogspot.com — देव पूजा विधि '
          '(आचमन, पवित्रीकरण)। पवित्रीकरण वाला श्लोक webdunia की महालक्ष्मी '
          'पूजन विधि में भी हूबहू यही मिला। पाँचों नामों का क्रम — तीन '
          'आचमन, हृषीकेश से होंठ, गोविन्द से हाथ — jyotish.guru के मंगलाचरण '
          'वाले पन्ने की विधि में इसी तरह लिखा है।';

      // ⚠ पन्ना आलसी `ListView` है — जो तह से नीचे है वो बनता ही
      // नहीं। चौड़ी स्क्रीन पर अक्षर अब 600dp में सिमटते हैं (→ D-062),
      // इसलिए पन्ना पहले से लंबा हो गया — स्क्रॉल करना पड़ता है।
      await scrollTak(tester, find.text('मंत्र'));
      expect(find.text('मंत्र'), findsOneWidget);
      expect(find.text(devanagari), findsOneWidget);

      await scrollTak(tester, find.text('उच्चारण'));
      expect(find.text('उच्चारण'), findsOneWidget);
      expect(find.text(roman), findsOneWidget);

      await scrollTak(tester, find.text('अर्थ'));
      expect(find.text('अर्थ'), findsOneWidget);
      expect(find.text(arth), findsOneWidget);

      // ड्राफ़्ट कभी चुपचाप "तैयार" जैसा नहीं दिखना चाहिए (→ D-022) —
      // पर वो काम **स्रोत** करता है, लाल चेतावनी नहीं (→ D-042)।
      //
      // और अब स्रोत मंत्र के नीचे खुला नहीं पड़ा — वो "इस पाठ के बारे
      // में" वाले बटन के पीछे है, क्योंकि सहायक-पाठ मंत्र से सवा तीन
      // गुना लंबा था। बटन दबाने पर पूरा स्रोत मिलना चाहिए।
      await scrollTak(tester, find.textContaining('इस पाठ के बारे में'));
      expect(find.textContaining('इस पाठ के बारे में'), findsOneWidget);
      // बंद हालत में स्रोत स्क्रीन पर नहीं होना चाहिए
      expect(find.text(strot), findsNothing);

      await tester.tap(find.textContaining('इस पाठ के बारे में'));
      await tester.pumpAndSettle();
      expect(find.text(strot), findsOneWidget);
      // शीट अब साझा `VidhivatSrotButton` से बनती है, इसलिए नाम और मान
      // अलग-अलग पंक्तियों में हैं — तीनों जगह एक जैसा (→ D-045)।
      expect(find.text('भरोसा'), findsOneWidget);

      // हर मंत्र पर लगने वाला पुराना लाल डिब्बा अब नहीं आता
      expect(find.textContaining('पंडित जी से पास नहीं हुआ'), findsNothing);
    });

    testWidgets('आरती वाले कदम से आरती खुलती है (→ D-039)', (tester) async {
      // पाठ पंद्रह जगह दोहराया नहीं जाता — बटन उसे एक ही जगह से
      // खोलता है। एक बार वहाँ आरती भर जाए, तो सब जगह जुड़ जाती है।
      await kholoPlayer(tester);

      for (var i = 0; i < 12; i++) {
        await tester.tap(find.text('आगे बढ़ें'));
        await tester.pumpAndSettle();
      }
      expect(find.text('चरण 13 / 16'), findsOneWidget);

      await scrollTak(tester, find.text('श्री सत्यनारायण जी की आरती'));
      await tester.tap(find.text('श्री सत्यनारायण जी की आरती'));
      await tester.pumpAndSettle();

      expect(find.byType(PaathScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('जिस कदम का मंत्र ख़ाली है वहाँ बना हुआ मंत्र नहीं दिखता',
        (tester) async {
      // अंदाज़े से मंत्र लिखना इस प्रोजेक्ट की सबसे बड़ी मनाही है।
      // आठवाँ कदम नवग्रह का है — उसके नौ मंत्र जान-बूझकर नहीं लिखे गए।
      await kholoPlayer(tester);

      for (var i = 0; i < 7; i++) {
        await tester.tap(find.text('आगे बढ़ें'));
        await tester.pumpAndSettle();
      }

      expect(find.text('चरण 8 / 16'), findsOneWidget);
      expect(find.text('मंत्र'), findsNothing);

      await scrollTak(
          tester, find.textContaining('मंत्र अभी ऐप में नहीं जोड़ा गया'));
      expect(
        find.textContaining('मंत्र अभी ऐप में नहीं जोड़ा गया'),
        findsOneWidget,
      );
      // ख़ाली छोड़ने की वजह भी दिखनी चाहिए।
      await scrollTak(
          tester, find.textContaining('नवग्रह के लिए नौ अलग मंत्र'));
      expect(find.textContaining('नवग्रह के लिए नौ अलग मंत्र'), findsOneWidget);

      // और वो चेतावनी भी, कि "सुप्रभातम्" वाला श्लोक यहाँ का नहीं है
      await scrollTak(tester, find.textContaining('सुप्रभातम्'));
      expect(find.textContaining('सुप्रभातम्'), findsOneWidget);
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
      await kholoSamagri(tester);
      await tester.tap(find.text('पूजा शुरू करें'));
      await tester.pumpAndSettle();

      for (var i = 0; i < 15; i++) {
        await tester.tap(find.text('आगे बढ़ें'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('पूजा पूर्ण करें'));
      await tester.pumpAndSettle();

      expect(find.text('मार्गदर्शिका पूरी हुई'), findsOneWidget);
      await tester.tap(find.text('होम पर लौटें'));
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
      expect(find.text('चरण 4 / 16'), findsOneWidget);
      expect(find.text('संकल्प'), findsOneWidget);
      await tester.tap(find.text('चरण 4 से जारी रखें'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('चरण 4 / 16'), findsOneWidget);
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

      // बटन अब resume कार्ड के अंदर है, नीचे की पट्टी में नहीं — इसलिए
      // उस तक स्क्रॉल करना पड़ता है (→ D-048)।
      await scrollTak(tester, find.text('शुरू से करें'));
      await tester.tap(find.text('शुरू से करें'));
      await tester.pumpAndSettle();
      expect(find.text('चरण 1 / 16'), findsOneWidget);
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

      await scrollTak(tester, find.text('शुरू से करें'));
      final startOver = tester.widget<VidhivatButton>(
        find.ancestor(
          of: find.text('शुरू से करें'),
          matching: find.byType(VidhivatButton),
        ),
      );
      startOver.onPressed!();
      startOver.onPressed!();
      await tester.pumpAndSettle();

      expect(find.text('चरण 1 / 16'), findsOneWidget);
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
      expect(find.text('पूजा शुरू करें'), findsOneWidget);
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
      // नीचे एक ही बटन, और वो बताता है कि कहाँ से जुड़ना है (→ D-048)।
      // "शुरू से करें" अब इसी कार्ड के अंदर है, नीचे की पट्टी में नहीं।
      expect(find.textContaining('से जारी रखें'), findsOneWidget);
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
      expect(find.text('होम पर लौटें'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('संकल्प वाला कदम — ऐप का सबसे बड़ा फ़र्क़', () {
    Future<void> jaoSankalpPar(WidgetTester tester) async {
      await kholoSatyanarayan(tester);
      await tester.tap(find.text('पूजा शुरू करें'));
      await tester.pumpAndSettle();
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('आगे बढ़ें'));
        await tester.pumpAndSettle();
      }
    }

    testWidgets('नाम न भरा हो तो भरने का बटन दिखता है', (tester) async {
      await jaoSankalpPar(tester);

      expect(find.text('चरण 4 / 16'), findsOneWidget);
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

      // और संकल्प के साथ यह बात हमेशा लिखी रहेगी — कि रूप कहाँ से
      // ── पूजा के बीच में सफ़ाई नहीं (→ D-056) ──────────────
      //
      // यही बात पहले तीन जगह छपती थी — पूजा की तैयारी, संकल्प
      // का पन्ना, और यह कदम। यहाँ आदमी जमीन पर बैठा संकल्प
      // बोल रहा है — यह वो पल नहीं जब उसे पद्धतियों का भेद पढ़ना है।
      expect(find.textContaining('व्याकरण और छपी पद्धतियों से'), findsNothing);
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

    // ── A3: यजमान का लिंग ────────────────────────────────────────
    // यह असली बग था — ऐप हर यजमान को पुरुष मानकर हर स्त्री के लिए भी
    // "…गोत्रोत्पन्नः" बना देता था।

    testWidgets('स्त्री यजमान का संकल्प स्त्रीलिंग में बनता है',
        (tester) async {
      await settings.setYajman(
        name: 'सीता देवी',
        gotra: 'भारद्वाज',
        yajaman: Yajaman.stri,
      );
      await jaoSankalpPar(tester);
      await scrollTak(tester, find.text('पूरा संकल्प'));

      expect(find.textContaining('गोत्रोत्पन्ना'), findsOneWidget);
      expect(find.textContaining('नाम्नी अहम्'), findsOneWidget);
      // पुल्लिंग रूप कहीं नहीं बचना चाहिए
      expect(find.textContaining('गोत्रोत्पन्नः'), findsNothing);
    });

    testWidgets('पुरुष यजमान का संकल्प पुल्लिंग में ही रहता है',
        (tester) async {
      await settings.setYajman(
        name: 'चन्दन सिंह',
        gotra: 'कश्यप',
        yajaman: Yajaman.purush,
      );
      await jaoSankalpPar(tester);
      await scrollTak(tester, find.text('पूरा संकल्प'));

      expect(find.textContaining('गोत्रोत्पन्नः'), findsOneWidget);
      expect(find.textContaining('गोत्रोत्पन्ना '), findsNothing);
    });

    // ── A5: जगह किस तरह की ───────────────────────────────────────

    testWidgets('साधारण शहर पर "क्षेत्रे" नहीं, "नाम्नि नगरे" आता है',
        (tester) async {
      await settings.setYajman(name: 'चन्दन सिंह', gotra: 'कश्यप');
      await settings.setSthanPrakar(SthanPrakar.nagar);
      await jaoSankalpPar(tester);
      await scrollTak(tester, find.text('पूरा संकल्प'));

      expect(find.textContaining('नाम्नि नगरे'), findsOneWidget);
      expect(find.textContaining('क्षेत्रे'), findsNothing);
    });

    testWidgets('गाँव चुनने पर "ग्रामे" आता है', (tester) async {
      await settings.setYajman(name: 'चन्दन सिंह', gotra: 'कश्यप');
      await settings.setSthanPrakar(SthanPrakar.gram);
      await jaoSankalpPar(tester);
      await scrollTak(tester, find.text('पूरा संकल्प'));

      expect(find.textContaining('नाम्नि ग्रामे'), findsOneWidget);
    });
  });

  group('गोत्र चुपचाप नहीं भरता — A12', () {
    // पहले ऐप डिफ़ॉल्ट "कश्यप" भर देता था और यूज़र को पता ही नहीं
    // चलता था। भरना ग़लत नहीं था — बिना बताए भरना ग़लत था।

    testWidgets('नया यूज़र — गोत्र के चिप्स पहले से नहीं दिखते',
        (tester) async {
      await tester.pumpWidget(app(NaamPoochho(onDone: () {})));
      await tester.pumpAndSettle();

      expect(find.text('गोत्र पता है'), findsOneWidget);
      expect(find.text('पता नहीं'), findsOneWidget);
      // "पता नहीं" डिफ़ॉल्ट है, इसलिए चुनने वाले चिप्स नहीं दिखने चाहिए
      expect(find.widgetWithText(ChoiceChip, 'भारद्वाज'), findsNothing);
    });

    testWidgets('"पता नहीं" पर वजह और शास्त्र-वचन दोनों दिखते हैं',
        (tester) async {
      await tester.pumpWidget(app(NaamPoochho(onDone: () {})));
      await tester.pumpAndSettle();

      expect(find.textContaining('कश्यप गोत्र" बोला जाएगा'), findsOneWidget);
      expect(find.textContaining('गोत्रस्य त्वपरिज्ञाने'), findsOneWidget);
      expect(find.textContaining('हेमाद्रि चन्द्रिका'), findsOneWidget);
    });

    testWidgets('"गोत्र पता है" चुनने पर सूची खुलती है', (tester) async {
      await tester.pumpWidget(app(NaamPoochho(onDone: () {})));
      await tester.pumpAndSettle();

      await tester.tap(find.text('गोत्र पता है'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ChoiceChip, 'भारद्वाज'), findsOneWidget);
      expect(find.textContaining('गोत्रस्य त्वपरिज्ञाने'), findsNothing);
    });

    test('पुराने यूज़र से दोबारा नहीं पूछा जाता', () async {
      // A12 से पहले वाले यूज़र — गोत्र सहेजा है, पर नया झंडा नहीं।
      // उन्होंने ख़ुद चुना था, इसलिए "पता है" माना जाए।
      SharedPreferences.setMockInitialValues({'gotra': 'भारद्वाज'});
      await settings.load();
      expect(settings.gotraPataHai, isTrue);
      expect(settings.gotra, 'भारद्वाज');
    });

    test('बिल्कुल नए यूज़र से पूछा जाता है', () async {
      SharedPreferences.setMockInitialValues({});
      await settings.load();
      expect(settings.gotraPataHai, isFalse);
    });
  });

  group('जगह का प्रकार शहर के नाम से अपने आप — A5', () {
    test('तीर्थ अपने आप पहचाने जाते हैं, पूछना नहीं पड़ता', () {
      expect(sthanPrakarForCity('वाराणसी'), SthanPrakar.kshetra);
      expect(sthanPrakarForCity('प्रयागराज'), SthanPrakar.kshetra);
      expect(sthanPrakarForCity('हरिद्वार'), SthanPrakar.kshetra);
    });

    test('साधारण शहर नगर ही रहते हैं', () {
      expect(sthanPrakarForCity('दिल्ली'), SthanPrakar.nagar);
      expect(sthanPrakarForCity('इंदौर'), SthanPrakar.nagar);
      // सूची में न हो तो भी नगर — यही सुरक्षित डिफ़ॉल्ट है
      expect(sthanPrakarForCity('गुड़गाँव'), SthanPrakar.nagar);
    });

    test('हर तीर्थ ऐप की शहर-सूची में सचमुच मौजूद है', () {
      // वरना सूची बेकार पड़ी रहेगी और किसी को कुछ पता नहीं चलेगा
      for (final tirtha in tirthaKshetras) {
        expect(
          indianCities.any((c) => c.name == tirtha),
          isTrue,
          reason: '$tirtha शहर-सूची में नहीं है',
        );
      }
    });
  });

  group('वो बग जो पिछली बार सिर्फ़ फ़ोन पर मिला था', () {
    // 21 अगस्त 2026: `TextEditingController` पर listener न होने से
    // "संकल्प बनाइए" बटन नाम भरने पर भी बंद रहता था। यह जाँच उसी को
    // पकड़ती है — अब वो दोबारा नहीं लौट सकता।

    // ⚠️ A3 + A5 के बाद यह पन्ना लंबा हो गया — ListView में नाम का खाना
    // और "संकल्प बनाइए" बटन एक साथ बने ही नहीं रहते। इसलिए नीचे जाकर
    // बटन देखो, और नाम भरने से पहले ऊपर लौटो।
    Future<void> scrollBy(WidgetTester tester, double dy) async {
      await tester.drag(find.byType(ListView), Offset(0, dy));
      await tester.pumpAndSettle();
    }

    Future<FilledButton> sankalpButton(WidgetTester tester) async {
      final finder = find.widgetWithText(FilledButton, 'संकल्प बनाइए');
      for (var i = 0; i < 8 && finder.evaluate().isEmpty; i++) {
        await scrollBy(tester, -250);
      }
      return tester.widget<FilledButton>(finder);
    }

    Future<void> naamBharo(WidgetTester tester, String naam) async {
      final finder = find.byType(TextField);
      for (var i = 0; i < 8 && finder.evaluate().isEmpty; i++) {
        await scrollBy(tester, 250);
      }
      await tester.enterText(finder.first, naam);
      await tester.pumpAndSettle();
    }

    testWidgets('नाम ख़ाली हो तो बटन बंद, नाम भरते ही चालू', (tester) async {
      await tester.pumpWidget(app(NaamPoochho(onDone: () {})));
      await tester.pumpAndSettle();

      expect((await sankalpButton(tester)).onPressed, isNull,
          reason: 'ख़ाली नाम पर बंद होना चाहिए');

      await naamBharo(tester, 'चन्दन सिंह');

      expect((await sankalpButton(tester)).onPressed, isNotNull,
          reason: 'नाम भरने पर बटन चालू हो जाना चाहिए — यही वो बग था');
    });

    testWidgets('सिर्फ़ खाली जगह भरने से बटन चालू नहीं होता', (tester) async {
      await tester.pumpWidget(app(NaamPoochho(onDone: () {})));
      await tester.pumpAndSettle();

      await naamBharo(tester, '   ');

      expect((await sankalpButton(tester)).onPressed, isNull);
    });
  });
}
