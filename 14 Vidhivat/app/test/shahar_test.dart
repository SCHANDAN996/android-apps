// शहरों की सूची और "अपनी जगह का नाम" — D-058 का पहरा।
//
// ⚠️ **इस सूची के अक्षांश-देशांतर से पंचांग बनता है।** यूज़र जब हाथ से
// शहर चुनता है, तब सूर्योदय इन्हीं अंकों से निकलता है — और तिथि सूर्योदय
// पर तय होती है। इसलिए यहाँ एक ग़लत अंक पूरा दिन खिसका सकता है।
//
// ये जाँचें मोटी ग़लतियाँ पकड़ती हैं: भारत से बाहर का बिंदु, दोहरा नाम,
// और दो शहर जो इतने पास हों कि किसी ने नक़ल करते वक़्त अंक बदलना भूल
// गया हो।
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:panchang_engine/panchang_engine.dart';
import 'package:vidhivat/state/settings.dart';

void main() {
  group('शहरों की सूची', () {
    test('हर शहर भारत की सीमा के अंदर है', () {
      for (final c in indianCities) {
        expect(c.latitude, inInclusiveRange(6.0, 37.5),
            reason: '${c.name} का अक्षांश भारत से बाहर है');
        expect(c.longitude, inInclusiveRange(68.0, 97.5),
            reason: '${c.name} का देशांतर भारत से बाहर है');
      }
    });

    test('कोई नाम दो बार नहीं', () {
      final naam = indianCities.map((c) => c.name).toList();
      expect(naam.toSet().length, naam.length,
          reason: 'एक ही नाम दो बार है — चुनने वाला भटकेगा');
    });

    test('हर शहर का नाम और राज्य भरा हुआ है', () {
      for (final c in indianCities) {
        expect(c.name.trim(), isNotEmpty);
        expect(c.state.trim(), isNotEmpty, reason: '${c.name} का राज्य ख़ाली');
      }
    });

    // ⚠️ नक़ल करते वक़्त अंक बदलना भूल जाना सबसे आम ग़लती है। दो अलग
    // शहर 2 किमी के अंदर नहीं हो सकते (0.02° ≈ 2.2 किमी)।
    test('दो शहरों के अंक हूबहू एक जैसे नहीं', () {
      for (var i = 0; i < indianCities.length; i++) {
        for (var j = i + 1; j < indianCities.length; j++) {
          final a = indianCities[i];
          final b = indianCities[j];
          final dLat = (a.latitude - b.latitude).abs();
          final dLon = (a.longitude - b.longitude).abs();
          expect(dLat < 0.02 && dLon < 0.02, isFalse,
              reason: '${a.name} और ${b.name} एक ही जगह पर बैठे हैं');
        }
      }
    });

    test('हर राज्य में कम से कम एक शहर, और छत्तीसगढ़ में कई', () {
      final rajya = indianCities.map((c) => c.state).toSet();
      expect(rajya.length, greaterThan(25),
          reason: 'इतने कम राज्य — कहीं कोई बड़ा हिस्सा छूट तो नहीं गया');

      // वो शिकायत जिससे यह पूरा काम शुरू हुआ: छत्तीसगढ़ में सिर्फ़
      // रायपुर था, इसलिए अंबिकापुर वाले को भी "रायपुर" मिलता था।
      final cg = indianCities.where((c) => c.state == 'छत्तीसगढ़');
      expect(cg.length, greaterThan(10),
          reason: 'छत्तीसगढ़ में सिर्फ़ रायपुर होना ही असली शिकायत थी');
      expect(cg.map((c) => c.name), contains('अंबिकापुर'));
      expect(cg.map((c) => c.name), contains('जगदलपुर'));
    });
  });

  group('सबसे नज़दीक शहर', () {
    test('अंबिकापुर के अंक पर अंबिकापुर ही मिलता है', () {
      // पहले यहाँ "रायपुर" मिलता था — 300 किमी दूर।
      expect(nearestIndianCity(23.1215, 83.1959).name, 'अंबिकापुर');
    });

    test('बस्तर के गाँव पर जगदलपुर मिलता है, रायपुर नहीं', () {
      expect(nearestIndianCity(19.20, 82.10).name, 'जगदलपुर');
    });

    test('दिल्ली के पास दिल्ली ही', () {
      expect(nearestIndianCity(28.60, 77.20).name, 'दिल्ली');
    });
  });

  group('अपनी जगह का नाम (→ D-058)', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await settings.load();
    });

    test('नाम बदलने से अक्षांश-देशांतर नहीं बदलते', () async {
      final pehle = settings.city;
      await settings.setSthanNaam('बगदरी');

      expect(settings.city.name, 'बगदरी');
      expect(settings.city.naamKhudLikha, isTrue);
      // ⚠️ यही इस पूरे काम की जड़ है — नाम बदला, गणित नहीं।
      expect(settings.city.latitude, pehle.latitude);
      expect(settings.city.longitude, pehle.longitude);
      expect(settings.place.latitude, pehle.latitude);
    });

    test('ख़ाली नाम कुछ नहीं बदलता', () async {
      final pehle = settings.city.name;
      await settings.setSthanNaam('   ');
      expect(settings.city.name, pehle);
      expect(settings.city.naamKhudLikha, isFalse);
    });

    test('लिखा हुआ नाम फ़ोन में सहेजा जाता है', () async {
      await settings.setSthanNaam('अंबिकापुर');
      final dobara = AppSettings();
      await dobara.load();
      expect(dobara.city.name, 'अंबिकापुर');
      expect(dobara.city.naamKhudLikha, isTrue);
    });

    test('लिखे हुए नाम का लेबल सच बोलता है', () async {
      await settings.setSthanNaam('बगदरी');
      expect(settings.city.locationSourceLabel, contains('आपका लिखा हुआ नाम'));
    });

    test('काशी लिखने पर जगह तीर्थ बन जाती है', () async {
      await settings.setSthanNaam('वाराणसी');
      expect(settings.sthanPrakar, SthanPrakar.kshetra);
    });
  });

  group('फ़ोन से पहचानी हुई जगह', () {
    test('नाम पास वाले शहर का, पर अंक फ़ोन के अपने', () {
      // अंबिकापुर से थोड़ा हटकर एक गाँव।
      final c = City.fromDeviceLocation(23.05, 83.30);
      expect(c.isDeviceDetected, isTrue);
      expect(c.name, 'अंबिकापुर');
      // ⚠️ गणित शहर के केंद्र से नहीं, फ़ोन के अपने बिंदु से होता है।
      expect(c.latitude, 23.05);
      expect(c.longitude, 83.30);
    });
  });
}
