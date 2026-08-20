/// जगह — अक्षांश, देशांतर और समय-क्षेत्र।
///
/// पंचांग जगह-जगह अलग होता है क्योंकि सूर्योदय अलग होता है।
/// दिल्ली और चेन्नई का सूर्योदय 40 मिनट तक अलग हो सकता है, और
/// तिथि सूर्योदय पर ही तय होती है — इसलिए जगह पूछना ज़रूरी है।
class Place {
  final String name;

  /// अक्षांश, डिग्री। उत्तर धनात्मक।
  final double latitude;

  /// देशांतर, डिग्री। **पूर्व धनात्मक** (भारत के लिए धनात्मक)।
  final double longitude;

  /// UTC से कितना आगे। भारत के लिए 5 घंटे 30 मिनट।
  final Duration timeZoneOffset;

  const Place({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.timeZoneOffset = const Duration(hours: 5, minutes: 30),
  });

  @override
  String toString() => name;

  // जाँच के लिए कुछ शहर
  static const delhi = Place(name: 'दिल्ली', latitude: 28.6139, longitude: 77.2090);
  static const patna = Place(name: 'पटना', latitude: 25.5941, longitude: 85.1376);
  static const jaipur = Place(name: 'जयपुर', latitude: 26.9124, longitude: 75.7873);
  static const nagpur = Place(name: 'नागपुर', latitude: 21.1458, longitude: 79.0882);
  static const chennai = Place(name: 'चेन्नई', latitude: 13.0827, longitude: 80.2707);
  static const varanasi = Place(name: 'वाराणसी', latitude: 25.3176, longitude: 82.9739);
  static const mumbai = Place(name: 'मुंबई', latitude: 19.0760, longitude: 72.8777);

  static const testCities = [delhi, patna, jaipur, nagpur, chennai];
}
