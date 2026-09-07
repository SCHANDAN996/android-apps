import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:panchang_engine/panchang_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shahar.dart';

export 'shahar.dart';

/// संकल्प में चुना जाने वाला व्यक्ति। यह केवल इसी फ़ोन में रहता है।
class SankalpPerson {
  final String id;
  final String name;
  final String gotra;

  /// पुरुष या स्त्री — संकल्प का वाक्य इसी से बदलता है (→ A3)।
  ///
  /// पहले हर व्यक्ति पुल्लिंग मान लिया जाता था, इसलिए हर स्त्री के लिए
  /// भी *"…गोत्रोत्पन्नः"* बनता था। पुरानी सहेजी हुई profile में यह
  /// खाना नहीं होगा — वहाँ पुरुष ही मानते हैं, ताकि बर्ताव न बदले।
  final Yajaman yajaman;

  final bool isDefaultProfile;

  const SankalpPerson({
    required this.id,
    required this.name,
    required this.gotra,
    this.yajaman = Yajaman.purush,
    this.isDefaultProfile = false,
  });

  Map<String, String> toJson() => {
        'id': id,
        'name': name,
        'gotra': gotra,
        'yajaman': yajaman.name,
      };

  factory SankalpPerson.fromJson(Map<String, dynamic> json) => SankalpPerson(
        id: json['id'] as String,
        name: json['name'] as String,
        gotra: json['gotra'] as String,
        yajaman: yajamanFromName(json['yajaman'] as String?),
      );
}

/// सहेजे हुए नाम से [Yajaman] — न मिले तो पुरुष (पुराना बर्ताव)।
Yajaman yajamanFromName(String? name) => Yajaman.values.firstWhere(
      (y) => y.name == name,
      orElse: () => Yajaman.purush,
    );

/// सहेजे हुए नाम से [SthanPrakar] — न मिले तो नगर।
SthanPrakar sthanPrakarFromName(String? name) => SthanPrakar.values.firstWhere(
      (s) => s.name == name,
      orElse: () => SthanPrakar.nagar,
    );

/// ऐप की शहर-सूची में जो **पुण्यक्षेत्र** हैं।
///
/// संकल्प में "क्षेत्र" तीर्थों के लिए बोला जाता है, साधारण शहर के लिए
/// "नगर" (→ A5)। ये नाम सूची में पहले से हैं, इसलिए इनके लिए यूज़र से
/// **कुछ पूछना ही नहीं पड़ता** — ऐप ख़ुद सही रूप चुन लेता है।
///
/// ⚠️ यह सूची जान-बूझकर छोटी है। जो नाम इसमें नहीं, वह "नगर" मानकर
/// चलेगा — और यूज़र एक दबाव में बदल सकता है।
const Set<String> tirthaKshetras = {
  'वाराणसी',
  'प्रयागराज',
  'गया',
  'उज्जैन',
  'हरिद्वार',
  'तिरुपति',
};

/// शहर के नाम से अंदाज़ा — तीर्थ है या साधारण नगर।
SthanPrakar sthanPrakarForCity(String cityName) =>
    tirthaKshetras.contains(cityName.trim())
        ? SthanPrakar.kshetra
        : SthanPrakar.nagar;

/// ऐप की सेटिंग — जगह, मास-पद्धति, और यजमान की जानकारी।
///
/// सब कुछ **सिर्फ़ फ़ोन में** रहता है। कोई सर्वर नहीं, कोई लॉगिन नहीं।
/// यूज़र का नाम और गोत्र कहीं नहीं जाता — यह ऐप की बुनियादी बात है।
class AppSettings extends ChangeNotifier {
  static const _kCity = 'city';
  static const _kCityDetails = 'city.v2';
  static const _kMasaSystem = 'masaSystem';
  static const _kName = 'name';
  static const _kGotra = 'gotra';
  static const _kSankalpPeople = 'sankalpPeople.v1';
  static const _kActiveSankalpPerson = 'activeSankalpPerson.v1';
  static const _kLocationPermissionPromptSeen = 'locationPromptSeen.v1';
  static const _kPlayerProgress = 'playerProgress.v1';
  static const _kYajaman = 'yajaman.v1';
  static const _kSthanPrakar = 'sthanPrakar.v1';
  static const _kSthanPrakarChosen = 'sthanPrakarChosen.v1';
  static const _kGotraPataHai = 'gotraPataHai.v1';
  static const _defaultSankalpPersonId = 'default-profile';

