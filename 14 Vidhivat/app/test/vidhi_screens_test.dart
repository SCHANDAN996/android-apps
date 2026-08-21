import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/main.dart';
import 'package:vidhivat/screens/sankalp_screen.dart';
import 'package:vidhivat/screens/vidhi_list_screen.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';

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

  Widget app(Widget home) => MaterialApp(
        theme: VidhivatTheme.light(),
        home: home,
      );

  /// जाँच की स्क्रीन को असली फ़ोन के नाप पर ले आओ।
  ///
  /// डिफ़ॉल्ट 800×600 है — वो किसी फ़ोन जैसा नहीं। vivo V2553 (जिस पर
  /// ऐप जाँचा जाता है) 1080×2400 का है, यानी 360×800 dp। इसी नाप पर
  /// जाँचने से "बटन तह के नीचे चला गया" जैसी बातें यहीं पकड़ में आती हैं।
  void phoneNaap(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  /// किसी चीज़ तक स्क्रॉल करो — जैसे यूज़र उँगली से करता है।
  Future<void> scrollTak(WidgetTester tester, Finder tak) async {
    await tester.scrollUntilVisible(
      tak,
      160,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  /// सूची से सत्यनारायण खोलो।
  Future<void> kholoSatyanarayan(WidgetTester tester) async {
    phoneNaap(tester);
    await tester.pumpWidget(app(const VidhiListScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('सत्यनारायण पूजा और कथा'));
    await tester.pumpAndSettle();
  }

  group('नीचे की पट्टी — अब छह पन्ने हैं', () {
    // विधि जुड़ने से पट्टी में पाँच की जगह छह पन्ने हो गए। Material की
    // सलाह पाँच तक की है, इसलिए यह देखना ज़रूरी है कि कुछ टूट तो नहीं
    // रहा और सबसे लंबा नाम ("चौघड़िया") अब भी दिखता है।

    testWidgets('छहों पन्ने हैं और विधि सबसे पहले है', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const HomeShell()));
      await tester.pumpAndSettle();

      final patti = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(patti.destinations, hasLength(6));
      expect(patti.selectedIndex, 0);

      for (final naam in [
        'विधि',
        'आज',
        'कैलेंडर',
        'संकल्प',
        'चौघड़िया',
        'सेटिंग',
      ]) {
        expect(find.text(naam), findsWidgets, reason: '"$naam" पट्टी में नहीं');
      }
    });

    testWidgets('विधि वाला पन्ना ही सबसे पहले खुलता है', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const HomeShell()));
      await tester.pumpAndSettle();

      expect(find.text('पूजा विधि'), findsOneWidget);
      expect(find.text('सत्यनारायण पूजा और कथा'), findsOneWidget);
    });
  });

  group('पूजाओं की सूची', () {
    testWidgets('सूची खुलती है और तैयार पूजा दिखती है', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const VidhiListScreen()));
      await tester.pumpAndSettle();

      expect(find.text('पूजा विधि'), findsOneWidget);
      expect(find.text('सत्यनारायण पूजा और कथा'), findsOneWidget);
    });

    testWidgets('जो तैयार नहीं उस पर "जल्द आएगी" लिखा है और वो दबती नहीं',
        (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const VidhiListScreen()));
      await tester.pumpAndSettle();

      expect(find.text('जल्द आएगी'), findsWidgets);

      // बंद पूजा पर टैप करने से कुछ नहीं खुलना चाहिए।
      await tester.tap(find.text('गणेश पूजन'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('पूजा विधि'), findsOneWidget);
    });
  });

  group('पूजा का विवरण', () {
    testWidgets('विवरण खुलता है और ज़रूरी बातें दिखती हैं', (tester) async {
      await kholoSatyanarayan(tester);

      // ये दोनों नीचे की पट्टी में हैं — बिना स्क्रॉल किए दिखने चाहिए।
      expect(find.text('सामग्री'), findsOneWidget);
      expect(find.text('विधि शुरू करें'), findsOneWidget);

      // 360×800 dp पर पहली तह में सिर्फ़ परिचय और पहली चेतावनी आती है —
      // बाक़ी के लिए यूज़र को स्क्रॉल करना पड़ता है, इसलिए जाँच भी करती है।
      await scrollTak(tester, find.text('एक नज़र में'));
      expect(find.text('एक नज़र में'), findsOneWidget);

      await scrollTak(tester, find.text('कदम'));
      expect(find.text('कदम'), findsWidgets);

      await scrollTak(tester, find.text('यह विधि कहाँ से आई'));
      expect(find.text('यह विधि कहाँ से आई'), findsOneWidget);
    });

    testWidgets('पंडित जी से पास न होने की चेतावनी दिखती है', (tester) async {
      // यह चुपचाप ग़ायब नहीं होनी चाहिए — पूरा भरोसा इसी पर टिका है।
      await kholoSatyanarayan(tester);
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
      await tester.tap(find.text('सामग्री'));
      await tester.pumpAndSettle();

      expect(find.textContaining('जुट गईं'), findsOneWidget);
      expect(settings.samagriTicks('satyanarayan'), isEmpty);

      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();

      expect(settings.samagriTicks('satyanarayan'), hasLength(1));
      expect(find.text('1 / 44 जुट गईं'), findsOneWidget);
    });

    testWidgets('"सिर्फ़ ज़रूरी" से वैकल्पिक चीज़ें छँट जाती हैं',
        (tester) async {
      await kholoSatyanarayan(tester);
      await tester.tap(find.text('सामग्री'));
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
      await tester.tap(find.text('सामग्री'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();
      expect(settings.samagriTicks('satyanarayan'), hasLength(1));

      await tester.tap(find.byIcon(Icons.restart_alt));
      await tester.pumpAndSettle();
      expect(settings.samagriTicks('satyanarayan'), isEmpty);
    });
  });

  group('विधि प्लेयर', () {
    Future<void> kholoPlayer(WidgetTester tester) async {
      await kholoSatyanarayan(tester);
      await tester.tap(find.text('विधि शुरू करें'));
      await tester.pumpAndSettle();
    }

    testWidgets('पहला कदम खुलता है और गिनती सही दिखती है', (tester) async {
      await kholoPlayer(tester);

      expect(find.text('1 / 14'), findsOneWidget);
      expect(find.text('तैयारी'), findsOneWidget);
      expect(find.text('आगे'), findsOneWidget);
    });

    testWidgets('पहले कदम पर "पीछे" बंद रहता है', (tester) async {
      await kholoPlayer(tester);
      final peeche = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'पीछे'),
      );
      expect(peeche.onPressed, isNull);
    });

    testWidgets('"आगे" से अगला कदम आता है, "पीछे" से वापस', (tester) async {
      await kholoPlayer(tester);

      await tester.tap(find.text('आगे'));
      await tester.pumpAndSettle();
      expect(find.text('2 / 14'), findsOneWidget);

      await tester.tap(find.text('पीछे'));
      await tester.pumpAndSettle();
      expect(find.text('1 / 14'), findsOneWidget);
    });

    testWidgets('आख़िरी कदम पर "पूजा पूरी हुई" लिखा आता है', (tester) async {
      await kholoPlayer(tester);

      for (var i = 0; i < 13; i++) {
        await tester.tap(find.text('आगे'));
        await tester.pumpAndSettle();
      }

      expect(find.text('14 / 14'), findsOneWidget);
      expect(find.text('पूजा पूरी हुई'), findsOneWidget);
      expect(find.text('आगे'), findsNothing);
    });

    testWidgets('जिस कदम का मंत्र ख़ाली है वहाँ बना हुआ मंत्र नहीं दिखता',
        (tester) async {
      // अंदाज़े से मंत्र लिखना इस प्रोजेक्ट की सबसे बड़ी मनाही है।
      await kholoPlayer(tester);

      await tester.tap(find.text('आगे')); // 2 — चौकी सजाना
      await tester.pumpAndSettle();
      await tester.tap(find.text('आगे')); // 3 — आचमन, यहाँ ख़ाली मंत्र है
      await tester.pumpAndSettle();

      expect(find.text('मंत्र'), findsNothing);
      expect(
        find.textContaining('मंत्र अभी ऐप में नहीं जोड़ा गया'),
        findsOneWidget,
      );
    });
  });

  group('संकल्प वाला कदम — ऐप का सबसे बड़ा फ़र्क़', () {
    Future<void> jaoSankalpPar(WidgetTester tester) async {
      await kholoSatyanarayan(tester);
      await tester.tap(find.text('विधि शुरू करें'));
      await tester.pumpAndSettle();
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('आगे'));
        await tester.pumpAndSettle();
      }
    }

    testWidgets('नाम न भरा हो तो भरने का बटन दिखता है', (tester) async {
      await jaoSankalpPar(tester);

      expect(find.text('4 / 14'), findsOneWidget);
      expect(find.text('संकल्प'), findsOneWidget);
      expect(find.text('नाम और गोत्र भरिए'), findsOneWidget);
    });

    testWidgets('नाम भरा हो तो पूरा संकल्प पंचांग से बनकर आ जाता है',
        (tester) async {
      await settings.setYajman(name: 'चन्दन सिंह', gotra: 'कश्यप');
      await jaoSankalpPar(tester);

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
