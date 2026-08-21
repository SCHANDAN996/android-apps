import 'package:flutter/foundation.dart';
import 'package:panchang_engine/panchang_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ऐप की सेटिंग — जगह, मास-पद्धति, और यजमान की जानकारी।
///
/// सब कुछ **सिर्फ़ फ़ोन में** रहता है। कोई सर्वर नहीं, कोई लॉगिन नहीं।
/// यूज़र का नाम और गोत्र कहीं नहीं जाता — यह ऐप की बुनियादी बात है।
class AppSettings extends ChangeNotifier {
  static const _kCity = 'city';
  static const _kMasaSystem = 'masaSystem';
  static const _kName = 'name';
  static const _kGotra = 'gotra';

  SharedPreferences? _prefs;

  City _city = indianCities.first;
  MasaSystem _masaSystem = MasaSystem.purnimanta;
  String _name = '';
  String _gotra = 'कश्यप';

  City get city => _city;
  MasaSystem get masaSystem => _masaSystem;
  String get name => _name;
  String get gotra => _gotra;

  Place get place => _city.place;

  /// यजमान की जानकारी भरी हुई है या नहीं — संकल्प के लिए ज़रूरी।
  bool get hasYajman => _name.trim().isNotEmpty;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();

    final cityName = _prefs!.getString(_kCity);
    if (cityName != null) {
      _city = indianCities.firstWhere(
        (c) => c.name == cityName,
        orElse: () => indianCities.first,
      );
    }

    _masaSystem = _prefs!.getString(_kMasaSystem) == 'amanta'
        ? MasaSystem.amanta
        : MasaSystem.purnimanta;
    _name = _prefs!.getString(_kName) ?? '';
    _gotra = _prefs!.getString(_kGotra) ?? 'कश्यप';

    notifyListeners();
  }

  Future<void> setCity(City value) async {
    _city = value;
    await _prefs?.setString(_kCity, value.name);
    notifyListeners();
  }

  Future<void> setMasaSystem(MasaSystem value) async {
    _masaSystem = value;
    await _prefs?.setString(
        _kMasaSystem, value == MasaSystem.amanta ? 'amanta' : 'purnimanta');
    notifyListeners();
  }

  Future<void> setYajman({String? name, String? gotra}) async {
    if (name != null) {
      _name = name;
      await _prefs?.setString(_kName, name);
    }
    if (gotra != null) {
      _gotra = gotra;
      await _prefs?.setString(_kGotra, gotra);
    }
    notifyListeners();
  }

  // ── सामग्री की टिक ──
  //
  // यूज़र बाज़ार जाते वक़्त सूची में टिक लगाता है। वो टिक अगली बार भी
  // दिखनी चाहिए — पर सिर्फ़ इसी फ़ोन में। हर पूजा की अपनी सूची।

  static String _samagriKey(String pujaId) => 'samagri.$pujaId';

  /// किस-किस सामग्री पर टिक लगी है (सूची में उसका क्रमांक)।
  Set<int> samagriTicks(String pujaId) =>
      (_prefs?.getStringList(_samagriKey(pujaId)) ?? const [])
          .map(int.tryParse)
          .whereType<int>()
          .toSet();

  Future<void> setSamagriTick(String pujaId, int index, bool tick) async {
    final ab = samagriTicks(pujaId);
    if (tick) {
      ab.add(index);
    } else {
      ab.remove(index);
    }
    await _prefs?.setStringList(
      _samagriKey(pujaId),
      ab.map((i) => i.toString()).toList(),
    );
    notifyListeners();
  }

  /// सारी टिक हटा दो — अगली बार पूजा करते वक़्त काम आता है।
  Future<void> clearSamagriTicks(String pujaId) async {
    await _prefs?.remove(_samagriKey(pujaId));
    notifyListeners();
  }

  /// आज का पंचांग, चुनी हुई जगह और पद्धति से।
  Panchang panchangFor(DateTime day) => computePanchang(
        day.year,
        day.month,
        day.day,
        place,
        masaSystem: _masaSystem,
      );
}

