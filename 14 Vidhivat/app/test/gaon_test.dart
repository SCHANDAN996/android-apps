import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vidhivat/state/gaon.dart';
import 'package:vidhivat/state/shahar.dart';
import 'package:vidhivat/widgets/jagah_khoj.dart';

/// गाँव-क़स्बों की खोज — बिना इंटरनेट (→ D-128)।
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GaonSuchi s;

  setUpAll(() {
    s = GaonSuchi.padho(Uint8List.fromList(File(gaonAsset).readAsBytesSync()));
  });

  test('सूची खुलती है — पाँच लाख से ज़्यादा जगहें, सब भारत की सीमा-रेखाओं के भीतर', () {
    expect(s.length, greaterThan(500000));
    expect(s.rajyaNaam, contains('छत्तीसगढ़'));
    expect(s.rajyaNaam, hasLength(36));
    // कोई भी अक्षांश-देशांतर भारत के डिब्बे से बाहर नहीं
    for (final g in s.khojo('Rampur', kitne: 200)) {
      expect(g.latitude, inInclusiveRange(6, 37.5));
      expect(g.longitude, inInclusiveRange(68, 97.5));
    }
  });

  test('अंग्रेज़ी में छोटा गाँव — ज़िला लिखकर ठीक वही', () {
    final g = s.khojo('Rawai, Mathura').first;
    expect(g.naam, 'Rawai');
    expect(g.zila, 'Mathura');
    expect(g.rajya, 'उत्तर प्रदेश');
    expect(g.latitude, closeTo(27.477, 0.002));
    expect(g.longitude, closeTo(77.726, 0.002));
  });

  test('हिंदी में लिखा नाम भी — «गंगदासपुर» → Gangdaspur', () {
    final mile = s.khojo('गंगदासपुर', kitne: 40);
    expect(mile.map((g) => '${g.naam} ${g.zila}'), contains('Gangdaspur Bijnor'));
  });

  test('बड़ी जगह (मुख्यालय) पहले — «अंबिकापुर»', () {
    final g = s.khojo('अंबिकापुर').first;
    expect(g.naam, 'Ambikapur');
    expect(g.rajya, 'छत्तीसगढ़');
    expect(g.darja, 0);
  });

  test('राज्य से छाँटना — «Athwal, पंजाब»', () {
    final mile = s.khojo('Athwal, पंजाब');
    expect(mile, isNotEmpty);
    expect(mile.every((g) => g.rajya == 'पंजाब'), isTrue);
  });

  test('दोनों सूचियाँ साथ: ऐप के शहर पहले (हिंदी नाम), फिर गाँव; वही शहर दोबारा नहीं', () async {
    final mile = await jagahKhojo('Bilaspur');
    expect(mile.first.gaonSuchiSe, isFalse);
    expect(mile.first.city.name, 'बिलासपुर');
    expect(mile.where((m) => m.gaonSuchiSe), isNotEmpty);
    final apna = mile.first.city;
    for (final m in mile.where((m) => m.gaonSuchiSe)) {
      final paas = (m.city.latitude - apna.latitude).abs() < 0.15 &&
          (m.city.longitude - apna.longitude).abs() < 0.15;
      expect(paas, isFalse, reason: '${m.city.name} ${m.city.state}');
    }
    // गाँव वाले नतीजे का पता: «ज़िला, राज्य»
    expect(mile.last.city.state, contains(', '));
  });

  test('ख़ाली या सिर्फ़ स्वर — कुछ नहीं', () {
    expect(s.khojo('  '), isEmpty);
    expect(s.khojo('aei'), isEmpty);
  });

  test('पुराना शहर-ढाँचा वैसा ही — byte वाला ढाँचा पुराने नियमों से मिलता है', () {
    expect(romanDhancha('Delhi'), 'dl');
    expect(romanDhancha('Bangalore'), 'bnglr');
    expect(romanDhancha('Calcutta'), 'klkt');
    expect(romanDhancha('Chandigarh'), 'cndgr');
    expect(romanDhancha('Thiruvananthapuram'), 'trntprn');
    expect(romanDhancha('Bilāspur'), 'blspr');
    expect(romanDhancha('Nashik'), 'nsk');
  });
}
