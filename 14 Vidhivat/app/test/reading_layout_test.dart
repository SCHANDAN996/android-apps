import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/vidhi/vidhi.dart';
import 'package:vidhivat/widgets/mantra_khand.dart';

void main() {
  final document = jsonDecode(
    File('assets/vidhi/nitya_pooja.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final mantras = (document['charan'] as List)
      .where((step) => step['mantra'] is Map)
      .map((step) => Mantra.fromJson(
          'nitya_pooja', Map<String, dynamic>.from(step['mantra'] as Map)))
      .where((mantra) => mantra.hasPath && mantra.arth.isNotEmpty)
      .toList()
    ..sort((a, b) => b.devanagari.length.compareTo(a.devanagari.length));
  final mantra = mantras.first;

  for (final dark in [false, true]) {
    for (final width in [320.0, 360.0]) {
      for (final scale in [1.0, 1.5, 2.0]) {
        testWidgets('reading $width dp, $scale scale, dark=$dark',
            (tester) async {
          tester.view.physicalSize = Size(width, 720);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          var completed = false;
          await tester.pumpWidget(MaterialApp(
            theme: dark ? VidhivatTheme.dark() : VidhivatTheme.light(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale),
              ),
              child: child!,
            ),
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MantraKhand(mantra: mantra),
                      FilledButton(
                        key: const ValueKey('next'),
                        onPressed: () => completed = true,
                        child: const Text('आगे बढ़ें'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(
              tester.widget<SelectableText>(find.byType(SelectableText)).data,
              mantra.devanagari);
          expect(find.text(mantra.arth), findsOneWidget);
          await tester.scrollUntilVisible(
              find.byKey(const ValueKey('next')), 400,
              scrollable: find.byType(Scrollable).first);
          await tester.tap(find.byKey(const ValueKey('next')));
          expect(completed, isTrue);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
