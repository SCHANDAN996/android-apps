import 'dart:async';

import 'package:flutter/material.dart';

import '../services/device_location_service.dart';
import '../services/osm_khoj.dart';
import '../state/gaon.dart';
import '../state/shahar.dart';
import '../theme.dart';
import 'design_system.dart';

/// एक खोज, दो सूचियाँ (→ D-128): पहले ऐप के अपने ~500 शहर (हिंदी नाम, पंचांग के
/// लिए जाँचे हुए), फिर साढ़े पाँच लाख गाँव-क़स्बे (`gaon.dart`, अंग्रेज़ी नाम)।
///
/// गाँव वाली सूची पहली बार खुलने में लगभग एक सेकंड लेती है — [jagahKhojTaiyar]
/// खोज वाले खाने को छूते ही बुला लो।
Future<List<JagahMila>> jagahKhojo(String khoj, {int shahar = 4, int gaon = 12}) async {
  final q = khoj.trim();
  if (q.isEmpty) return const [];
  final apne = shaharKhojo(q).take(shahar).toList();
  if (q.length < 2) return [for (final c in apne) JagahMila(c, false)];
  final suchi = await GaonSuchi.khulo();
  final gaonMile = suchi.khojo(q, kitne: gaon + apne.length);
  final out = [for (final c in apne) JagahMila(c, false)];
  for (final g in gaonMile) {
    // वही शहर दोबारा नहीं — नाम का ढाँचा एक और जगह पास-पास
    final dohra = apne.any((c) =>
        devDhanche(c.name).contains(romanDhancha(g.naam)) &&
        (c.latitude - g.latitude).abs() < 0.15 &&
        (c.longitude - g.longitude).abs() < 0.15);
    if (!dohra) out.add(JagahMila(g.city, true));
    if (out.length >= apne.length + gaon) break;
  }
  return out;
}

/// गाँवों की सूची पहले से खुलवा दो (नतीजे का इंतज़ार नहीं)।
void jagahKhojTaiyar() => unawaited(GaonSuchi.khulo());

/// खोज का एक नतीजा। [gaonSuchiSe] = नाम अंग्रेज़ी अक्षरों में है, ऐप के अपने शहरों में नहीं।
class JagahMila {
  final City city;
  final bool gaonSuchiSe;
  const JagahMila(this.city, this.gaonSuchiSe);
}

/// जगह चुनने का **एक** पन्ना — सेटिंग (संकल्प, पंचांग), कुंडली का जन्म-स्थान और
/// पूर्वज की जगह, तीनों में यही (→ D-128, D-129, D-134)। चुनी जगह `Navigator.pop` से
/// [City] बनकर लौटती है।
///
/// ## सीधा रखा है — जान-बूझकर (D-134)
/// डेवलपर (23 अक्टूबर 2026): *"एक सिंपल सी चीज़ location — तुम इसको इतना complicated बना
/// चुके हो कि यूज़र परेशान हो जाए, फिर भी सही location न add कर सके।"* पहले यहाँ तीन
/// हिस्से थे (इंटरनेट से / ऐप की सूची से / गाँव और क़स्बे), हर एक का शीर्षक और समझाइश,
/// एक बड़ा बटन, और गाँव चुनने पर एक और dialog। अब:
/// 1. सबसे ऊपर «फ़ोन की अभी की जगह लें» (जहाँ यह काम का है) — एक टैप में काम ख़त्म;
/// 2. एक खोज-डिब्बा, उसके नीचे **एक ही सूची** — लिखते ही ऐप की अपनी सूची (शहर, फिर
///    गाँव), और लिखना ज़रा रुकते ही **अपने-आप इंटरनेट से भी** (कोई बटन नहीं — डेवलपर:
///    *"लिखने से इंटरनेट से auto search होता रहे, बटन दबाकर न खोजना पड़े"*); इंटरनेट
///    वाले नतीजे उसी सूची में सबसे ऊपर।
class JagahKhojSheet extends StatefulWidget {
  final ScrollController controller;
  final City? selectedCity;
  final String shirshak;

  /// «फ़ोन की अभी की जगह लें» के नीचे की छोटी लाइन; `null` = वह पंक्ति ही नहीं
  /// (पूर्वज की जगह — वहाँ फ़ोन की अभी की जगह का कोई मतलब नहीं)।
  final String? phoneKiJagah;

  /// जाँचों के लिए — असली फ़ोन पर `DeviceLocationService`।
  final Future<DeviceLocationResult> Function()? jagahLo;

  const JagahKhojSheet({
    super.key,
    required this.controller,
    this.selectedCity,
    this.shirshak = 'जगह चुनें',
    this.phoneKiJagah,
    this.jagahLo,
  });

  @override
  State<JagahKhojSheet> createState() => _JagahKhojSheetState();
}

class _JagahKhojSheetState extends State<JagahKhojSheet> {
  final _search = TextEditingController();

