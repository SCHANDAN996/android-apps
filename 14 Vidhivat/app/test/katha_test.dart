// कथा — सत्यनारायण के पाँच अध्याय (→ D-060)।
//
// ⚠️ इन जाँचों का सबसे बड़ा काम यह है कि **"भावार्थ" वाली बात कभी न
// छिपे।** कथा हिंदी में कही गई है, शब्दशः संस्कृत पाठ नहीं — और यूज़र
// की पोथी से फ़र्क़ मिलेगा। वो बात स्क्रीन पर होनी ही चाहिए, वरना ऐप
// वो दावा कर रहा होगा जो वो कर नहीं सकता।
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/vidhi_player_screen.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/vidhi/bhandar.dart';
import 'package:vidhivat/vidhi/katha.dart';
import 'package:vidhivat/vidhi/vidhi.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await settings.load();
    await settings.setYajman(name: 'चन्दन', gotra: 'कश्यप');
  });

  group('कथा की फ़ाइल', () {
    late Katha katha;

    setUp(() async {
      katha = await kathaBhandar.katha('satyanarayan');
    });

    test('पाँचों अध्याय हैं, और क्रम में हैं', () {
      expect(katha.adhyayKul, 5);
      for (var i = 0; i < 5; i++) {
        expect(katha.adhyay[i].kram, i + 1);
      }
    });

    test('हर अध्याय में शीर्षक, सार और पूरी कथा है', () {
      for (final a in katha.adhyay) {
        expect(a.shirshak.trim(), isNotEmpty);
        expect(a.saar.trim(), isNotEmpty);
        // एक अध्याय आधा-अधूरा नहीं हो सकता — यह कथा है, सार नहीं।
        expect(a.gadya.trim().split(RegExp(r'\s+')).length, greaterThan(200),
            reason: '${a.shirshak} बहुत छोटा है');
      }
    });

    test('कथा पूरी है — तीन हज़ार शब्द के आसपास', () {
      final shabd = katha.adhyay
          .map((a) => a.gadya.trim().split(RegExp(r'\s+')).length)
          .reduce((a, b) => a + b);
      expect(shabd, greaterThan(1800), reason: 'मिले $shabd शब्द');
      expect(katha.minute, greaterThan(9),
          reason: 'कथा सुनाने में बीस मिनट के आसपास लगते हैं');
    });

    // ⚠️ यही वो चीज़ है जो इस पूरे काम को ईमानदार रखती है।
    test('रूप "भावार्थ" है, और वो बात साफ़ लिखी है', () {
      expect(katha.roop, KathaRoop.bhavarth);
      expect(katha.roop.batao, contains('शब्दशः संस्कृत पाठ नहीं'));
    });

    test('स्रोत में मूल ग्रंथ का नाम है', () {
      expect(katha.strot, contains('स्कंद पुराण'));
    });

    test('कथा के पाँचों जाने-पहचाने पात्र मौजूद हैं', () {
      final poori = katha.adhyay.map((a) => a.gadya).join(' ');
      for (final naam in [
        'नारद',
        'शतानंद',
        'उल्कामुख',
        'कलावती',
        'लीलावती',
        'तुंगध्वज',
      ]) {
        expect(poori, contains(naam), reason: '$naam कथा में नहीं मिला');
      }
    });

    test('टूटा हुआ क्रम पकड़ा जाता है', () {
      // दूसरा अध्याय छूट जाए तो यूज़र को पता ही नहीं चलेगा।
      expect(
        () => Katha.parse('जाँच', '''
{"id":"x","naam":"क","roop":"bhavarth","strot":"स","kabSunayen":"क",
 "adhyay":[{"kram":1,"shirshak":"अ","gadya":"ग","saar":"स"},
           {"kram":3,"shirshak":"अ","gadya":"ग","saar":"स"}]}'''),
        throwsA(isA<VidhiFormatException>()),
      );
    });
  });

  group('पूजा से जुड़ाव', () {
    test('सत्यनारायण के कथा-कदम पर कथा जुड़ी है', () async {
      final v = await vidhiBhandar.vidhi('satyanarayan');
      final kadam =
          v.charan.where((c) => c.vishesh == CharanVishesh.katha).toList();
      expect(kadam, hasLength(1));
      expect(kadam.first.katha, 'satyanarayan');
    });

    test('हर जुड़ी हुई कथा की फ़ाइल सचमुच मौजूद है', () async {
      for (final e in await vidhiBhandar.suchi()) {
        final v = await vidhiBhandar.vidhi(e.id);
        for (final c in v.charan) {
          if (c.katha.isEmpty) continue;
          // खुल गई तो फ़ाइल है और पढ़ी जा सकती है।
          final k = await kathaBhandar.katha(c.katha);
          expect(k.adhyayKul, greaterThan(0));
        }
      }
    });
  });

  group('प्लेयर में', () {
    Widget app(Widget home) => ListenableBuilder(
          listenable: settings,
          builder: (context, _) =>
              MaterialApp(theme: VidhivatTheme.dark(), home: home),
        );

    Future<void> kathaKadamPar(WidgetTester tester) async {
      tester.view.physicalSize = const Size(400 * 3, 2600 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final v = await vidhiBhandar.vidhi('satyanarayan');
      final index =
          v.charan.indexWhere((c) => c.vishesh == CharanVishesh.katha);
      await tester.pumpWidget(
        app(VidhiPlayerScreen(vidhi: v, initialStepIndex: index)),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('कथा खुलती है, और पहला अध्याय पहले से खुला मिलता है',
        (tester) async {
      await kathaKadamPar(tester);

      expect(find.text('श्री सत्यनारायण व्रत कथा'), findsOneWidget);
      expect(find.textContaining('पहला अध्याय'), findsOneWidget);
      expect(find.textContaining('पाँचवाँ अध्याय'), findsOneWidget);
      // पहला खुला — पढ़ना शुरू करने के लिए एक दबाव भी न लगे।
      expect(find.textContaining('नैमिषारण्य'), findsOneWidget);
      // दूसरा बंद — ⚠️ ऐसा शब्द चुना है जो सिर्फ़ गद्य में है।
      // "शतानंद" अध्याय के शीर्षक में भी है, और शीर्षक हमेशा दिखते हैं।
      expect(find.textContaining('चौगुने'), findsNothing);
    });

    testWidgets('⚠️ "भावार्थ" वाली बात स्क्रीन पर खुली रहती है',
        (tester) async {
      await kathaKadamPar(tester);
      expect(
        find.textContaining('शब्दशः संस्कृत पाठ नहीं'),
        findsOneWidget,
        reason: 'इसके बिना ऐप वो दावा कर रहा होगा जो वो कर नहीं सकता',
      );
    });

    testWidgets('अध्याय दबाने पर खुलता और बंद होता है', (tester) async {
      await kathaKadamPar(tester);

      // ⚠ कथा का पन्ना बहुत लंबा है — दूसरे अध्याय का चिह्न
      // पाँच हज़ार पिक्सल नीचे बैठता है। `ensureVisible` वहाँ तक
      // नहीं पहुँचाता; सचमुच स्क्रॉल करना पड़ता है।
      Future<void> jaao(Finder tak) async {
        await tester.scrollUntilVisible(
          tak,
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
      }

      expect(find.byIcon(Icons.expand_less), findsOneWidget);
      expect(find.byIcon(Icons.expand_more), findsNWidgets(4));

      await jaao(find.byIcon(Icons.expand_more).first);
      await tester.tap(find.byIcon(Icons.expand_more).first);
      await tester.pumpAndSettle();

      // दूसरा अध्याय खुल गया — उसका गद्य अब मिलना चाहिए।
      await jaao(find.textContaining('चौगुने'));
      expect(find.textContaining('चौगुने'), findsOneWidget);
    });

    testWidgets('पुराना "कथा जोड़ी नहीं गई" वाला वाक्य अब नहीं आता',
        (tester) async {
      await kathaKadamPar(tester);
      expect(find.textContaining('कथा का पूरा पाठ अभी ऐप में नहीं'),
          findsNothing);
    });
  });
}
