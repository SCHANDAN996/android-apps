import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/more_screen.dart';
import 'package:vidhivat/screens/paath_list_screen.dart';
import 'package:vidhivat/screens/paath_screen.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/vidhi/paath.dart';

/// चालीसा और आरती वाले section की जाँच — उँगली चलाकर (→ D-039)।
void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await settings.load();
  });

  Widget app(Widget home) => MaterialApp(
        theme: VidhivatTheme.dark(),
        home: home,
      );

  void phoneNaap(WidgetTester tester, {double width = 360}) {
    tester.view.physicalSize = Size(width * 3, 800 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  /// किसी चीज़ तक स्क्रॉल करो।
  ///
  /// ⚠️ क़दम 500 का है, 160 का नहीं। हनुमान चालीसा का पन्ना **10,000px से
  /// ज़्यादा लंबा** है (43 पद × पाठ + रोमन + अर्थ)। 160 के क़दम से
  /// `scrollUntilVisible` का डिफ़ॉल्ट बजट (50 × 160 = 8000px) आख़िरी पदों
  /// तक पहुँचता ही नहीं और "Bad state: No element" देता है — जो देखने में
  /// widget गायब होने जैसा लगता है, पर असल में बजट ख़त्म होना है।
  Future<void> scrollTak(WidgetTester tester, Finder tak) async {
    await tester.scrollUntilVisible(
      tak,
      500,
      scrollable: find
          .descendant(of: find.byType(ListView), matching: find.byType(Scrollable))
          .first,
    );
    await tester.pumpAndSettle();
  }

  group('चालीसा और आरती की सूची', () {
    testWidgets('सूची खुलती है और दोनों तरह के पाठ दिखते हैं', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const PaathListScreen()));
      await tester.pumpAndSettle();

      expect(find.text('श्री हनुमान चालीसा'), findsOneWidget);
      expect(find.text('श्री गणेश जी की आरती'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('छन्नी से सिर्फ़ आरती रह जाती हैं', (tester) async {
      // चालीसा और आरती अलग tab नहीं, एक ही सूची में छन्नी (→ D-039)।
      phoneNaap(tester);
      await tester.pumpWidget(app(const PaathListScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ChoiceChip, 'आरती'));
      await tester.pumpAndSettle();

      expect(find.text('श्री हनुमान चालीसा'), findsNothing);
      expect(find.text('श्री गणेश जी की आरती'), findsOneWidget);
    });

    testWidgets('पाठ दबाने पर खुलता है', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const PaathListScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('श्री हनुमान चालीसा'));
      await tester.pumpAndSettle();
      expect(find.byType(PaathScreen), findsOneWidget);
    });
  });

  group('पाठ पढ़ने वाला पन्ना', () {
    testWidgets('चालीसा के पद पाठ के साथ दिखते हैं', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const PaathScreen(id: 'hanuman_chalisa')));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.text('दोहा १'));
      expect(find.textContaining('श्रीगुरु चरन सरोज रज'), findsOneWidget);

      await scrollTak(tester, find.text('चौपाई 1'));
      expect(find.textContaining('जय हनुमान ज्ञान गुन सागर'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('डिफ़ॉल्ट रूप से सिर्फ़ पाठ दिखता है, अर्थ नहीं',
        (tester) async {
      // तीनों (देवनागरी + रोमन + अर्थ) एक साथ दिखाने पर पन्ना 33,000px
      // से ज़्यादा लंबा हो जाता है — फ़ोन पर ~45 स्क्रीन। पाठ करते वक़्त
      // सिर्फ़ देवनागरी चाहिए।
      phoneNaap(tester);
      await tester.pumpWidget(app(const PaathScreen(id: 'hanuman_chalisa')));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.text('चौपाई 1'));
      expect(find.textContaining('जय हनुमान ज्ञान गुन सागर'), findsOneWidget);
      // रोमन और अर्थ छिपे रहने चाहिए
      expect(find.textContaining('jai hanumaan gyaan'), findsNothing);
      expect(find.textContaining('ज्ञान और गुणों के सागर'), findsNothing);
    });

    testWidgets('"अर्थ दिखाएँ" दबाने पर रोमन और अर्थ आ जाते हैं',
        (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const PaathScreen(id: 'hanuman_chalisa')));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.text('अर्थ दिखाएँ'));
      await tester.tap(find.text('अर्थ दिखाएँ'));
      await tester.pumpAndSettle();

      // बटन का लेबल तुरंत बदल जाना चाहिए — बाद में स्क्रॉल करने पर वो
      // तह से बाहर चला जाता है, इसलिए यहीं देख लो।
      expect(find.text('सिर्फ़ पाठ'), findsOneWidget);

      await scrollTak(tester, find.text('चौपाई 1'));
      expect(find.textContaining('jai hanumaan gyaan'), findsOneWidget);
      expect(find.textContaining('ज्ञान और गुणों के सागर'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('पूरा भरा पाठ बिना किसी चेतावनी के खुलता है', (tester) async {
      // ⚠️ यह जाँच पहले उल्टी थी — 43 / 43 पद भरे होने पर भी "जाँच बाकी
      // है (43 / 43 पद भरे हैं)" दिखना ज़रूरी माना गया था।
      //
      // फ़ोन पर देखने से पकड़ा गया (4 सित 2026): वो डिब्बा यूज़र से कह
      // रहा था *"सब कुछ मौजूद है, पर भरोसा मत करो"* — और उससे वो कुछ कर
      // भी नहीं सकता था। चेतावनी अब सिर्फ़ वहाँ जहाँ पाठ सचमुच **कम** है
      // (→ D-042)।
      phoneNaap(tester);
      await tester.pumpWidget(app(const PaathScreen(id: 'hanuman_chalisa')));
      await tester.pumpAndSettle();

      expect(find.text('जाँच बाकी है'), findsNothing);
      expect(find.text('यह पाठ अभी अधूरा है'), findsNothing);
      expect(find.text('पाठ अभी जोड़ा नहीं गया'), findsNothing);
    });

    testWidgets('आधा भरा पाठ — चेतावनी दिखती है, गिनती के साथ',
        (tester) async {
      // यही असली चेतावनी है, और यह ग़ायब नहीं होनी चाहिए (→ D-022)।
      phoneNaap(tester);
      await tester.pumpWidget(app(PaathReader(paath: _adhuraPaath())));
      await tester.pumpAndSettle();

      expect(find.text('यह पाठ अभी अधूरा है'), findsOneWidget);
      expect(find.textContaining('2 में से 1 पद'), findsOneWidget);
      expect(find.text('पाठ अभी जोड़ा नहीं गया'), findsNothing);
    });

    testWidgets('पाठ अभी नहीं जोड़ा गया तो वही साफ़ लिखा दिखता है',
        (tester) async {
      // ⚠️ यह जाँच पहले असली `ganesh_aarti` पर चलती थी, इस भरोसे पर कि वो
      // ख़ाली पड़ी रहेगी। आरतियों का पाठ भरते ही टूट गई — जाँच कंटेंट की
      // हालत से बँधी नहीं होनी चाहिए। इसलिए अब सीधे `PaathReader` को एक
      // ख़ाली पाठ देकर देखते हैं; शाखा वही रहती है, असली फ़ाइलें आज़ाद।
      phoneNaap(tester);
      await tester.pumpWidget(app(PaathReader(paath: _khaaliPaath())));
      await tester.pumpAndSettle();

      expect(find.text('पाठ अभी जोड़ा नहीं गया'), findsOneWidget);
      expect(find.text('जाँच बाकी है'), findsNothing);
    });

    testWidgets('गणेश आरती का पाठ आ गया है, और चुपचाप खुलता है',
        (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const PaathScreen(id: 'ganesh_aarti')));
      await tester.pumpAndSettle();

      expect(find.text('पाठ अभी जोड़ा नहीं गया'), findsNothing);
      expect(find.text('जाँच बाकी है'), findsNothing);
      // पद lazy list में नीचे हैं — बिना स्क्रॉल किए बने ही नहीं होते।
      await scrollTak(tester, find.textContaining('जय गणेश'));
      expect(find.textContaining('जय गणेश'), findsWidgets);
    });

    testWidgets('रचयिता और भाषा दिखती है — कॉपीराइट के लिए ज़रूरी',
        (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const PaathScreen(id: 'hanuman_chalisa')));
      await tester.pumpAndSettle();

      expect(find.textContaining('गोस्वामी तुलसीदास'), findsWidgets);
      expect(find.textContaining('अवधी'), findsWidgets);
    });

    testWidgets('आरती में आग वाली सावधानी लिखी है', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const PaathScreen(id: 'ganesh_aarti')));
      await tester.pumpAndSettle();

      await scrollTak(tester, find.textContaining('आग के पास ध्यान रखें'));
      expect(find.textContaining('आग के पास ध्यान रखें'), findsOneWidget);
    });

    testWidgets('320dp पर भी कुछ टूटता नहीं', (tester) async {
      phoneNaap(tester, width: 320);
      await tester.pumpWidget(app(const PaathScreen(id: 'hanuman_chalisa')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '320dp पर overflow');
    });
  });

  group('"अधिक" से पहुँच', () {
    testWidgets('चालीसा और आरती वाला रास्ता वहाँ मौजूद है', (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const MoreScreen()));
      await tester.pumpAndSettle();

      // कार्ड अब "पूजा के साधन" में नहीं, अपने "पढ़ने के लिए" वाले
      // हिस्से में है — यानी तह से नीचे (→ D-051)।
      await scrollTak(tester, find.text('चालीसा और आरती'));
      expect(find.text('चालीसा और आरती'), findsOneWidget);
      await tester.tap(find.text('चालीसा और आरती'));
      await tester.pumpAndSettle();
      expect(find.byType(PaathListScreen), findsOneWidget);
    });
  });
}