/// पूरे ऐप के लिए एक ही सेटिंग।
final settings = AppSettings();

/// एक शहर — नाम, राज्य, और उसका अक्षांश-देशांतर।
class City {
  final String name;
  final String state;
  final double latitude;
  final double longitude;

  const City(this.name, this.state, this.latitude, this.longitude);

  /// इंजन के लिए जगह। समय-क्षेत्र भारत का ही (IST)।
  Place get place => Place(
        name: name,
        latitude: latitude,
        longitude: longitude,
      );

  @override
  String toString() => '$name, $state';
}

/// शहरों की सूची — देशांतर के साथ, ताकि सूर्योदय सही निकले।
///
/// ⚠️ सूर्योदय जगह पर निर्भर करता है, और **तिथि सूर्योदय पर तय होती है** —
/// इसलिए ग़लत शहर चुनने से पंचांग एक दिन खिसक सकता है।
const List<City> indianCities = [
  City('दिल्ली', 'दिल्ली', 28.6139, 77.2090),
  City('मुंबई', 'महाराष्ट्र', 19.0760, 72.8777),
  City('कोलकाता', 'पश्चिम बंगाल', 22.5726, 88.3639),
  City('चेन्नई', 'तमिलनाडु', 13.0827, 80.2707),
  City('बेंगलुरु', 'कर्नाटक', 12.9716, 77.5946),
  City('हैदराबाद', 'तेलंगाना', 17.3850, 78.4867),
  City('पुणे', 'महाराष्ट्र', 18.5204, 73.8567),
  City('अहमदाबाद', 'गुजरात', 23.0225, 72.5714),
  City('जयपुर', 'राजस्थान', 26.9124, 75.7873),
  City('लखनऊ', 'उत्तर प्रदेश', 26.8467, 80.9462),
  City('कानपुर', 'उत्तर प्रदेश', 26.4499, 80.3319),
  City('वाराणसी', 'उत्तर प्रदेश', 25.3176, 82.9739),
  City('प्रयागराज', 'उत्तर प्रदेश', 25.4358, 81.8463),
  City('पटना', 'बिहार', 25.5941, 85.1376),
  City('गया', 'बिहार', 24.7955, 85.0002),
  City('मुज़फ़्फ़रपुर', 'बिहार', 26.1197, 85.3910),
  City('राँची', 'झारखंड', 23.3441, 85.3096),
  City('भोपाल', 'मध्य प्रदेश', 23.2599, 77.4126),
  City('इंदौर', 'मध्य प्रदेश', 22.7196, 75.8577),
  City('उज्जैन', 'मध्य प्रदेश', 23.1765, 75.7885),
  City('नागपुर', 'महाराष्ट्र', 21.1458, 79.0882),
  City('सूरत', 'गुजरात', 21.1702, 72.8311),
  City('चंडीगढ़', 'चंडीगढ़', 30.7333, 76.7794),
  City('अमृतसर', 'पंजाब', 31.6340, 74.8723),
  City('देहरादून', 'उत्तराखंड', 30.3165, 78.0322),
  City('हरिद्वार', 'उत्तराखंड', 29.9457, 78.1642),
  City('आगरा', 'उत्तर प्रदेश', 27.1767, 78.0081),
  City('गोरखपुर', 'उत्तर प्रदेश', 26.7606, 83.3732),
  City('जोधपुर', 'राजस्थान', 26.2389, 73.0243),
  City('रायपुर', 'छत्तीसगढ़', 21.2514, 81.6296),
  City('भुवनेश्वर', 'ओडिशा', 20.2961, 85.8245),
  City('गुवाहाटी', 'असम', 26.1445, 91.7362),
  City('तिरुपति', 'आंध्र प्रदेश', 13.6288, 79.4192),
  City('मदुरै', 'तमिलनाडु', 9.9252, 78.1198),
  City('कोच्चि', 'केरल', 9.9312, 76.2673),
];