  SharedPreferences? _prefs;

  City _city = indianCities.first;
  bool _locationPermissionPromptSeen = false;
  MasaSystem _masaSystem = MasaSystem.purnimanta;
  String _name = '';
  String _gotra = 'कश्यप';
  Yajaman _yajaman = Yajaman.purush;

  /// यूज़र ने कहा है कि उसे अपना गोत्र पता है।
  ///
  /// पहले ऐप चुपचाप "कश्यप" भर देता था और यूज़र को पता ही नहीं चलता
  /// था (→ A12)। अब वह एक चुनाव है, और "पता नहीं" चुनने पर ऐप वजह
  /// भी बताता है ([gotraAgyaatShloka])।
  bool _gotraPataHai = false;
  SthanPrakar _sthanPrakar = SthanPrakar.nagar;

  /// यूज़र ने ख़ुद चुना है या ऐप ने शहर से अंदाज़ा लगाया है।
  /// ख़ुद चुना हो तो शहर बदलने पर उसे मत मिटाओ — गाँव वाला शहर बदलने
  /// पर भी गाँव में ही रहता है।
  bool _sthanPrakarChosen = false;
  String _activeSankalpPersonId = _defaultSankalpPersonId;
  List<SankalpPerson> _additionalSankalpPeople = const [];
  final Map<String, PujaPlayerProgress> _playerProgress = {};

  City get city => _city;
  MasaSystem get masaSystem => _masaSystem;
  String get name => _name;
  String get gotra => _gotra;

  /// यूज़र ने अपना गोत्र ख़ुद बताया है, या ऐप ने "पता नहीं" वाला
  /// कश्यप भरा है?
  bool get gotraPataHai => _gotraPataHai;

  Yajaman get yajaman => _yajaman;

  /// जगह नगर है, गाँव है या तीर्थ (→ A5)।
  SthanPrakar get sthanPrakar => _sthanPrakar;

  /// यूज़र ने ख़ुद चुना, या ऐप ने शहर के नाम से अंदाज़ा लगाया?
  bool get sthanPrakarChosen => _sthanPrakarChosen;

  Place get place => _city.place;
  bool get locationPermissionPromptSeen => _locationPermissionPromptSeen;

  /// यजमान की जानकारी भरी हुई है या नहीं — संकल्प के लिए ज़रूरी।
  bool get hasYajman => _name.trim().isNotEmpty;

  /// संकल्प में उपलब्ध सभी लोग। पहला entry आपकी मौजूदा app profile है।
  List<SankalpPerson> get sankalpPeople => [
        if (hasYajman)
          SankalpPerson(
            id: _defaultSankalpPersonId,
            name: _name,
            gotra: _gotra,
            yajaman: _yajaman,
            isDefaultProfile: true,
          ),
        ..._additionalSankalpPeople,
      ];

  SankalpPerson? get activeSankalpPerson {
    final people = sankalpPeople;
    if (people.isEmpty) return null;
    return people.firstWhere(
      (person) => person.id == _activeSankalpPersonId,
      orElse: () => people.first,
    );
  }

  bool get hasSankalpPerson => activeSankalpPerson != null;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();

    // ── सहेजा हुआ शहर ───────────────────────────────
    //
    // ⚠ कुछ सहेजा न हो तो **डिफ़ॉल्ट पर लौटना ज़रूरी है।** पहले
    // यहाँ कुछ नहीं होता था, यानी `_city` पिछली बार वाला ही बना
    // रह जाता था। जाँच ने पकड़ा (→ D-058)।
    final savedCity = _cityFromJson(_prefs!.getString(_kCityDetails));
    if (savedCity != null) {
      _city = savedCity;
    } else {
      final cityName = _prefs!.getString(_kCity);
      _city = cityName == null
          ? indianCities.first
          : indianCities.firstWhere(
              (c) => c.name == cityName,
              orElse: () => indianCities.first,
            );
    }

