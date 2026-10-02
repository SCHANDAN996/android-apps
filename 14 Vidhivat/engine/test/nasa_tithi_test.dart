import 'dart:convert';
import 'dart:io';

import 'package:panchang_engine/panchang_engine.dart';
import 'package:test/test.dart';

/// तिथि का अंत — **NASA JPL Horizons की स्थितियों से** निकले क्षण से मिलान
/// (→ D-104, docs/08 §17)।
///
/// `reference_test` संदर्भ-पंचांग के छपे समय से मिलाता है: वे मिनट तक हैं, और
/// इसी डेटा से निकला कि वे असली क्षण से 40–76 सेकंड **पहले** छपते हैं। इसलिए
/// वहाँ दो मिनट की छूट है। यहाँ छूट 20 सेकंड है — यही इंजन की असली नाप है।
///
/// 2 अक्टूबर 2026 को नापा: छोटे सूत्र वाले सूर्य से फ़र्क़ −25…+34 सेकंड था;
/// VSOP वाले सूर्य से −11…+1 सेकंड। जो 5 सेकंड का औसत बचा है वह ΔT का है
/// (हमारा बहुपद 2026 में 6 सेकंड ज़्यादा देता है)।
void main() {
  final data = jsonDecode(File('test/data/horizons_tithi.json').readAsStringSync())
      as Map<String, dynamic>;
  final cities = (jsonDecode(File('test/data/reference_dates.json')
          .readAsStringSync()) as Map<String, dynamic>)['cities']
      as Map<String, dynamic>;
  final entries = (data['entries'] as List).cast<Map<String, dynamic>>();

  test('बारहों संदर्भ-तारीख़ों का NASA वाला क्षण मौजूद है', () {
    expect(entries.length, 12);
  });

  group('तिथि का अंत — NASA से 20 सेकंड के भीतर', () {
    for (final e in entries) {
      test('${e['date']} — ${e['city']}', () {
        final c = cities[e['city']] as Map<String, dynamic>;
        final place = Place(
            name: c['name'] as String,
            latitude: (c['lat'] as num).toDouble(),
            longitude: (c['lon'] as num).toDouble());
        final d = (e['date'] as String).split('-').map(int.parse).toList();
        final p = computePanchang(d[0], d[1], d[2], place);

        // इंजन स्थानीय घड़ी का समय लौटाता है (UTC के खाने में); NASA वाला
        // क्षण भी भारतीय घड़ी में लिखा है।
        final nasa = DateTime.parse('${e['tithiAntIst']}Z');
        final farq = p.tithi.endsAt!.difference(nasa).inSeconds;
        expect(farq.abs(), lessThanOrEqualTo(20),
            reason: 'इंजन ${p.tithi.endsAt}, NASA $nasa — $farq सेकंड');
      });
    }
  });

  test('संदर्भ-पंचांग के छपे समय NASA से 30–90 सेकंड पहले हैं — सबमें एक ही तरफ़',
      () {
    // यह इंजन की जाँच नहीं, एक दर्ज की हुई बात है: `reference_test` और
    // `sankranti_test` की दो मिनट की छूट इसी वजह से है।
    for (final e in entries) {
      expect(e['sandarbhSeFarqSec'], inInclusiveRange(30, 90),
          reason: '${e['date']}');
    }
  });
}
