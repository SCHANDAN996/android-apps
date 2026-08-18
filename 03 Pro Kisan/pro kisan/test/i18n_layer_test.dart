import 'package:flutter_test/flutter_test.dart';
import 'package:pro_kisan/data/crops.dart';
import 'package:pro_kisan/data/palan/palan_data.dart';
import 'package:pro_kisan/data/palan/palan_i18n.dart';
import 'package:pro_kisan/data/palan/palan_common.dart';
import 'package:pro_kisan/data/palan/palan_model.dart';

/// अनुवाद की परत की जाँच।
///
/// यह परत हिंदी वाक्य को **चाबी** मानकर बाक़ी भाषाओं का पाठ रखती है। ख़तरा
/// यह है कि data फ़ाइल में वाक्य बदल जाए और चाबी पुरानी रह जाए — तब अनुवाद
/// चुपचाप लगना बंद हो जाएगा और किसी को पता नहीं चलेगा। इसीलिए यहाँ हर चाबी
/// को असली data से मिलाकर देखा जाता है।
void main() {
  const langs = ['ta', 'te', 'kn', 'bn', 'gu', 'pa', 'mr', 'bho'];

  group('अनुवाद की परत जुड़ी है या नहीं', () {
    test('tx() भाषा-कोड मिलने पर अनुवाद लौटाता है', () {
      const v = (hi: 'बकरी पालन', en: 'Goat farming');
      expect(tx(v, false, 'ta'), 'ஆடு வளர்ப்பு');
      expect(tx(v, false, 'bn'), 'ছাগল পালন');
    });

    test('अनुवाद न हो तो पुराना बर्ताव वैसा ही रहता है', () {
      const v = (hi: 'ऐसा कोई वाक्य नहीं', en: 'No such sentence');
      // देवनागरी पढ़ने वाले को हिंदी
      expect(tx(v, true, 'mr'), 'ऐसा कोई वाक्य नहीं');
      // बाक़ी को अंग्रेज़ी
      expect(tx(v, false, 'ta'), 'No such sentence');
      // भाषा-कोड दिया ही न हो
      expect(tx(v, false), 'No such sentence');
    });

    test('Crop.name() भी उसी तरह काम करता है', () {
      final gehu = kCrops.firstWhere((c) => c.hi == 'गेहूं');
      expect(gehu.name(false, 'ta'), 'கோதுமை');
      expect(gehu.name(false, 'pa'), 'ਕਣਕ');
      // कोड न दें तो पहले जैसा
      expect(gehu.name(true), 'गेहूं');
      expect(gehu.name(false), gehu.en);
    });
  });

  group('चाबियाँ असली data से मिलती हैं', () {
    test('हर चाबी का हिंदी वाक्य data में मौजूद है', () {
      // ⚠️ पहले यह जाँच सिर्फ़ `name` और `tagline` देखती थी, क्योंकि तब परत
      // में बस इतना ही था। 6 अगस्त 2026 को गहरा पाठ भी जुड़ गया (नस्ल, आवास,
      // चारा, टीका, बीमारी, लागत-मुनाफ़ा, बेचने के रास्ते…), इसलिए अब गाइड
      // का **हर** हिंदी वाक्य इकट्ठा करना पड़ता है।
      //
      // जाँच का मक़सद वही है: data फ़ाइल में वाक्य बदल जाए और चाबी पुरानी रह
      // जाए तो अनुवाद चुपचाप लगना बंद हो जाएगा — वह यहीं पकड़ा जाए।
      final hiText = <String>{};
      for (final g in kPalanGuides) {
        hiText.addAll([g.name.hi, g.tagline.hi, g.intro.hi,
                       g.economicsUnit.hi, g.economicsNote.hi]);
        for (final list in [g.breeds, g.housing, g.feedNotes, g.production,
                            g.diseases, g.selling, g.mistakes,
                            g.whereToBuy, g.schemes]) {
          hiText.addAll(list.map((e) => e.hi));
        }
        for (final f in g.feed) {
          hiText.addAll([f.stage.hi, f.feed.hi, f.qty.hi]);
        }
        for (final v in g.vaccines) {
          hiText.addAll([v.when.hi, v.what.hi]);
        }
        for (final m in [...g.costs, ...g.income]) {
          hiText.add(m.item.hi);
        }
        hiText.addAll(g.reminderPlan.map((r) => r.what.hi));
      }
      // फ़सल की खाद/बीज वाली पंक्तियाँ भी परत में हैं।
      // spacingHi / seedTreatHi हर फ़सल में नहीं होते, इसलिए null छाँट लो।
      for (final c in kCrops) {
        hiText.addAll([c.hi, c.splitsHi]);
        for (final s in [c.spacingHi, c.seedTreatHi]) {
          if (s != null) hiText.add(s);
        }
        hiText.addAll(c.splitPlan.map((s) => s.whenHi));
      }
      // N-P-K के नाम और उनका ब्योरा भी खाद वाले पन्ने पर दिखता है
      for (final n in kNutrientInfo) {
        hiText.addAll([n.nameHi, n.descHi]);
      }
      // सबके लिए साझा सरकारी मदद, आम ग़लतियाँ और ख़रीदने की जगहें
      for (final list in [kCommonSchemes, kCommonMistakes, kCommonWhereToBuy]) {
        hiText.addAll(list.map((e) => e.hi));
      }

      final stale = kPalanI18n.keys.where((k) => !hiText.contains(k)).toList();
      expect(stale, isEmpty,
          reason: 'इन चाबियों का हिंदी वाक्य data में बदल चुका है — '
              'अनुवाद अब नहीं लगेगा:\n${stale.take(12).join('\n')}');
    });

    test('हर फ़सल की चाबी data में मौजूद है', () {
      final hiNames = kCrops.map((c) => c.hi).toSet();
      final stale = kCropI18n.keys.where((k) => !hiNames.contains(k)).toList();
      expect(stale, isEmpty, reason: 'पुरानी चाबियाँ: $stale');
    });
  });

  group('अनुवाद पूरे हैं', () {
    test('हर चाबी में आठों भाषाएँ हैं', () {
      final missing = <String>[];
      for (final m in [kPalanI18n, kCropI18n]) {
        m.forEach((key, t) {
          for (final l in langs) {
            if ((t[l] ?? '').trim().isEmpty) missing.add('$key → $l');
          }
        });
      }
      expect(missing, isEmpty, reason: 'ये अनुवाद छूट गए: $missing');
    });

    test('कोई अनुवाद हिंदी की नक़ल नहीं है (मराठी/भोजपुरी छोड़कर)', () {
      // मराठी और भोजपुरी देवनागरी में हैं — कई शब्द सचमुच एक जैसे होते हैं
      // ("गाय पालन")। बाक़ी छह की लिपि अलग है, इसलिए वहाँ हिंदी जैसा पाठ
      // होने का मतलब है कि अनुवाद करना भूल गए।
      final copied = <String>[];
      for (final m in [kPalanI18n, kCropI18n]) {
        m.forEach((key, t) {
          for (final l in ['ta', 'te', 'kn', 'bn', 'gu', 'pa']) {
            if (t[l] == key) copied.add('$key → $l');
          }
        });
      }
      expect(copied, isEmpty, reason: 'ये हिंदी की नक़ल हैं: $copied');
    });
  });

  group('सबसे ज़रूरी नाम छूटे नहीं', () {
    test('सभी 15 पालन के नाम अनुवाद हो चुके हैं', () {
      final left =
          kPalanGuides.where((g) => !kPalanI18n.containsKey(g.name.hi)).toList();
      expect(left.map((g) => g.id).toList(), isEmpty,
          reason: 'इन पालनों का नाम अब भी अनुवाद नहीं हुआ');
    });

    test('सभी फ़सलों के नाम अनुवाद हो चुके हैं', () {
      final left = kCrops.where((c) => !kCropI18n.containsKey(c.hi)).toList();
      expect(left.map((c) => c.hi).toList(), isEmpty,
          reason: 'इन फ़सलों का नाम अब भी अनुवाद नहीं हुआ');
    });
  });
}
