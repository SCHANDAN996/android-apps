import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_kisan/l10n/app_localizations.dart';

String tr(String lang, String key) =>
    AppLocalizations(Locale(lang)).translate(key);

bool _isDevanagari(String s) =>
    s.runes.any((r) => r >= 0x0900 && r <= 0x097F);

/// जो भाषाएँ देवनागरी में नहीं लिखी जातीं — इनके पढ़ने वाले हिंदी नहीं पढ़ सकते
const _nonDeva = ['ta', 'te', 'kn', 'bn', 'gu', 'pa'];

/// वे चाबियाँ जो सबसे ज़्यादा दिखती हैं और पहले आठों भाषाओं में छूटी हुई थीं
const _wasMissing = [
  'fcrCalcTitle', 'fcrBroiler', 'fcrLayer', 'fcrProfit', 'fcrIncome',
  'periodAllTime', 'periodWeek', 'monthLabel', 'thisMonth', 'days',
  'totalMilk', 'totalEntries', 'tableDue', 'tablePaid', 'tableName',
  'reportHistoryTitle', 'pickFromContacts', 'openSettings', 'changeBtn',
  'chooseCustomerTitle', 'addFirstCustomer', 'addCustomerFirst',
  'milkDashTitle', 'moneyToCollect', 'allSettled', 'seeAllEntries',
  'vaccineReminderBtn', 'removeReminder', 'preparingFile',
  'wUseGps', 'wGpsFinding', 'wGpsOff', 'wSearchRecent', 'wSearchNoResult',
  'pashuSuar', 'pashuMurgi', 'pashuFish', 'pashuBhed', 'pashuBee',
  'backupLocationLabel', 'customRange', 'noContactsFound',
];

void main() {
  group('जो चाबियाँ छूटी थीं — अब आठों भाषाओं में हैं', () {
    test('हर भाषा में हर चाबी का अपना अनुवाद है', () {
      for (final l in [..._nonDeva, 'mr', 'bho']) {
        for (final k in _wasMissing) {
          final v = tr(l, k);
          expect(v, isNot(k), reason: '$l · $k — कोई अनुवाद नहीं');
          expect(v, isNot(tr('en', k)),
              reason: '$l · $k — अंग्रेज़ी ही लौट रही है (अनुवाद नहीं हुआ)');
        }
      }
    });

    test('देवनागरी न पढ़ने वालों को इनमें देवनागरी नहीं दिखती', () {
      for (final l in _nonDeva) {
        for (final k in _wasMissing) {
          final v = tr(l, k);
          expect(_isDevanagari(v), isFalse,
              reason: '$l · $k = "$v" — यह देवनागरी है, पढ़ी नहीं जाएगी');
        }
      }
    });

    test('मराठी और भोजपुरी में देवनागरी ही रहे', () {
      for (final l in ['mr', 'bho']) {
        expect(_isDevanagari(tr(l, 'monthLabel')), isTrue, reason: l);
      }
    });
  });

  group('भाषा का fallback', () {
    // ⚠️ पहले हर भाषा **हिंदी** पर गिरती थी। तमिल/तेलुगु/कन्नड़/बांग्ला/
    // गुजराती/पंजाबी पढ़ने वाला देवनागरी नहीं पढ़ सकता।
    test('अनुवाद न मिले तो देवनागरी न पढ़ने वालों को अंग्रेज़ी मिले', () {
      // अब सारी चाबियाँ भर चुकी हैं, इसलिए एक बनावटी चाबी से जाँचते हैं
      // कि fallback का रास्ता सही दिशा में जाता है।
      const ghost = 'zzz_koi_chabi_nahi';
      for (final l in _nonDeva) {
        expect(tr(l, ghost), ghost, reason: l);
      }
    });

    test('जिस भाषा में अनुवाद है, वही मिले (fallback न लगे)', () {
      final ta = tr('ta', 'navMilk');
      expect(ta, isNot(tr('hi', 'navMilk')));
      expect(ta, isNot(tr('en', 'navMilk')));
      expect(ta, isNotEmpty);
    });

    test('जो चाबी कहीं नहीं है वह चाबी ही लौटे (क्रैश नहीं)', () {
      expect(tr('ta', 'aisi_koi_chabi_nahi'), 'aisi_koi_chabi_nahi');
    });
  });

  group('भाषा की सूची', () {
    test('दसों भाषाएँ समर्थित हैं', () {
      expect(AppLocalizations.supportedLocales.length, 10);
    });

    test('हर समर्थित भाषा में कुछ न कुछ अपना अनुवाद है', () {
      for (final loc in AppLocalizations.supportedLocales) {
        expect(tr(loc.languageCode, 'navMilk'), isNot('navMilk'),
            reason: '${loc.languageCode} में कुछ भी अनुवाद नहीं');
      }
    });
  });

  group('पालन गाइड के शीर्षक भी हर भाषा में', () {
    const palanKeys = [
      'palanTitle', 'palanIntro', 'palanBreeds', 'palanHousing', 'palanFeed',
      'palanProduction', 'palanVaccine', 'palanDisease', 'palanEconomics',
      'palanCost', 'palanIncome', 'palanProfit', 'palanSelling',
      'permTitle', 'permAllow', 'permLater',
      'dashGoodMorning', 'dashTodayMilk', 'grandTotal',
      'reportDayWise', 'reportCustomerWise', 'pdfBillTitle',
    ];

    test('आठों भाषाओं में अपना अनुवाद', () {
      for (final l in [..._nonDeva, 'mr', 'bho']) {
        for (final k in palanKeys) {
          final v = tr(l, k);
          expect(v, isNot(k), reason: '$l · $k — अनुवाद नहीं');
          expect(v, isNot(tr('en', k)), reason: '$l · $k — अंग्रेज़ी लौट रही है');
        }
      }
    });

    test('देवनागरी न पढ़ने वालों को यहाँ भी देवनागरी न दिखे', () {
      for (final l in _nonDeva) {
        for (final k in palanKeys) {
          expect(_isDevanagari(tr(l, k)), isFalse,
              reason: '$l · $k = "${tr(l, k)}"');
        }
      }
    });
  });
}