/// एक ऐसा पाठ जिसमें जगह बनी है पर शब्द नहीं आए — सिर्फ़ जाँच के लिए।
/// आधा भरा पाठ — एक पद आया, एक बाक़ी। असली फ़ाइलों से बाँधने पर यह जाँच
/// कंटेंट भरते ही टूट जाती, इसलिए यहीं अपना बनाया।
Paath _adhuraPaath() => Paath.parse('adhura.json', '''
{
  "schemaVersion": 1,
  "id": "adhuri_aarti",
  "naam": "अधूरी आरती",
  "upnaam": [],
  "prakar": "aarti",
  "devta": "कोई देवता",
  "rachnakar": "पारंपरिक",
  "bhasha": "हिंदी",
  "parichay": "सिर्फ़ जाँच के लिए।",
  "kabPadhein": "कभी भी",
  "kaisePadhein": "खड़े होकर",
  "khand": [
    {"shirshak": "पहला पद", "dev": "जय देव जय देव", "roman": "", "arth": "",
     "audio": "", "sthiti": "draft"},
    {"shirshak": "दूसरा पद", "dev": "", "roman": "", "arth": "",
     "audio": "", "sthiti": "khaali"}
  ],
  "bharosa": "kam",
  "strot": {"paddhati": "जाँच", "kshetra": "जाँच", "note": ""},
  "jaanch": {"panditNaam": "", "tarikh": "", "paas": false}
}
''');

Paath _khaaliPaath() => Paath.parse('jaanch.json', '''
{
  "schemaVersion": 1,
  "id": "jaanch_aarti",
  "naam": "जाँच वाली आरती",
  "upnaam": [],
  "prakar": "aarti",
  "devta": "कोई देवता",
  "rachnakar": "पारंपरिक",
  "bhasha": "हिंदी",
  "parichay": "सिर्फ़ जाँच के लिए।",
  "kabPadhein": "कभी भी",
  "kaisePadhein": "खड़े होकर",
  "khand": [
    {"shirshak": "पूरी आरती", "dev": "", "roman": "", "arth": "",
     "audio": "", "sthiti": "khaali"}
  ],
  "bharosa": "kam",
  "strot": {"paddhati": "जाँच", "kshetra": "जाँच", "note": ""},
  "jaanch": {"panditNaam": "", "tarikh": "", "paas": false}
}
''');
