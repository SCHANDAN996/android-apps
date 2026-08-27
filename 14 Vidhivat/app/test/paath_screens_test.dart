import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/more_screen.dart';
import 'package:vidhivat/screens/paath_list_screen.dart';
import 'package:vidhivat/screens/paath_screen.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';

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

  Future<void> scrollTak(WidgetTester tester, Finder tak) async {
    await tester.scrollUntilVisible(
      tak,
      160,
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
    testWidgets('चालीसा के 43 पद और ख़ाली होने की चेतावनी दिखती है',
        (tester) async {
      phoneNaap(tester);
      await tester.pumpWidget(app(const PaathScreen(id: 'hanuman_chalisa')));
      await tester.pumpAndSettle();

      // पाठ अभी नहीं आया — यह सबसे ऊपर साफ़ लिखा होना चाहिए।
      expect(find.text('पाठ अभी जोड़ा नहीं गया'), findsOneWidget);
      expect(find.textContaining('43 पदों की जगह बनी हुई है'), findsOneWidget);

      await scrollTak(tester, find.text('दोहा १'));
      expect(find.text('दोहा १'), findsOneWidget);
      await scrollTak(tester, find.text('चौपाई 40'));
      expect(find.text('चौपाई 40'), findsOneWidget);
      expect(tester.takeException(), isNull);
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

      expect(find.text('चालीसा और आरती'), findsOneWidget);
      await tester.tap(find.text('चालीसा और आरती'));
      await tester.pumpAndSettle();
      expect(find.byType(PaathListScreen), findsOneWidget);
    });
  });
}
