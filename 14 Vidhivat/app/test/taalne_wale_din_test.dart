// "कौन से दिन टालने हैं" — ऐप की तरफ़ का पहरा (→ D-059)।
//
// ⚠️ इन जाँचों का सबसे बड़ा काम **रोकना** है, दिखाना नहीं। D-019 ने
// मुहूर्त जान-बूझकर रोका था; यह डिब्बा उसी की सीमा पर खड़ा है। जिस दिन
// यह "यह दिन शुभ है" कहने लगेगा, उसी दिन वो चीज़ बन जाएगा जिससे बचना
// था — और तब कोई पंडित पकड़ लेगा।
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/vidhi_screen.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/vidhi/bhandar.dart';
import 'package:vidhivat/widgets/taalne_wale_din_card.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await settings.load();
  });

  Widget app(Widget home) => ListenableBuilder(
        listenable: settings,
        builder: (context, _) =>
            MaterialApp(theme: VidhivatTheme.dark(), home: home),
      );

  void phone(WidgetTester tester, {double width = 400, double height = 2400}) {
    tester.view.physicalSize = Size(width * 3, height * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('किन पूजाओं पर दिखता है', () {
    // तारीख़ चुननी पड़ती है → दिखे। तारीख़ पंचांग तय करता है → न दिखे।
    test('सिर्फ़ चार पूजाओं में तारीख़ ख़ुद चुननी पड़ती है', () async {
      final sab = await vidhiBhandar.suchi();
      final chunni = <String>[];
      for (final e in sab) {
        final v = await vidhiBhandar.vidhi(e.id);
        if (v.kabKarein.tarikhKhudChunni) chunni.add(v.naam);
      }
      expect(chunni, hasLength(4), reason: 'मिले: $chunni');
      expect(chunni, contains('गृह प्रवेश'));
      expect(chunni, contains('मुंडन संस्कार'));
      expect(chunni, contains('उपनयन (जनेऊ) संस्कार'));
      expect(chunni, contains('वाहन पूजा'));
    });

    test('दीपावली पर नहीं — उसकी तारीख़ पंचांग तय करता है', () async {
      final v = await vidhiBhandar.vidhi('lakshmi_poojan');
      expect(v.kabKarein.tarikhKhudChunni, isFalse);
    });

    testWidgets('गृह प्रवेश के पन्ने पर डिब्बा आता है', (tester) async {
      phone(tester);
      await tester.pumpWidget(app(const VidhiScreen(id: 'grih_pravesh')));
      await tester.pumpAndSettle();
      expect(find.byType(TaalneWaleDinCard), findsOneWidget);
    });

    testWidgets('सत्यनारायण के पन्ने पर नहीं आता', (tester) async {
      phone(tester);
      await tester.pumpWidget(app(const VidhiScreen(id: 'satyanarayan')));
      await tester.pumpAndSettle();
      expect(find.byType(TaalneWaleDinCard), findsNothing);
    });
  });

  group('⛔ यह मुहूर्त होने का दावा नहीं करता', () {
    testWidgets('साफ़ लिखा है कि ऐप शुभ दिन नहीं बताता', (tester) async {
      phone(tester);
      await tester.pumpWidget(app(const VidhiScreen(id: 'grih_pravesh')));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('ऐप शुभ दिन नहीं बताता'),
        findsOneWidget,
        reason: 'इस पंक्ति के बिना डिब्बा मुहूर्त होने का दावा करने लगता है',
      );
      expect(find.textContaining('पंडित जी'), findsWidgets);
    });

    /// स्रोत पढ़कर की जाने वाली जाँच — वही तरीक़ा जो दक्षिणा पर है।
    ///
    /// ⚠️ यह सिर्फ़ **string** पढ़ती है, टिप्पणियाँ नहीं — क्योंकि
    /// टिप्पणियों में ये वाक्य जान-बूझकर लिखे हैं ("यह मत लिखना")।
    test('स्क्रीन पर कोई शुभ-दिन वाला वाक्य नहीं जाता', () {
      final src = File('lib/widgets/taalne_wale_din_card.dart')
          .readAsStringSync();
      final shabd = RegExp("'([^']*)'").allMatches(src).map((m) => m[1]!).join(' ');

      for (final manahi in [
        'यह दिन शुभ',
        'शुभ दिन है',
        'इस दिन करें',
        'सबसे अच्छा दिन',
        'मुहूर्त निकाला',
      ]) {
        expect(shabd.contains(manahi), isFalse,
            reason: '"$manahi" — यह डिब्बा तारीख़ नहीं सुझाता (→ D-019)');
      }
    });

    test('साफ़ दिनों की गिनती कहीं नहीं छपती', () {
      // "बाक़ी 19 दिन ठीक हैं" पढ़ते ही वो सुझाव बन जाता है।
      final src = File('lib/widgets/taalne_wale_din_card.dart')
          .readAsStringSync();
      final shabd = RegExp("'([^']*)'").allMatches(src).map((m) => m[1]!).join(' ');
      expect(shabd.contains('दिन ठीक'), isFalse);
      expect(shabd.contains('बाक़ी'), isFalse);
    });
  });

  group('जो कहता है वो सच कहता है', () {
    testWidgets('गिनती और वजहें दोनों मिलती हैं', (tester) async {
      phone(tester);
      await tester.pumpWidget(app(const VidhiScreen(id: 'grih_pravesh')));
      await tester.pumpAndSettle();

      // ⚠️ पूरी सूची ℹ के पीछे है (→ D-056) — पन्ने पर सिर्फ़ गिनती।
      expect(find.text('कौन से दिन, और क्यों'), findsOneWidget);

      await tester.ensureVisible(find.text('कौन से दिन, और क्यों'));
      await tester.tap(find.text('कौन से दिन, और क्यों'));
      await tester.pumpAndSettle();

      // शीट में हर वजह अपने नाम और गिनती के साथ आती है।
      expect(find.textContaining('दिन'), findsWidgets);

      // ⚠ शीट आधी ऊँचाई पर खुलती है और उसकी ListView आलसी है —
      // नीचे की पंक्तियाँ बनी ही नहीं होतीं।
      await tester.dragUntilVisible(
        find.textContaining('पंचक और गंडमूल पर हर घर'),
        find.byType(ListView).last,
        const Offset(0, -80),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('पंचक और गंडमूल पर हर घर'),
        findsOneWidget,
        reason: 'जिन पर मतभेद है, वह बात शीट के आख़िर में लिखी रहनी चाहिए',
      );
    });
  });
}
