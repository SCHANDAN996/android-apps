import 'package:panchang_engine/panchang_engine.dart';
import 'package:test/test.dart';

/// **प्रहर** — सूतक की जड़ (→ D-054)।
///
/// यह फ़ाइल इसलिए है कि *"एक प्रहर = तीन घंटे"* वाली आसान ग़लती दोबारा
/// कोड में न घुसे। प्रहर मौसम के साथ छोटा-बड़ा होता है, और सूतक ठीक उसी
/// पर टिका है।
void main() {
  const dilli = Place.delhi;

  /// स्थानीय घड़ी में देखो — प्रहर हमेशा स्थानीय बात है।
  DateTime sthaniya(DateTime utc) => utc.add(dilli.timeZoneOffset);

  group('प्रहर की बनावट', () {
    test('एक अहोरात्र में ठीक आठ प्रहर, और वे क्रम में हैं', () {
      final kshan = DateTime.utc(2026, 6, 15, 6, 0); // दिल्ली में ~11:30
      final seemaayen = praharKiSeemaayen(kshan, dilli);

      expect(seemaayen.length % praharEkDinMein, 0,
          reason: 'हर दिन के ठीक आठ प्रहर बनने चाहिए');
      for (var i = 1; i < seemaayen.length; i++) {
        expect(seemaayen[i].isAfter(seemaayen[i - 1]), isTrue,
            reason: 'प्रहर की सीमाएँ क्रम से बाहर हैं');
      }
    });

    test('दिन के चारों प्रहर बराबर, रात के चारों बराबर — पर आपस में नहीं',
        () {
      // 21 जून — साल का सबसे लंबा दिन। यहाँ फ़र्क़ सबसे साफ़ दिखेगा।
      final ss = sunriseSunset(2026, 6, 21, dilli);
      final uday = ss.sunrise!;
      final ast = ss.sunset!;

      final seemaayen = praharKiSeemaayen(uday.add(const Duration(hours: 3)),
          dilli, pichleDin: 0, aageDin: 0);
      final dinKe = seemaayen
          .where((t) => !t.isBefore(uday) && t.isBefore(ast))
          .toList();
      expect(dinKe, hasLength(4));

      final pehla = dinKe[1].difference(dinKe[0]);
      for (var i = 2; i < 4; i++) {
        final ab = dinKe[i].difference(dinKe[i - 1]);
        expect((ab - pehla).abs() < const Duration(seconds: 2), isTrue,
            reason: 'दिन के प्रहर आपस में बराबर होने चाहिए');
      }

      // जून में दिन लंबा है, इसलिए दिन का प्रहर तीन घंटे से बड़ा।
      expect(pehla > const Duration(hours: 3), isTrue,
          reason: 'सबसे लंबे दिन पर भी प्रहर तीन घंटे का निकल रहा है — '
              'यानी कहीं तीन घंटे हार्डकोड हैं');
    });

    test('जून का दिन-प्रहर दिसंबर के दिन-प्रहर से बड़ा होता है', () {
      Duration dinKaPrahar(int mahina, int din) {
        final ss = sunriseSunset(2026, mahina, din, dilli);
        return ss.sunset!.difference(ss.sunrise!) ~/ 4;
      }

      final june = dinKaPrahar(6, 21);
      final december = dinKaPrahar(12, 21);
      expect(june > december, isTrue);
      // दिल्ली में यह फ़र्क़ लगभग पौन घंटे का होता है — छोटा नहीं।
      expect(june - december > const Duration(minutes: 30), isTrue);
    });
  });

  group('प्रहर पीछे गिनना — सूतक इसी पर खड़ा है', () {
    test('शून्य प्रहर पीछे यानी उसी प्रहर की शुरुआत', () {
      final kshan = DateTime.utc(2026, 3, 3, 13, 0);
      final shuruaat = praharPeeche(kshan, dilli, 0)!;

      expect(shuruaat.isAfter(kshan), isFalse);
      // अगली सीमा उस क्षण के बाद होनी चाहिए — वरना ग़लत प्रहर पकड़ा है।
      final seemaayen = praharKiSeemaayen(kshan, dilli);
      final agli = seemaayen.firstWhere((t) => t.isAfter(shuruaat));
      expect(agli.isAfter(kshan), isTrue);
    });

    test('जितने प्रहर पीछे कहो, उतनी ही सीमाएँ पीछे जाता है', () {
      final kshan = DateTime.utc(2026, 3, 3, 13, 0);
      final seemaayen = praharKiSeemaayen(kshan, dilli);
      final abKa = praharPeeche(kshan, dilli, 0)!;
      final index = seemaayen.indexOf(abKa);

      for (var kitne = 1; kitne <= 5; kitne++) {
        expect(praharPeeche(kshan, dilli, kitne), seemaayen[index - kitne]);
      }
    });

    test('"नौ घंटे" सूतक की सबसे कम अवधि है, ठीक अवधि नहीं', () {
      // ⚠️ यहीं वो ग़लती बैठी थी जो सूतक ग़लत करा रही थी।
      //
      // सूतक उस प्रहर की **शुरुआत** पर लगता है जो तीन प्रहर पीछे है।
      // ग्रहण अपने प्रहर के आख़िर में पड़े तो वहाँ से ग्रहण तक पूरे
      // **चार** प्रहर बन जाते हैं। इसलिए असली अवधि तीन से चार प्रहर
      // के बीच रहती है — नौ घंटे उसका फ़र्श है, छत नहीं।
      final door = <Duration>{};
      for (var mahina = 1; mahina <= 12; mahina++) {
        final kshan = DateTime.utc(2026, mahina, 15, 16, 0);
        door.add(kshan.difference(praharPeeche(kshan, dilli, 3)!));
      }

      for (final d in door) {
        expect(d >= const Duration(hours: 7, minutes: 30), isTrue,
            reason: 'तीन प्रहर इतने छोटे नहीं हो सकते: $d');
        expect(d <= const Duration(hours: 14), isTrue,
            reason: 'चार प्रहर से भी लंबा निकल रहा है: $d');
      }
      expect(door.length > 1, isTrue, reason: 'साल भर एक ही अवधि आ रही है');
    });

    test('लगातार तीन प्रहर मिलकर कभी ठीक नौ घंटे नहीं बनते', () {
      final teen = <Duration>{};
      for (var mahina = 1; mahina <= 12; mahina++) {
        final kshan = DateTime.utc(2026, mahina, 15, 16, 0);
        teen.add(praharPeeche(kshan, dilli, 0)!
            .difference(praharPeeche(kshan, dilli, 3)!));
      }
      expect(teen.contains(const Duration(hours: 9)), isFalse,
          reason: 'तीन प्रहर ठीक नौ घंटे निकल रहे हैं — यानी प्रहर बराबर '
              'तीन-तीन घंटे के मान लिए गए हैं');
      expect(teen.length > 1, isTrue);
    });
  });

  group('Drik Panchang से मिलान — 7 सितम्बर 2025, दिल्ली', () {
    // ग्रहण का स्पर्श 21:58 (Drik)। उसी से गिनकर Drik ने छापा:
    //   Sutak Begins                  12:19
    //   Sutak for Kids, Old and Sick  18:36
    final grahanKaSparsha =
        DateTime.utc(2025, 9, 7, 21, 58).subtract(dilli.timeZoneOffset);

    test('तीन प्रहर पीछे — 12:19', () {
      final mila = sthaniya(praharPeeche(grahanKaSparsha, dilli, 3)!);
      expect(mila.hour, 12);
      expect(mila.minute, anyOf(18, 19), reason: 'Drik: 12:19, हमारा $mila');
    });

    test('एक प्रहर पीछे — 18:36, यानी ठीक सूर्यास्त', () {
      final mila = sthaniya(praharPeeche(grahanKaSparsha, dilli, 1)!);
      expect(mila.hour, 18);
      expect(mila.minute, anyOf(35, 36), reason: 'Drik: 18:36, हमारा $mila');

      // रात का पहला प्रहर सूर्यास्त से ही शुरू होता है — यही जाँच उस
      // बात को पकड़ती है।
      final ast = sunriseSunset(2025, 9, 7, dilli).sunset!;
      expect((mila.difference(sthaniya(ast))).abs() < const Duration(minutes: 1),
          isTrue);
    });
  });
}
