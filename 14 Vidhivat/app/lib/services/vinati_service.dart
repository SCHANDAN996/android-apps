import 'package:shared_preferences/shared_preferences.dart';

/// **विनती की बही** — ऐप में कितनी बार आए, और दक्षिणा की विनती कब (→ D-132,
/// `docs/32_VINATI_YOJANA.md`)।
///
/// डेवलपर (23 अक्टूबर 2026): *"10 visit के बाद अगर नहीं दिए हैं एक बार भी, तो
/// माँग लो दक्षिणा।"*
///
/// ## नियम
/// - **एक आना = एक बैठक:** ऐप ठंडा खुले, या [baithakKaFasla] से ज़्यादा पीछे पड़ा
///   रहकर सामने आए। फ़ोन घुमाना या दो मिनट किसी और ऐप में जाना नहीं गिनता।
/// - **पहली विनती:** [pehliBaar]वाँ आना, और ऐप को पहली बार देखे [kamSeKamDin] हो
///   चुके हों — नया आदमी पहले दिन दस बार खोल ले तो उससे माँगना जल्दबाज़ी है।
/// - **"अभी नहीं" के बाद:** 20 आने बाद, फिर 40 बाद; **कुल तीन बार**, फिर कभी नहीं।
/// - **कभी दी हो** (`DakshinaBahi.kabhiDiThi`) — कभी नहीं। "एक बार भी नहीं दी"
///   डेवलपर की शर्त है।
/// - एक बैठक में एक बार; दो विनतियों में कम से कम [doVinatiMeinFasla]।
/// - जिस बैठक में notification दबाकर आए (आदमी स्मरण के लिए आया है), या जिसमें
///   पूजा-पूर्ण वाला दक्षिणा-डिब्बा दिख चुका — उसमें नहीं।
///
/// गिनती और तारीख़ें सिर्फ़ फ़ोन में — कोई सर्वर, कोई analytics नहीं।
class VinatiBahi {
  static const _kGinti = 'vinatiAagamanGinti.v1';
  static const _kPehlaDin = 'vinatiPehlaDin.v1';
  static const _kKitni = 'vinatiDakshinaKitni.v1';
  static const _kAgli = 'vinatiDakshinaAgli.v1';
  static const _kAakhiri = 'vinatiAakhiriKab.v1';

  static const pehliBaar = 10;
  static const kamSeKamDin = Duration(days: 7);
  static const zyadaSeZyada = 3;
  static const baithakKaFasla = Duration(minutes: 30);
  static const doVinatiMeinFasla = Duration(days: 2);

  /// "अभी नहीं" के बाद कितने आने बाद फिर — पहली के बाद 20, दूसरी के बाद 40।
  static int phirKitneBaad(int kitniHoChuki) => kitniHoChuki <= 1 ? 20 : 40;

  SharedPreferences? _prefs;
  int _ginti = 0;
  DateTime? _pehlaDin;
  int _kitni = 0;
  int _agli = pehliBaar;
  DateTime? _aakhiri;

  // ── इस बैठक की बातें (फ़ोन में भी नहीं रखी जातीं) ──
  DateTime? _peechheGayaKab;
  DateTime? _notificationKab;
  bool _notificationSe = false;
  bool _isBaithakMeinHoChuki = false;

  int get ginti => _ginti;
  int get kitniBaarPoochhi => _kitni;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    _ginti = _prefs!.getInt(_kGinti) ?? 0;
    _pehlaDin = _samay(_prefs!.getInt(_kPehlaDin));
    _kitni = _prefs!.getInt(_kKitni) ?? 0;
    _agli = _prefs!.getInt(_kAgli) ?? pehliBaar;
    _aakhiri = _samay(_prefs!.getInt(_kAakhiri));
  }

  /// नई बैठक — ऐप ठंडा खुला, या बहुत देर बाद सामने आया।
  Future<void> baithakShuru(DateTime ab) async {
    _ginti++;
    _pehlaDin ??= ab;
    _isBaithakMeinHoChuki = false;
    // notification दबाने की ख़बर बैठक गिनने से ज़रा पहले भी आ सकती है
    final n = _notificationKab;
    _notificationSe = n != null && ab.difference(n).abs() < const Duration(seconds: 10);
    _peechheGayaKab = null;
    await _prefs?.setInt(_kGinti, _ginti);
    await _prefs?.setInt(_kPehlaDin, _pehlaDin!.millisecondsSinceEpoch);
  }

  /// ऐप पीछे गया।
  void peechhe(DateTime ab) => _peechheGayaKab = ab;

  /// ऐप फिर सामने आया — बहुत देर बाद, तो नई बैठक।
  Future<void> saamne(DateTime ab) async {
    final gaya = _peechheGayaKab;
    _peechheGayaKab = null;
    if (gaya != null && ab.difference(gaya) >= baithakKaFasla) {
      await baithakShuru(ab);
    }
  }

  /// यह बैठक notification दबाकर आई।
  void notificationSeAaya(DateTime ab) {
    _notificationKab = ab;
    _notificationSe = true;
  }

  /// पूजा-पूर्ण वाला दक्षिणा-डिब्बा इस बैठक में दिख चुका — अब पट्टी नहीं।
  void dakshinaDibbaDikha() => _isBaithakMeinHoChuki = true;

  /// अभी दक्षिणा की विनती करें?
  bool dakshinaPoochhen(DateTime ab, {required bool kabhiDiThi}) {
    if (kabhiDiThi || _notificationSe || _isBaithakMeinHoChuki) return false;
    if (_kitni >= zyadaSeZyada || _ginti < _agli) return false;
    final pehla = _pehlaDin;
    if (pehla == null || ab.difference(pehla) < kamSeKamDin) return false;
    final aakhiri = _aakhiri;
    if (aakhiri != null && ab.difference(aakhiri) < doVinatiMeinFasla) {
      return false;
    }
    return true;
  }

  /// विनती दिखा दी — गिनो, और अगली कब।
  Future<void> dakshinaPoochhi(DateTime ab) async {
    _kitni++;
    _agli = _ginti + phirKitneBaad(_kitni);
    _aakhiri = ab;
    _isBaithakMeinHoChuki = true;
    await _prefs?.setInt(_kKitni, _kitni);
    await _prefs?.setInt(_kAgli, _agli);
    await _prefs?.setInt(_kAakhiri, ab.millisecondsSinceEpoch);
  }

  static DateTime? _samay(int? millis) =>
      millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
}

/// पूरे ऐप की एक बही।
final vinati = VinatiBahi();
