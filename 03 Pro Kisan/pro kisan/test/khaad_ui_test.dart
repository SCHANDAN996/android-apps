import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_kisan/data/crop_meta.dart';
import 'package:pro_kisan/data/crops.dart';
import 'package:pro_kisan/ui/khaad/crop_picker.dart';

void main() {
  group('फ़सल चुनने का पन्ना', () {
    testWidgets('30 फ़सलें 2 कतार के grid में दिखती हैं', (tester) async {
      Crop? picked;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CropPicker(onPicked: (c) => picked = c),
          ),
        ),
      ));
      expect(find.byType(GridView), findsOneWidget);
      final grid = tester.widget<GridView>(find.byType(GridView));
      final del = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(del.crossAxisCount, 2, reason: '2 × 2 कार्ड चाहिए');
      expect(find.text('गेहूं'), findsOneWidget);
      await tester.tap(find.text('गेहूं'));
      await tester.pump();
      expect(picked?.id, 'wheat');
    });

    testWidgets('खोज पट्टी काम करती है', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: CropPicker(onPicked: _noop))),
      ));
      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'धान');
      await tester.pump();
      // grid के भीतर ही गिनिए — खोज बक्से में भी वही शब्द लिखा है
      Finder inGrid(String s) =>
          find.descendant(of: find.byType(GridView), matching: find.text(s));
      expect(inGrid('धान'), findsOneWidget);
      expect(inGrid('गेहूं'), findsNothing);
    });

    testWidgets('रोमन में लिखने पर भी मिलती है — gehu', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: CropPicker(onPicked: _noop))),
      ));
      await tester.enterText(find.byType(TextField), 'gehu');
      await tester.pump();
      expect(find.text('गेहूं'), findsOneWidget);
    });

    testWidgets('श्रेणी की चिप्पी छाँटती है', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: CropPicker(onPicked: _noop))),
      ));
      await tester.tap(find.text('दलहन'));
      await tester.pump();
      expect(find.text('चना'), findsOneWidget);
      expect(find.text('गेहूं'), findsNothing);
    });

    testWidgets('कुछ न मिले तो साफ़ बताता है', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: CropPicker(onPicked: _noop))),
      ));
      await tester.enterText(find.byType(TextField), 'zzzzz');
      await tester.pump();
      expect(find.text('यह फ़सल नहीं मिली'), findsOneWidget);
    });
  });

  group('फ़सल का ब्योरा', () {
    test('हर फ़सल की श्रेणी और emoji है', () {
      for (final c in kCrops) {
        expect(cropEmoji(c.id), isNotEmpty, reason: c.id);
        expect(CropGroup.values.contains(cropGroup(c.id)), isTrue, reason: c.id);
      }
    });

    test('हर फ़सल का अपना चित्र है — कोई साझा नहीं', () {
      final imgs = <String, String>{};
      for (final c in kCrops) {
        final p = cropImage(c.id);
        expect(p, isNotNull, reason: '${c.id} का चित्र नहीं');
        expect(imgs.containsKey(p), isFalse,
            reason: '${c.id} और ${imgs[p]} एक ही चित्र इस्तेमाल कर रहे हैं');
        imgs[p!] = c.id;
      }
    });

    test('खोज हिंदी, अंग्रेज़ी, रोमन तीनों से चलती है', () {
      final wheat = kCrops.firstWhere((c) => c.id == 'wheat');
      for (final q in ['गेहूं', 'wheat', 'gehu', 'kanak', 'WHEAT']) {
        expect(cropMatches(wheat, q), isTrue, reason: q);
      }
      expect(cropMatches(wheat, 'धान'), isFalse);
    });
  });
}

void _noop(Crop c) {}