    _masaSystem = _prefs!.getString(_kMasaSystem) == 'amanta'
        ? MasaSystem.amanta
        : MasaSystem.purnimanta;
    _name = _prefs!.getString(_kName) ?? '';
    _gotra = _prefs!.getString(_kGotra) ?? gotraJabPataNaHo;
    // पुराने यूज़र, जिन्होंने A12 से पहले गोत्र भरा था — उन्हें दोबारा
    // मत पूछो। गोत्र सहेजा हुआ है, यानी उन्होंने ख़ुद चुना था।
    _gotraPataHai = _prefs!.getBool(_kGotraPataHai) ??
        (_prefs!.getString(_kGotra) != null);
    _yajaman = yajamanFromName(_prefs!.getString(_kYajaman));

    // जगह का प्रकार — यूज़र ने चुना हो तो वही, वरना शहर के नाम से
    // अंदाज़ा (काशी, प्रयाग, गया… तीर्थ हैं; बाक़ी नगर)।
    _sthanPrakarChosen = _prefs!.getBool(_kSthanPrakarChosen) ?? false;
    _sthanPrakar = _sthanPrakarChosen
        ? sthanPrakarFromName(_prefs!.getString(_kSthanPrakar))
        : sthanPrakarForCity(_city.name);

    _activeSankalpPersonId =
        _prefs!.getString(_kActiveSankalpPerson) ?? _defaultSankalpPersonId;
    _loadSankalpPeople(_prefs!.getString(_kSankalpPeople));
    _locationPermissionPromptSeen =
        _prefs!.getBool(_kLocationPermissionPromptSeen) ?? false;
    _loadPlayerProgress(_prefs!.getString(_kPlayerProgress));

