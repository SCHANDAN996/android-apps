/// मौसम के आँकड़ों के मॉडल + Open-Meteo के जवाब को इनमें बदलने का काम।
///
/// पुराने मॉडल में सिर्फ़ तापमान/कोड/बारिश थे। card पर touch करने पर पूरी
/// जानकारी दिखानी है, इसलिए अब "महसूस" तापमान, नमी, हवा की दिशा, बारिश की
/// संभावना और सूर्योदय/सूर्यास्त भी रखते हैं।
library;

class WeatherData {
  final CurrentWeather current;
  final List<DailyForecast> daily;

  const WeatherData({required this.current, required this.daily});

  /// Open-Meteo के कच्चे जवाब से मॉडल बनाओ।
  /// कोई field गायब हो तो null/0 — ऐप टूटना नहीं चाहिए।
  factory WeatherData.fromApi(Map<String, dynamic> json) {
    final c = json['current'] as Map<String, dynamic>? ?? {};
    final d = json['daily'] as Map<String, dynamic>? ?? {};
    final h = json['hourly'] as Map<String, dynamic>? ?? {};

    double? num2d(dynamic v) => (v as num?)?.toDouble();
    List<dynamic> arr(Map<String, dynamic> m, String k) =>
        (m[k] as List?) ?? const [];
    T? at<T>(List<dynamic> l, int i) => i < l.length ? l[i] as T? : null;

    // ── आज का हाल ──
    final current = CurrentWeather(
      temp: num2d(c['temperature_2m']) ?? 0,
      feelsLike: num2d(c['apparent_temperature']),
      humidity: (c['relative_humidity_2m'] as num?)?.toInt(),
      weatherCode: (c['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed: num2d(c['wind_speed_10m']) ?? 0,
      windDirection: num2d(c['wind_direction_10m']),
      uvIndex: num2d(c['uv_index']),
      precipitation: num2d(c['precipitation']),
    );

    // ── दिन-दर-दिन ──
    final times = arr(d, 'time');
    final daily = <DailyForecast>[];
    for (int i = 0; i < times.length; i++) {
      daily.add(DailyForecast(
        date: DateTime.parse(times[i] as String),
        weatherCode: (at<num>(arr(d, 'weather_code'), i))?.toInt() ?? 0,
        maxTemp: (at<num>(arr(d, 'temperature_2m_max'), i))?.toDouble() ?? 0,
        minTemp: (at<num>(arr(d, 'temperature_2m_min'), i))?.toDouble() ?? 0,
        feelsMax: (at<num>(arr(d, 'apparent_temperature_max'), i))?.toDouble(),
        feelsMin: (at<num>(arr(d, 'apparent_temperature_min'), i))?.toDouble(),
        precipitation:
            (at<num>(arr(d, 'precipitation_sum'), i))?.toDouble() ?? 0,
        rainChance:
            (at<num>(arr(d, 'precipitation_probability_max'), i))?.toDouble(),
        windMax: (at<num>(arr(d, 'wind_speed_10m_max'), i))?.toDouble(),
        uvIndex: (at<num>(arr(d, 'uv_index_max'), i))?.toDouble() ?? 0,
        sunrise: _parseTime(at<String>(arr(d, 'sunrise'), i)),
        sunset: _parseTime(at<String>(arr(d, 'sunset'), i)),
      ));
    }

    // ── घंटेवार — हर दिन के नीचे बाँट दो ──
    final hTimes = arr(h, 'time');
    final hourlyByDay = <int, List<HourlyForecast>>{};
    for (int i = 0; i < hTimes.length; i++) {
      final dt = DateTime.parse(hTimes[i] as String);
      final dayIdx = daily.indexWhere((x) =>
          x.date.year == dt.year &&
          x.date.month == dt.month &&
          x.date.day == dt.day);
      if (dayIdx == -1) continue;

      hourlyByDay.putIfAbsent(dayIdx, () => []).add(HourlyForecast(
            time: dt,
            temp: (at<num>(arr(h, 'temperature_2m'), i))?.toDouble() ?? 0,
            feelsLike:
                (at<num>(arr(h, 'apparent_temperature'), i))?.toDouble(),
            humidity:
                (at<num>(arr(h, 'relative_humidity_2m'), i))?.toInt(),
            weatherCode: (at<num>(arr(h, 'weather_code'), i))?.toInt() ?? 0,
            rainChance: (at<num>(arr(h, 'precipitation_probability'), i))
                    ?.toDouble() ??
                0,
            rainMm: (at<num>(arr(h, 'precipitation'), i))?.toDouble(),
            windSpeed:
                (at<num>(arr(h, 'wind_speed_10m'), i))?.toDouble() ?? 0,
            windDirection:
                (at<num>(arr(h, 'wind_direction_10m'), i))?.toDouble(),
          ));
    }
    for (int i = 0; i < daily.length; i++) {
      daily[i].hourly = hourlyByDay[i] ?? const [];
    }

    return WeatherData(current: current, daily: daily);
  }

  static DateTime? _parseTime(String? s) =>
      (s == null || s.isEmpty) ? null : DateTime.tryParse(s);
}

class CurrentWeather {
  final double temp;
  final double? feelsLike;
  final int? humidity;
  final int weatherCode;
  final double windSpeed;
  final double? windDirection;
  final double? uvIndex;
  final double? precipitation;

  const CurrentWeather({
    required this.temp,
    this.feelsLike,
    this.humidity,
    required this.weatherCode,
    required this.windSpeed,
    this.windDirection,
    this.uvIndex,
    this.precipitation,
  });
}

class DailyForecast {
  final DateTime date;
  final int weatherCode;
  final double maxTemp;
  final double minTemp;
  final double? feelsMax;
  final double? feelsMin;

  /// कुल बारिश (मिमी)
  final double precipitation;

  /// बारिश की संभावना (%)
  final double? rainChance;
  final double? windMax;
  final double uvIndex;
  final DateTime? sunrise;
  final DateTime? sunset;

  List<HourlyForecast> hourly = const [];

  DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.maxTemp,
    required this.minTemp,
    this.feelsMax,
    this.feelsMin,
    required this.precipitation,
    this.rainChance,
    this.windMax,
    required this.uvIndex,
    this.sunrise,
    this.sunset,
  });