  /// गाँवों की सूची से (→ D-128)
  List<JagahMila> _gaon = const [];
  int _khojKram = 0;

  /// इंटरनेट से (→ D-129) — `null` = इस शब्द पर अभी नहीं खोजा
  List<OsmJagah>? _online;
  bool _onlineChal = false;
  String? _onlineHaal;
  String _onlineKhoj = '';
  bool _band = false;

  bool _gpsChal = false;
  String? _gpsGalti;

  /// लिखना रुकने का इंतज़ार — हर अक्षर पर इंटरनेट नहीं, ठहराव पर एक बार
  Timer? _thahrav;
  static const _thahravKaSamay = Duration(milliseconds: 700);

  @override
  void initState() {
    super.initState();
    jagahKhojTaiyar();
  }

  @override
  void dispose() {
    _band = true;
    _thahrav?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _onlineKhojo() async {
    final q = _search.text.trim();
    if (q.length < 3) return;
    // यही शब्द पहले से खोजा जा रहा है, या उसका जवाब आ चुका
    if (q == _onlineKhoj && (_onlineChal || _online != null)) return;
    setState(() {
      _onlineChal = true;
      _onlineHaal = null;
      _onlineKhoj = q;
      _online = null;
    });
    try {
      final mile = await osmKhoj.khojo(
        q,
        haal: (h) {
          if (mounted) setState(() => _onlineHaal = h);
        },
        // पन्ना बंद हुआ या खोज का शब्द बदल गया — यह खोज छोड़ो
        radd: () => _band || _search.text.trim() != q,
      );
      if (!mounted || _search.text.trim() != q) return;
      setState(() {
        _online = mile;
        _onlineChal = false;
      });
    } on OsmRadd {
      // शब्द बदल गया — नई खोज अपना हाल ख़ुद दिखाएगी
      if (mounted && !_band && _onlineKhoj == q) {
        setState(() => _onlineChal = false);
      }
    }
  }

  Future<void> _gaonKhojo(String q) async {
    final kram = ++_khojKram;
    final mile = q.trim().length < 2
        ? const <JagahMila>[]
        : (await jagahKhojo(q, shahar: 0, gaon: 15));
    if (mounted && kram == _khojKram) setState(() => _gaon = mile);
  }

  Future<void> _phoneKiJagah() async {
    setState(() {
      _gpsChal = true;
      _gpsGalti = null;
    });
    final lo = widget.jagahLo ??
        () => const DeviceLocationService().getCurrentLocation();
    final r = await lo();
    if (!mounted) return;
    if (!r.hasPosition) {
      setState(() {
        _gpsChal = false;
        _gpsGalti = switch (r.failure) {
          DeviceLocationFailure.serviceDisabled =>
            'फ़ोन में स्थान (GPS) बंद है — चालू करें, या नीचे नाम लिखकर खोजें।',
          DeviceLocationFailure.permissionDenied =>
            'स्थान की अनुमति नहीं मिली — नीचे नाम लिखकर खोजें।',
          _ => 'जगह नहीं मिल पाई — नीचे नाम लिखकर खोजें।',
        };
      });
      return;
    }
    final a = r.latitude!, d = r.longitude!;
    if (a < 6 || a > 37.5 || d < 68 || d > 97.5) {
      setState(() {
        _gpsChal = false;
        _gpsGalti = 'यह जगह भारत के बाहर की है — नीचे नाम लिखकर खोजें।';
      });
      return;
    }
    Navigator.of(context).pop(City.fromDeviceLocation(a, d));
  }

  /// एक सूची: इंटरनेट वाले पहले, फिर ऐप के शहर, फिर गाँव — एक ही जगह दोबारा नहीं।
  List<City> _sab() {
    final q = _search.text.trim();
    if (q.isEmpty) return const [];
    final out = <City>[];
    bool dohra(City c) => out.any((o) =>
        (o.latitude - c.latitude).abs() < 0.05 &&
        (o.longitude - c.longitude).abs() < 0.05 &&
        (o.name == c.name ||
            devDhanche(o.name).contains(romanDhancha(c.name)) ||
            devDhanche(c.name).contains(romanDhancha(o.name))));
    void jodo(City c) {
      if (!dohra(c)) out.add(c);
    }

    if (q == _onlineKhoj) {
      for (final o in _online ?? const <OsmJagah>[]) {
        jodo(City(o.naam, o.pata.isEmpty ? 'भारत' : o.pata, o.latitude,
            o.longitude));
      }
    }
    shaharKhojo(q).forEach(jodo);
    for (final g in _gaon) {
      jodo(g.city);
    }
    // इंटरनेट-सेवा मिलते-जुलते नाम भी देती है («Bihta» पर Bihla, Birta, Bhita) — फ़ोन पर
    // वे ऐप की सूची के असली «Bihta» गाँवों से ऊपर दिखे। इसलिए क्रम: हूबहू नाम, फिर
    // शुरुआत मिले, फिर बाक़ी; बराबरी पर पहले जैसा (इंटरनेट, शहर, गाँव)।
    final chhota = q.toLowerCase();
    int darja(City c) {
      final n = c.name.toLowerCase();
      if (n == chhota) return 0;
      if (n.startsWith(chhota)) return 1;
      return 2;
    }

    final kram = {for (var i = 0; i < out.length; i++) out[i]: i};
    out.sort((x, y) {
      final d = darja(x).compareTo(darja(y));
      return d != 0 ? d : kram[x]!.compareTo(kram[y]!);
    });
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final type = VidhivatTheme.typographyOf(context);
    final colors = VidhivatTheme.colorsOf(context);
    final likha = _search.text.trim();
    final sab = _sab();
    final onlineDikhe = likha == _onlineKhoj && (_online?.isNotEmpty ?? false);

    return ListView(
      controller: widget.controller,
      padding: const EdgeInsets.fromLTRB(
        VidhivatSpacing.lg,
        0,
        VidhivatSpacing.lg,
        VidhivatSpacing.xxl,
      ),
      children: [
        Text(widget.shirshak, style: type.sectionTitle),
        const SizedBox(height: VidhivatSpacing.md),

        // ── १ · फ़ोन की अभी की जगह ──
        if (widget.phoneKiJagah != null) ...[
          VidhivatSurfaceCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              key: const Key('phone_ki_jagah'),
              leading: _gpsChal
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.my_location, color: colors.primary),
              title: const Text('फ़ोन की अभी की जगह लें'),
              subtitle: Text(widget.phoneKiJagah!),
              onTap: _gpsChal ? null : _phoneKiJagah,
            ),
          ),
          if (_gpsGalti != null)
            Padding(
              padding: const EdgeInsets.only(top: VidhivatSpacing.xs),
              child: Text(_gpsGalti!,
                  style: type.bodySmall.copyWith(color: colors.textSecondary)),
            ),
          const SizedBox(height: VidhivatSpacing.md),
        ],

        // ── २ · नाम से खोज ──
        TextField(
          key: const Key('jagah_khoj'),
          controller: _search,
          autofocus: widget.phoneKiJagah == null,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) {
            _thahrav?.cancel();
            _onlineKhojo();
          },
          onChanged: (v) {
            setState(() {
              if (v.trim() != _onlineKhoj) _onlineChal = false;
            });
            _gaonKhojo(v);
            _thahrav?.cancel();
            _thahrav = Timer(_thahravKaSamay, _onlineKhojo);
          },
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'गाँव या शहर का नाम लिखें',
            border: OutlineInputBorder(),
          ),
        ),
        if (_onlineChal) ...[
          const SizedBox(height: VidhivatSpacing.xs),
          const LinearProgressIndicator(minHeight: 2),
          // सिर्फ़ इंतज़ार हो तभी लाइन — "इंटरनेट नहीं मिला — 8 सेकंड में फिर कोशिश…"
          if (_onlineHaal != null)
            Padding(
              padding: const EdgeInsets.only(top: VidhivatSpacing.xxs),
              child: Text(_onlineHaal!,
                  style: type.bodySmall.copyWith(color: colors.textSecondary)),
            ),
        ],
        const SizedBox(height: VidhivatSpacing.sm),

        // ── ३ · एक ही सूची ──
        for (final c in sab)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.place_outlined),
            title: Text(c.name),
            subtitle: Text(c.state),
            selected: c.name == widget.selectedCity?.name &&
                c.state == widget.selectedCity?.state,
            onTap: () => Navigator.of(context).pop(c),
          ),
        if (sab.isEmpty && likha.length >= 3 && likha == _onlineKhoj && !_onlineChal)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: VidhivatSpacing.sm),
            child: Text(
                'इस नाम की जगह नहीं मिली — दूसरी वर्तनी, या पास का क़स्बा लिखें।'),
          ),
        // ODbL लाइसेंस की शर्त — जहाँ OpenStreetMap का डेटा दिखे, वहीं श्रेय (→ D-129)
        if (onlineDikhe)
          Padding(
            padding: const EdgeInsets.only(top: VidhivatSpacing.xs),
            child: Text('कुछ जगहों का डेटा © OpenStreetMap contributors',
                style: type.caption.copyWith(color: colors.textTertiary)),
          ),
      ],
    );
  }
}

/// [JagahKhojSheet] खोलो — चुनी जगह लौटती है, या `null`।
Future<City?> jagahChuno(
  BuildContext context, {
  City? selectedCity,
  String shirshak = 'जगह चुनें',
  String? phoneKiJagah,
  Future<DeviceLocationResult> Function()? jagahLo,
}) =>
    showModalBottomSheet<City>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        builder: (context, controller) => JagahKhojSheet(
          controller: controller,
          selectedCity: selectedCity,
          shirshak: shirshak,
          phoneKiJagah: phoneKiJagah,
          jagahLo: jagahLo,
        ),
      ),
    );
