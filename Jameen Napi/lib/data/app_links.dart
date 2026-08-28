/// ऐप का Play Store लिंक — यहीं एक जगह से आता है।
library;

/// Play पर ऐप की पहचान। यह कभी नहीं बदलेगा — यही live ऐप का पैकेज है।
/// (नाम "जमीन नापी" है, पर पैकेज पुराना ही रहेगा; बदलते ही Play इसे नया ऐप
/// मान लेगा और पुराने installs को update मिलना बंद हो जाएगा।)
const String appPackageId = 'com.chandansingh.kisan_calculator';

/// Play Store का लिंक, install कहाँ से आया यह पता चलने के साथ।
///
/// `referrer` में UTM डालने पर Play Console → **Grow users → Acquisition
/// reports** में दिखता है कि कितने install इस रास्ते से आए। `source` अलग-अलग
/// रखने से पता चलता है कि लोग ज़्यादा कहाँ से आ रहे हैं — सीधे ऐप शेयर करने से,
/// या किसी की भेजी हुई नाप-रिपोर्ट से।
///
/// ध्यान: `referrer` का मान URL-encoded होना ज़रूरी है (`%3D` = `=`,
/// `%26` = `&`), वरना Play उसे पढ़ ही नहीं पाता।
String playStoreLink({String source = 'app_share'}) {
  final referrer = Uri.encodeComponent(
    'utm_source=$source&utm_medium=inapp&utm_campaign=user_share',
  );
  return 'https://play.google.com/store/apps/details'
      '?id=$appPackageId&referrer=$referrer';
}

/// जब user खुद ऐप शेयर करे (Settings → ऐप दोस्तों के साथ शेयर करें)
String get shareAppLink => playStoreLink(source: 'app_share');

/// जब किसी नाप की रिपोर्ट व्हाट्सएप पर जाए — असली growth यहीं से आता है,
/// इसलिए इसे अलग गिनना चाहिए।
String get shareReportLink => playStoreLink(source: 'report_share');