  bool get isToday {
    final n = DateTime.now();
    return date.year == n.year && date.month == n.month && date.day == n.day;
  }
}

class HourlyForecast {
  final DateTime time;
  final double temp;
  final double? feelsLike;
  final int? humidity;
  final int weatherCode;

  /// बारिश की संभावना (%)
  final double rainChance;

  /// कितनी बारिश (मिमी)
  final double? rainMm;
  final double windSpeed;
  final double? windDirection;

  const HourlyForecast({
    required this.time,
    required this.temp,
    this.feelsLike,
    this.humidity,
    required this.weatherCode,
    required this.rainChance,
    this.rainMm,
    required this.windSpeed,
    this.windDirection,
  });
}

/// हवा की दिशा को किसान की भाषा में — "उत्तर-पश्चिम" वग़ैरह
String windDirectionName(double? deg, bool isHi) {
  if (deg == null) return '';
  const hi = ['उत्तर', 'उत्तर-पूर्व', 'पूर्व', 'दक्षिण-पूर्व',
              'दक्षिण', 'दक्षिण-पश्चिम', 'पश्चिम', 'उत्तर-पश्चिम'];
  const en = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  final i = (((deg % 360) + 22.5) ~/ 45) % 8;
  return isHi ? hi[i] : en[i];
}