    notifyListeners();
  }

  Future<void> setCity(City value) async {
    _city = value;
    // सूर्योदय जगह से बदलता है, इसलिए हिंदू दिन की सीमा भी (→ D-044)।
    _hinduDin = null;
    await _prefs?.setString(_kCity, value.name);
    await _prefs?.setString(_kCityDetails, jsonEncode(value.toJson()));
    // शहर बदला तो प्रकार का अंदाज़ा दोबारा लगाओ — पर सिर्फ़ तब, जब
    // यूज़र ने ख़ुद कुछ नहीं चुना था। चुना हुआ कभी चुपचाप मत बदलो।
    if (!_sthanPrakarChosen) {
      _sthanPrakar = sthanPrakarForCity(value.name);
    }
    notifyListeners();
  }

  /// ── जगह का नाम यूज़र ने ख़ुद लिखा (→ D-058) ───────────
  ///
  /// सूची चाहे जितनी बड़ी हो, गाँव उसमें नहीं आएगा — और संकल्प में
  /// वही नाम बोला जाता है।
  ///
  /// ⚠ नाम बदलने से **पंचांग नहीं बदलता** — अक्षांश-देशांतर वही
  /// रहते हैं। पर जगह का **प्रकार** दोबारा आँका जाता है — कोई
  /// "काशी" लिखे तो वह तीर्थ है, बशर्ते यूज़र ने ख़ुद कुछ न चुना हो।
  Future<void> setSthanNaam(String naam) async {
    final saaf = naam.trim();
    if (saaf.isEmpty) return;
    await setCity(_city.withNaam(saaf));
  }

  /// जगह का प्रकार यूज़र ने ख़ुद चुना — नगर, गाँव या तीर्थ।
  Future<void> setSthanPrakar(SthanPrakar value) async {
    _sthanPrakar = value;
    _sthanPrakarChosen = true;
    await _prefs?.setString(_kSthanPrakar, value.name);
    await _prefs?.setBool(_kSthanPrakarChosen, true);
    notifyListeners();
  }

  /// GPS coordinates ही गणना में जाते हैं; दिखाने के लिए पास का known शहर है।
  Future<void> setCityFromDeviceLocation({
    required double latitude,
    required double longitude,
  }) =>
      setCity(City.fromDeviceLocation(latitude, longitude));

  Future<void> markLocationPermissionPromptSeen() async {
    _locationPermissionPromptSeen = true;
    await _prefs?.setBool(_kLocationPermissionPromptSeen, true);
    notifyListeners();
  }

  City? _cityFromJson(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? City.fromJson(decoded) : null;
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<void> setMasaSystem(MasaSystem value) async {
    _masaSystem = value;
    await _prefs?.setString(
        _kMasaSystem, value == MasaSystem.amanta ? 'amanta' : 'purnimanta');
    notifyListeners();
  }

  Future<void> setYajman({
    String? name,
    String? gotra,
    Yajaman? yajaman,
    bool? gotraPataHai,
  }) async {
    if (name != null) {
      _name = name;
      await _prefs?.setString(_kName, name);
    }
    if (gotra != null) {
      _gotra = gotra;
      await _prefs?.setString(_kGotra, gotra);
    }
    if (yajaman != null) {
      _yajaman = yajaman;
      await _prefs?.setString(_kYajaman, yajaman.name);
    }
    if (gotraPataHai != null) {
      _gotraPataHai = gotraPataHai;
      await _prefs?.setBool(_kGotraPataHai, gotraPataHai);
    }
    notifyListeners();
  }

  Future<void> selectSankalpPerson(String id) async {
    if (!sankalpPeople.any((person) => person.id == id)) return;
    _activeSankalpPersonId = id;
    await _prefs?.setString(_kActiveSankalpPerson, id);
    notifyListeners();
  }

  Future<void> addSankalpPerson({
    required String name,
    required String gotra,
    Yajaman yajaman = Yajaman.purush,
  }) async {
    final person = SankalpPerson(
      id: 'person-${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      gotra: gotra,
      yajaman: yajaman,
    );
    _additionalSankalpPeople = [..._additionalSankalpPeople, person];
    _activeSankalpPersonId = person.id;
    await _saveSankalpPeople();
    await _prefs?.setString(_kActiveSankalpPerson, person.id);
    notifyListeners();
  }

  /// Default profile हटाने पर केवल वही profile साफ़ होती है; बाकी लोग रहेंगे।
  Future<void> removeSankalpPerson(String id) async {
    if (id == _defaultSankalpPersonId) {
      _name = '';
      // गोत्र वाला चुनाव भी साफ़ हो — वरना नया यूज़र फिर चुपचाप
      // कश्यप पर अटक जाएगा (→ A12)।
      _gotraPataHai = false;
      await _prefs?.remove(_kGotraPataHai);
      await _prefs?.remove(_kName);
    } else {
      _additionalSankalpPeople = _additionalSankalpPeople
          .where((person) => person.id != id)
          .toList(growable: false);
      await _saveSankalpPeople();
    }

    if (_activeSankalpPersonId == id) {
      _activeSankalpPersonId = sankalpPeople.isEmpty
          ? _defaultSankalpPersonId
          : sankalpPeople.first.id;
      await _prefs?.setString(_kActiveSankalpPerson, _activeSankalpPersonId);
    }
    notifyListeners();
  }

  Future<void> clearSankalpPeople() async {
    _name = '';
    _additionalSankalpPeople = const [];
    _activeSankalpPersonId = _defaultSankalpPersonId;
    await _prefs?.remove(_kName);
    await _prefs?.remove(_kSankalpPeople);
    await _prefs?.remove(_kActiveSankalpPerson);
    notifyListeners();
  }

  void _loadSankalpPeople(String? raw) {
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _additionalSankalpPeople = decoded
          .whereType<Map<String, dynamic>>()
          .map(SankalpPerson.fromJson)
          .where((person) =>
              person.id.isNotEmpty &&
              person.name.trim().isNotEmpty &&
              person.gotra.isNotEmpty)
          .toList(growable: false);
    } on FormatException {
      _additionalSankalpPeople = const [];
    } on TypeError {
      _additionalSankalpPeople = const [];
    }
  }

  Future<void> _saveSankalpPeople() =>
      _prefs?.setString(
        _kSankalpPeople,
        jsonEncode(
            _additionalSankalpPeople.map((person) => person.toJson()).toList()),
      ) ??
      Future.value();

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

  // ── विधि player में आख़िरी पहुँची हुई जगह ──
  //
  // यह पूजा के धार्मिक रूप से पूरे होने का record नहीं है। सिर्फ़ इतना है कि
  // यूज़र इस फ़ोन पर app में आख़िरी बार किस चरण तक पहुँचा था। Puja JSON या
  // मंत्र कभी store नहीं होते — केवल stable Puja id और technical position।

  /// अधूरी छूटी पूजा **कितनी देर याद रहे** — अगले सूर्योदय तक (→ D-044)।
  ///
  /// ## तीन में से यही क्यों
  ///
  /// | तरीक़ा | दिक़्क़त |
  /// |---|---|
  /// | कई दिन चलती रहे | संकल्प **आज के** पंचांग से बनता है। परसों लौटने पर वो संकल्प बासी है, पर ऐप कहेगा "जहाँ छोड़ा था" |
  /// | रात 12 बजे मिट जाए | **जन्माष्टमी की पूजा आधी रात को ही होती है।** दीपावली प्रदोष में, महाशिवरात्रि निशीथ में — तीनों बीच पूजा में कट जातीं |
  /// | **अगले सूर्योदय पर** | ऐप का अपना दिन यही है, और रात वाली पूजाएँ पूरी बचती हैं |
  ///
  /// गणना महँगी नहीं पड़ती — [HinduDin] अपनी दोनों सीमाएँ साथ लाता है,
  /// इसलिए दिन भर एक ही बार निकलती है।
  HinduDin? _hinduDin;

  HinduDin? _abKaHinduDin() {
    final ab = DateTime.now();
    final pichhla = _hinduDin;
    if (pichhla != null && pichhla.samaayeHai(ab)) return pichhla;
    return _hinduDin = hinduDin(ab, place);
  }

  /// यह सहेजा हुआ पल अभी वाले हिंदू दिन का ही है या नहीं।
  ///
  /// ध्रुवीय इलाक़े में सूरज न उगे तो [hinduDin] `null` देता है — तब कुछ
  /// मत मिटाओ। पूजा चालू रहना, ग़लती से मिट जाने से बेहतर है।
  bool _abhiWaleDinKa(int updatedAt) {
    final din = _abKaHinduDin();
    if (din == null) return true;
    return din.samaayeHai(DateTime.fromMillisecondsSinceEpoch(updatedAt));
  }

  /// सबसे हाल में खुली ऐसी पूजा की id जिसके लिए technical position saved है।
  /// Dashboard इससे केवल एक relevant Vidhi file पढ़ता है; यह completion या
  /// धार्मिक progress का दावा नहीं करता।
  ///
  /// पिछले हिंदू दिन की अधूरी पूजा यहाँ नहीं आती (→ D-044)।
  String? get latestPlayerProgressPujaId {
    final aajKe = _playerProgress.entries
        .where((entry) => _abhiWaleDinKa(entry.value.updatedAt));
    if (aajKe.isEmpty) return null;
    return aajKe
        .reduce((a, b) => a.value.updatedAt >= b.value.updatedAt ? a : b)
        .key;
  }

  /// [pujaId] में सुरक्षित रूप से फिर खुल सकने वाली आख़िरी app position।
  ///
  /// Stale step index current content length में clamp हो जाता है; corrupt या
  /// initial-step records resume prompt नहीं बनाते।
  PujaPlayerProgress? playerProgressFor(String pujaId, int totalSteps) {
    if (pujaId.trim().isEmpty || totalSteps <= 1) return null;
    final saved = _playerProgress[pujaId];
    if (saved == null || saved.lastReachedStepIndex <= 0) return null;
    // कल की अधूरी पूजा आज नहीं उठती (→ D-044)।
    if (!_abhiWaleDinKa(saved.updatedAt)) return null;
    final safeIndex = saved.lastReachedStepIndex.clamp(1, totalSteps - 1);
    return saved.copyWith(
      lastReachedStepIndex: safeIndex,
      totalStepsAtSave: totalSteps,
    );
  }

  /// Furthest app step is retained when the user moves back to reread a step.
  /// This avoids silently losing a useful resume position through navigation.
  Future<void> recordLastReachedStep({
    required String pujaId,
    required int stepIndex,
    required int totalSteps,
  }) async {
    if (pujaId.trim().isEmpty || totalSteps <= 1 || stepIndex <= 0) return;
    final safeIndex = stepIndex.clamp(1, totalSteps - 1);
    final previous = _playerProgress[pujaId];
    final furthest =
        previous == null || previous.lastReachedStepIndex < safeIndex
            ? safeIndex
            : previous.lastReachedStepIndex;
    if (previous != null &&
        previous.lastReachedStepIndex == furthest &&
        previous.totalStepsAtSave == totalSteps) {
      return;
    }

    _playerProgress[pujaId] = PujaPlayerProgress(
      lastReachedStepIndex: furthest,
      totalStepsAtSave: totalSteps,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await _writePlayerProgress();
    notifyListeners();
  }

  /// Completion clears only the active technical resume location. No history,
  /// completion count, religious validity, or completion date is retained.
  Future<void> clearPlayerProgress(String pujaId) async {
    if (_playerProgress.remove(pujaId) == null) return;
    await _writePlayerProgress();
    notifyListeners();
  }

  void _loadPlayerProgress(String? raw) {
    _playerProgress.clear();
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      for (final entry in decoded.entries) {
        if (entry.key is! String || entry.key.trim().isEmpty) continue;
        final progress = PujaPlayerProgress.fromJson(entry.value);
        if (progress == null) continue;
        // बीते हिंदू दिन की अधूरी पूजा पढ़ी ही नहीं जाती — इसलिए वो
        // फ़ोन में पड़ी-पड़ी जमा भी नहीं होती (→ D-044)।
        if (!_abhiWaleDinKa(progress.updatedAt)) continue;
        _playerProgress[entry.key as String] = progress;
      }
    } catch (_) {
      // Corrupt local progress must never stop a Puja from opening.
    }
  }

  Future<void> _writePlayerProgress() async {
    final encoded = jsonEncode(
      _playerProgress.map((id, progress) => MapEntry(id, progress.toJson())),
    );
    try {
      await _prefs?.setString(_kPlayerProgress, encoded);
    } catch (_) {
      // Keep the in-memory state usable even if platform storage fails.
    }
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

/// A technical app-navigation position, never a claim of ritual completion.
class PujaPlayerProgress {
  final int lastReachedStepIndex;
  final int totalStepsAtSave;
  final int updatedAt;

  const PujaPlayerProgress({
    required this.lastReachedStepIndex,
    required this.totalStepsAtSave,
    required this.updatedAt,
  });

  PujaPlayerProgress copyWith({
    int? lastReachedStepIndex,
    int? totalStepsAtSave,
    int? updatedAt,
  }) =>
      PujaPlayerProgress(
        lastReachedStepIndex: lastReachedStepIndex ?? this.lastReachedStepIndex,
        totalStepsAtSave: totalStepsAtSave ?? this.totalStepsAtSave,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, int> toJson() => {
        'lastReachedStepIndex': lastReachedStepIndex,
        'totalStepsAtSave': totalStepsAtSave,
        'updatedAt': updatedAt,
      };

  static PujaPlayerProgress? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final index = raw['lastReachedStepIndex'];
    final total = raw['totalStepsAtSave'];
    final updatedAt = raw['updatedAt'];
    if (index is! int || total is! int || updatedAt is! int) return null;
    if (index < 0 || total < 1 || updatedAt < 0) return null;
    return PujaPlayerProgress(
      lastReachedStepIndex: index,
      totalStepsAtSave: total,
      updatedAt: updatedAt,
    );
  }
}
