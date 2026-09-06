import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panchang_engine/panchang_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/calendar_screen.dart';
import 'package:vidhivat/screens/muhurta_screen.dart';
import 'package:vidhivat/screens/puja_completion_screen.dart';
import 'package:vidhivat/screens/vidhi_player_screen.dart';
import 'package:vidhivat/screens/vidhi_screen.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/vidhi/bhandar.dart';
import 'package:vidhivat/widgets/common.dart';
import 'package:vidhivat/widgets/design_system.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await settings.load();
    await settings.setYajman(name: 'चन्दन', gotra: 'कश्यप');
  });

  Widget app(
    Widget home, {
    double textScale = 1,
    bool disableAnimations = false,
  }) =>
      MaterialApp(
        theme: VidhivatTheme.dark(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
            disableAnimations: disableAnimations,
          ),
          child: child!,
        ),
        home: home,
      );

  void phone(WidgetTester tester, double width, {double height = 800}) {
    tester.view.physicalSize = Size(width * 3, height * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('Puja loading state calm design-system presentation रखता है',
      (tester) async {
    phone(tester, 393);
    await tester.pumpWidget(app(const VidhiScreen(id: 'satyanarayan')));

    expect(find.byKey(const Key('vidhivat_loading_state')), findsOneWidget);
    expect(find.text('पूजा की जानकारी खुल रही है'), findsOneWidget);
    expect(find.byType(VidhivatStateView), findsOneWidget);
  });

  testWidgets('Puja error state technical exception नहीं दिखाता',
      (tester) async {
    phone(tester, 393);
    await tester.pumpWidget(app(const VidhiScreen(id: 'missing_puja')));
    await tester.pumpAndSettle();

    expect(find.text('यह पूजा नहीं खुल सकी'), findsOneWidget);
    expect(find.textContaining('missing_puja'), findsNothing);
    expect(find.textContaining('Exception'), findsNothing);
    expect(find.byKey(const Key('vidhivat_message_state')), findsOneWidget);
  });

  testWidgets('Calendar 320dp/2.0x और reduced motion पर selection सुरक्षित है',
      (tester) async {
    phone(tester, 320);
    final now = DateTime.now();
    final day = now.day == 1 ? 2 : 1;
    final finder = find.byKey(
      Key('calendar_day_${now.year}_${now.month}_$day'),
    );

    await tester.pumpWidget(
      app(
        const CalendarScreen(),
        textScale: 2,
        disableAnimations: true,
      ),
    );
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pump();

    expect(
      tester.getSemantics(finder).flagsCollection.isSelected == Tristate.isTrue,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Choghadiya boundary पर lifecycle-safe presentation refresh होता है',
      (tester) async {
    phone(tester, 360);
    final startedAt = DateTime.now();
    final current = currentChoghadiya(startedAt, settings.place)!;

    await tester.pumpWidget(app(const MuhurtaScreen()));
    final currentCard = find.byKey(const Key('current_choghadiya'));
    expect(tester.getSemantics(currentCard).label, contains(current.name));

    final advance =
        current.end.difference(startedAt) + const Duration(seconds: 2);
    await tester.pump(advance);
    final refreshed = currentChoghadiya(DateTime.now(), settings.place)!;
    final refreshedLabel = tester.getSemantics(currentCard).label;
    expect(refreshedLabel, contains(refreshed.name));
    expect(refreshedLabel, contains(hm(refreshed.start)));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(days: 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Guided Player और Completion 320dp/2.0x पर stable हैं',
      (tester) async {
    phone(tester, 320);
    final vidhi = await vidhiBhandar.vidhi('satyanarayan');

    await tester.pumpWidget(
      app(VidhiPlayerScreen(vidhi: vidhi), textScale: 2),
    );
    expect(find.text('अब क्या करें'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      app(PujaCompletionScreen(vidhi: vidhi), textScale: 2),
    );
    expect(find.text('मार्गदर्शिका पूरी हुई'), findsOneWidget);
    expect(find.text('होम पर लौटें'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