/// खेती की सलाह — मौसम देखकर, किसान के काम की बात (10 भाषाओं में)।
List<String> farmAdvice(DailyForecast d, String langCode) {
  final tips = <String>[];
  final rain = d.rainChance ?? 0;
  final wind = d.windMax ?? 0;

  String getTip(String key) {
    switch (langCode) {
      case 'mr':
        switch (key) {
          case 'rain_high': return '🌧️ पावसाची दाट शक्यता — फवारणी आणि सिंचन पुढे ढकला';
          case 'rain_med': return '🌦️ पाऊस पडू शकतो — फवारणीपूर्वी आकाश तपासा';
          case 'wind': return '💨 वेगवान वारा — आज औषध फवारणी करू नका, वाया जाईल';
          case 'heat': return '🔥 कडक ऊन — सकाळी लवकर किंवा संध्याकाळी सिंचन करा';
          case 'frost': return '❄️ थंडी/धुक्याचा धोका — हलके सिंचन करा, पिके झाका';
          case 'uv': return '☀️ तीव्र सूर्यप्रकाश — दुपारी १२ ते ३ शेतातील काम टाळा';
          default: return '✅ हवामान शेतीच्या कामांसाठी उत्तम आहे';
        }
      case 'pa':
        switch (key) {
          case 'rain_high': return '🌧️ ਭਾਰੀ ਮੀਂਹ ਦੀ ਸੰਭਾਵਨਾ — ਛਿੜਕਾਅ ਅਤੇ ਸਿੰਚਾਈ ਟਾਲੋ';
          case 'rain_med': return '🌦️ ਮੀਂਹ ਪੈ ਸਕਦਾ ਹੈ — ਛਿੜਕਾਅ ਤੋਂ ਪਹਿਲਾਂ ਅਸਮਾਨ ਦੇਖੋ';
          case 'wind': return '💨 ਤੇਜ਼ ਹਵਾ — ਅੱਜ ਦਵਾਈ ਦਾ ਛਿੜਕਾਅ ਨਾ ਕਰੋ, ਖਰਾਬ ਹੋ ਜਾਵੇਗੀ';
          case 'heat': return '🔥 ਭਾਰੀ ਗਰਮੀ — ਸਵੇਰੇ ਜਲਦੀ ਜਾਂ ਸ਼ਾਮ ਨੂੰ ਸਿੰਚਾਈ ਕਰੋ';
          case 'frost': return '❄️ ਕੋਰਾ ਪੈਣ ਦਾ ਖਤਰਾ — ਹਲਕੀ ਸਿੰਚਾਈ ਕਰੋ, ਫਸਲ ਢੱਕੋ';
          case 'uv': return '☀️ ਤੇਜ਼ ਧੁੱਪ — ਦੁਪਹਿਰ 12 ਤੋਂ 3 ਵਜੇ ਤੱਕ ਖੇਤਾਂ ਵਿੱਚ ਕੰਮ ਤੋਂ ਬਚੋ';
          default: return '✅ ਮੌਸਮ ਖੇਤੀ ਦੇ ਕੰਮਾਂ ਲਈ ਠੀਕ ਹੈ';
        }
      case 'gu':
        switch (key) {
          case 'rain_high': return '🌧️ ભારે વરસાદની શક્યતા — છંટકાવ અને સિંચાઈ ટાળો';
          case 'rain_med': return '🌦️ વરસાદ આવી શકે છે — છંટકાવ પહેલાં આકાશ જુઓ';
          case 'wind': return '💨 તેજ પવન — આજે દવાનો છંટકાવ ન કરવો, બગાડ થશે';
          case 'heat': return '🔥 ભારે ગરમી — સવારે વહેલા અથવા સાંજે સિંચાઈ કરો';
          case 'frost': return '❄️ ઠંડી/ઝાકળનું જોખમ — હળવી સિંચાઈ કરો';
          case 'uv': return '☀️ તીવ્ર તડકો — બપોરે 12 થી 3 ખેતરમાં કામ ટાળો';
          default: return '✅ હવામાન ખેતીના કામ માટે અનુકૂળ છે';
        }
      case 'bn':
        switch (key) {
          case 'rain_high': return '🌧️ ভারী বৃষ্টির সম্ভাবনা — স্প্রে ও সেচ স্থগিত রাখুন';
          case 'rain_med': return '🌦️ বৃষ্টি হতে পারে — স্প্রে করার আগে আকাশ দেখে নিন';
          case 'wind': return '💨 তীব্র বাতাস — আজ ওষুধ স্প্রে করবেন না, নষ্ট হবে';
          case 'heat': return '🔥 তীব্র গরম — ভোরে বা সন্ধ্যায় সেচ দিন';
          case 'frost': return '❄️ তুষারপাতের আশঙ্কা — হালকা সেচ দিন, ফসল ঢেকে রাখুন';
          case 'uv': return '☀️ প্রখর রোদ — দুপুর ১২টা থেকে ৩টে পর্যন্ত মাঠে কাজ এড়ান';
          default: return '✅ আবহাওয়া কৃষি কাজের জন্য অনুকূল';
        }
      case 'te':
        switch (key) {
          case 'rain_high': return '🌧️ వర్షం పడే అవకాశం ఉంది — పిచికారీ మరియు నీటిపారుదల వాయిదా వేయండి';
          case 'rain_med': return '🌦️ వర్షించే సూచనలు ఉన్నాయి — పిచికారీకి ముందు ఆకాశాన్ని గమనించండి';
          case 'wind': return '💨 ఈదురు గాలులు — ఈరోజు మందులు పిచికారీ చేయవద్దు';
          case 'heat': return '🔥 అధిక ఉష్ణోగ్రత — ఉదయాన్నే లేదా సాయంత్రం వేళ నీరు పెట్టండి';
          case 'frost': return '❄️ మంచు ముప్పు — స్వల్ప నీటిపారుదల అందించండి';
          case 'uv': return '☀️ తీవ్రమైన ఎండ — మధ్యాహ్నం 12 నుండి 3 వరకు పొలం పనులు వద్దు';
          default: return '✅ వాతావరణం వ్యవసాయ పనులకు అనుకూలంగా ఉంది';
        }
      case 'ta':
        switch (key) {
          case 'rain_high': return '🌧️ மழை பெய்ய வாய்ப்புள்ளது — தெளித்தல் மற்றும் பாசனத்தை தள்ளிவையுங்கள்';
          case 'rain_med': return '🌦️ மழை பெய்யக்கூடும் — தெளிப்பதற்கு முன் வானத்தை பார்க்கவும்';
          case 'wind': return '💨 பலத்த காற்று — இன்று மருந்து தெளிப்பதைத் தவிர்க்கவும்';
          case 'heat': return '🔥 கடும் வெப்பம் — அதிகாலை அல்லது மாலையில் பாசனம் செய்யவும்';
          case 'frost': return '❄️ பனிப்பொழிவு அபாயம் — லேசான பாசனம் செய்யவும்';
          case 'uv': return '☀️ கடுமையான வெயில் — மதியம் 12 முதல் 3 மணி வரை வேலை தவிர்க்கவும்';
          default: return '✅ வானிலை விவசாய பணிகளுக்கு சாதகமாக உள்ளது';
        }
      case 'kn':
        switch (key) {
          case 'rain_high': return '🌧️ ಮಳೆಯಾಗುವ ಸಾಧ್ಯತೆ ಇದೆ — ಸಿಂಪಡಣೆ ಮತ್ತು ನೀರಾವರಿಯನ್ನು ಮುಂದೂಡಿ';
          case 'rain_med': return '🌦️ ಮಳೆಯಾಗಬಹುದು — ಸಿಂಪಡಿಸುವ ಮೊದಲು ಆಕಾಶವನ್ನು ನೋಡಿ';
          case 'wind': return '💨 ಬಿರುಗಾಳಿ — ಇಂದು ಔಷಧಿ ಸಿಂಪಡಿಸಬೇಡಿ';
          case 'heat': return '🔥 ತೀವ್ರ ಬಿಸಿಲು — ಬೆಳಿಗ್ಗೆ ಬೇಗ ಅಥವಾ ಸಂಜೆ ನೀರಾವರಿ ಮಾಡಿ';
          case 'frost': return '❄️ ಹಿಮಪಾತದ ಅಪಾಯ — ಸಣ್ಣ ಪ್ರಮಾಣದ ನೀರಾವರಿ ಮಾಡಿ';
          case 'uv': return '☀️ ತೀವ್ರ ಬಿಸಿಲು — ಮಧ್ಯಾಹ್ನ 12 ರಿಂದ 3 ರವರೆಗೆ ಹೊಲದ ಕೆಲಸ ಬೇಡ';
          default: return '✅ ವಾತಾವರಣವು ಕೃಷಿ ಕೆಲಸಗಳಿಗೆ ಸೂಕ್ತವಾಗಿದೆ';
        }
      case 'en':
        switch (key) {
          case 'rain_high': return '🌧️ Heavy rain expected — postpone spraying & irrigation';
          case 'rain_med': return '🌦️ Rain possible — check the sky before spraying';
          case 'wind': return '💨 Strong wind — avoid spraying pesticides today';
          case 'heat': return '🔥 Extreme heat — irrigate early morning or evening';
          case 'frost': return '❄️ Frost risk — apply light irrigation to protect crop';
          case 'uv': return '☀️ Harsh sun — avoid field work between 12 and 3 PM';
          default: return '✅ Weather is favorable for field work';
        }
      default: // hi, bho
        switch (key) {
          case 'rain_high': return '🌧️ बारिश की पूरी संभावना — छिड़काव और सिंचाई टाल दें';
          case 'rain_med': return '🌦️ बारिश हो सकती है — छिड़काव से पहले आसमान देख लें';
          case 'wind': return '💨 तेज़ हवा — आज दवा का छिड़काव न करें, बर्बाद जाएगी';
          case 'heat': return '🔥 भीषण गर्मी — सुबह जल्दी या शाम को सिंचाई करें';
          case 'frost': return '❄️ पाला पड़ने का ख़तरा — हल्की सिंचाई करें, फ़सल ढकें';
          case 'uv': return '☀️ तेज़ धूप — दोपहर 12 से 3 खेत में काम से बचें';
          default: return '✅ मौसम खेती के कामों के लिए ठीक है';
        }
    }
  }

  if (rain >= 60) {
    tips.add(getTip('rain_high'));
  } else if (rain >= 30) {
    tips.add(getTip('rain_med'));
  }

  if (wind >= 25) {
    tips.add(getTip('wind'));
  }

  if (d.maxTemp >= 40) {
    tips.add(getTip('heat'));
  }
  if (d.minTemp <= 4) {
    tips.add(getTip('frost'));
  }

  if (d.uvIndex >= 8) {
    tips.add(getTip('uv'));
  }

  if (tips.isEmpty) {
    tips.add(getTip('fine'));
  }
  return tips;
}

