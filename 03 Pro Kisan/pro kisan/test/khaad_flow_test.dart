import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_kisan/blocs/app_cubit.dart';
import 'package:pro_kisan/ui/khaad/khaad_screen.dart';

/// AppCubit को असली DB चाहिए (loadSettings), इसलिए जाँच में सिर्फ़ इसकी
/// शुरुआती state इस्तेमाल करते हैं — DB को हाथ नहीं लगाते।
Future<void> _pump(WidgetTester tester) async {
  final cubit = AppCubit();
  addTearDown(cubit.close);
  await tester.pumpWidget(
    BlocProvider<AppCubit>.value(
      value: cubit,
      child: const MaterialApp(home: KhaadScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('खाद-बीज: तीनों क़दम और चारों tab चलते हैं', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _pump(tester);

    // क़दम 1 — फ़सल चुनिए
    expect(find.text('पहले फ़सल चुनिए'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);

    await tester.tap(find.text('गेहूं').first);
    await tester.pumpAndSettle();

    // क़दम 2 — रक़बा, ऊपर फ़सल का चित्र
    expect(find.text('खेत कितना है?'), findsOneWidget);
    expect(find.text('बदलें'), findsOneWidget);
    expect(find.byType(Image), findsWidgets, reason: 'फ़सल का चित्र दिखना चाहिए');

    await tester.enterText(find.byType(TextField).first, '1');
    await tester.pumpAndSettle();

    // क़दम 3 — चारों tab
    expect(find.text('खाद'), findsOneWidget);
    expect(find.text('बीज'), findsOneWidget);
    expect(find.text('कब डालें'), findsOneWidget);
    expect(find.text('अन्य ज़रूरी'), findsOneWidget);

    // बीज tab
    await tester.tap(find.text('बीज'));
    await tester.pumpAndSettle();
    expect(find.textContaining('दूरी और तरीक़ा'), findsOneWidget);
    expect(find.textContaining('बीज उपचार'), findsOneWidget);

    // कब डालें tab — तीन चरण
    await tester.tap(find.text('कब डालें'));
    await tester.pumpAndSettle();
    expect(find.textContaining('बुवाई के दिन'), findsOneWidget);
    expect(find.textContaining('पहली सिंचाई'), findsOneWidget);

    // अन्य ज़रूरी tab — गोबर खाद + ज़िंक
    await tester.tap(find.text('अन्य ज़रूरी'));
    await tester.pumpAndSettle();
    expect(find.textContaining('गोबर की खाद'), findsOneWidget);
    // "ज़िंक सल्फ़ेट" नीचे स्रोत वाली पंक्ति में भी लिखा है, इसलिए findsWidgets
    expect(find.textContaining('ज़िंक सल्फ़ेट'), findsWidgets);

    // स्रोत नीचे दिख रहा है
    expect(find.textContaining('ICAR-IIWBR'), findsOneWidget);

    // "बदलें" से वापस फ़सल चुनने पर
    await tester.tap(find.text('बदलें'));
    await tester.pumpAndSettle();
    expect(find.text('पहले फ़सल चुनिए'), findsOneWidget);
  });

  testWidgets('सरसों चुनने पर SSP वाला बेहतर रास्ता दिखता है', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _pump(tester);
    await tester.enterText(find.byType(TextField).first, 'सरसों');
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
        of: find.byType(GridView), matching: find.text('सरसों')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '1');
    await tester.pumpAndSettle();

    expect(find.textContaining('DAP की जगह SSP'), findsOneWidget);
    expect(find.textContaining('गंधक मुफ़्त'), findsOneWidget);
  });

  testWidgets('गन्ना: बीज टन में दिखता है, शून्य नहीं', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await _pump(tester);
    await tester.enterText(find.byType(TextField).first, 'गन्ना');
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
        of: find.byType(GridView), matching: find.text('गन्ना')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '1');
    await tester.pumpAndSettle();

    await tester.tap(find.text('बीज'));
    await tester.pumpAndSettle();
    expect(find.text('टन'), findsOneWidget);
    expect(find.textContaining('टुकड़े'), findsWidgets);
  });
}
