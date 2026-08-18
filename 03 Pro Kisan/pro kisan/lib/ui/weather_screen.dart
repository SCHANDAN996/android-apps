import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../blocs/app_cubit.dart';
import '../data/india_cities.dart';
import '../data/weather_models.dart';
import '../l10n/app_localizations.dart';
import '../services/weather_service.dart';
import 'theme/dairy_theme.dart';
import 'weather/weather_common.dart';
import 'weather/weather_detail_sheet.dart';

/// ☀️ मौसम — किसान के काम का।
///
/// पहले की सबसे बड़ी शिकायत "देर से खुलता है" यहीं ठीक हुई है:
/// अब **cache पहले** दिखता है (तुरंत), ताज़ा data पीछे-पीछे आकर बदल देता है।
/// पहले GPS(10s) → नाम(4s) → API(15s) का इंतज़ार होता था — यानी सबसे बुरी
/// हालत में 29 सेकंड तक ख़ाली स्क्रीन।
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _svc = WeatherService.instance;

  List<WeatherPlace> _places = [];
  int _selected = 0;

  WeatherData? _data;

  /// cache कितना पुराना है (मिनट)। null = अभी-अभी का ताज़ा data।
  int? _cacheAgeMin;

  bool _loading = true;
  bool _refreshing = false;
  String? _error;

  int _selectedDay = 0;

  String _t(String k) => AppLocalizations.get(context, k);
  bool get _isHi => AppLocalizations.isHindiLike(context);
  String get _lang => AppLocalizations.langCode(context);

  String _subtitleCapital(String lang) {
    switch (lang) {
      case 'mr': return 'राज्य राजधानी';
      case 'pa': return 'ਰਾਜ ਦੀ ਰਾਜਧਾਨੀ';
      case 'gu': return 'રાજ્ય પાટનગર';
      case 'bn': return 'রাজ্য রাজধানী';
      case 'te': return 'రాష్ట్ర రాజధాని';
      case 'ta': return 'மாநில தலைநகரம்';
      case 'kn': return 'ರಾಜ್ಯ ರಾಜಧಾನಿ';
      case 'hi': case 'bho': return 'राज्य राजधानी';
      default: return 'State capital';
    }
  }

  String _subtitleMyLocation(String lang) {
    switch (lang) {
      case 'mr': return 'माझे स्थान';
      case 'pa': return 'ਮੇਰੀ ਜਗ੍ਹਾ';
      case 'gu': return 'મારું સ્થાન';
      case 'bn': return 'আমার স্থান';
      case 'te': return 'నా స్థానం';
      case 'ta': return 'என் இடம்';
      case 'kn': return '<ctrl42>ನನ್ನ ಸ್ಥಳ';
      case 'hi': case 'bho': return 'मेरी जगह';
      default: return 'My location';
    }
  }

  WeatherPlace? get _place =>
      _places.isEmpty ? null : _places[_selected.clamp(0, _places.length - 1)];

  @override
  void initState() {
    super.initState();
    _boot();
  }

  // ── शुरुआत: cache पहले, ताज़ा बाद में ──────────────────────────────────
  Future<void> _boot() async {
    var places = await _svc.getPlaces();

    if (places.isEmpty) {
      final code = mounted ? context.read<AppCubit>().state.stateCode : 'UP';
      final cap = _capitalOf(code);
      places = [
        WeatherPlace(
          name: cap.$1,
          subtitle: _subtitleCapital(_lang),
          lat: cap.$2,
          lon: cap.$3,
          isCurrent: true,
        )
      ];
      await _svc.savePlaces(places);
    }

    if (!mounted) return;
    setState(() => _places = places);

    await _showFromCache();

    unawaited(_refresh(silent: _data != null));
    unawaited(_updateCurrentPlaceFromGps());
  }

  Future<void> _showFromCache() async {
    final p = _place;
    if (p == null) return;
    final c = await _svc.readCache(p);
    if (!mounted) return;
    if (c == null) {
      setState(() => _loading = _data == null);
      return;
    }
    setState(() {
      _data = WeatherData.fromApi(c.data);
      _cacheAgeMin = c.ageMinutes;
      _loading = false;
      _selectedDay = 0;
    });
  }

  /// ताज़ा मौसम लाओ। [silent] = पहले से कुछ दिख रहा है, इसलिए loader मत दिखाओ।
  Future<void> _refresh({bool silent = false}) async {
    final p = _place;
    if (p == null) return;

    if (mounted) {
      setState(() {
        _refreshing = true;
        if (!silent) _loading = _data == null;
        _error = null;
      });
    }

    try {
      final raw = await _svc.fetch(p);
      await _svc.writeCache(p, raw);
      if (!mounted) return;
      final parsed = WeatherData.fromApi(raw);
      setState(() {
        _data = parsed;
        _cacheAgeMin = null;
        _loading = false;
        _refreshing = false;
        if (parsed.daily.isNotEmpty) {
          _selectedDay = _selectedDay.clamp(0, parsed.daily.length - 1);
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _refreshing = false;
        _loading = false;
        if (_data == null) _error = _t('wDataError');
      });
    }
  }

  /// GPS से "मेरी जगह" सुधारो
  Future<void> _updateCurrentPlaceFromGps() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );

      final idx = _places.indexWhere((p) => p.isCurrent);
      if (idx == -1) return;

      var placeName = _places[idx].name;
      final real = await _svc.reverseGeocode(pos.latitude, pos.longitude,
          isHi: _isHi, langCode: _lang);
      if (real != null) placeName = real;

      final updated = WeatherPlace(
        name: placeName,
        subtitle: _subtitleMyLocation(_lang),
        lat: pos.latitude,
        lon: pos.longitude,
        isCurrent: true,
      );
      _places[idx] = updated;
      await _svc.savePlaces(_places);

      if (!mounted) return;
      setState(() {});
      if (_selected == idx) unawaited(_refresh(silent: true));
    } catch (_) {
    }
  }

  (String, double, double) _capitalOf(String code) {
    const caps = <String, (String, double, double)>{
      'UP': ('लखनऊ', 26.85, 80.95), 'BR': ('पटना', 25.59, 85.14),
      'MP': ('भोपाल', 23.26, 77.41), 'RJ': ('जयपुर', 26.91, 75.79),
      'HR': ('चंडीगढ़', 30.73, 76.78), 'PB': ('चंडीगढ़', 30.73, 76.78),
      'MH': ('मुंबई', 19.08, 72.88), 'GJ': ('गांधीनगर', 23.22, 72.68),
      'WB': ('कोलकाता', 22.57, 88.36), 'TN': ('चेन्नई', 13.08, 80.27),
      'KA': ('बेंगलुरु', 12.97, 77.59), 'TS': ('हैदराबाद', 17.38, 78.48),
      'AP': ('अमरावती', 16.51, 80.51), 'KL': ('तिरुवनंतपुरम', 8.52, 76.94),
      'OD': ('भुवनेश्वर', 20.30, 85.82), 'JH': ('रांची', 23.34, 85.31),
      'CG': ('रायपुर', 21.25, 81.63), 'UK': ('देहरादून', 30.32, 78.03),
      'AS': ('गुवाहाटी', 26.14, 91.74), 'HP': ('शिमला', 31.10, 77.17),
      'JK': ('श्रीनगर', 34.08, 74.80),
    };
    return caps[code] ?? ('दिल्ली', 28.61, 77.21);
  }

  // ── जगह बदलना / जोड़ना / हटाना ────────────────────────────────────────
  Future<void> _switchPlace(int i) async {
    if (i == _selected) return;
    setState(() {
      _selected = i;
      _data = null;
      _loading = true;
      _selectedDay = 0;
    });
    await _showFromCache();
    unawaited(_refresh(silent: _data != null));
  }

  Future<void> _useGpsNow() async {
    void snack(String msg, {String? action, VoidCallback? onAction}) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 4),
        action: (action != null && onAction != null)
            ? SnackBarAction(
                label: action, textColor: Colors.white, onPressed: onAction)
            : null,
      ));
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      snack(_t('wGpsOff'),
          action: _t('openSettings'),
          onAction: () => Geolocator.openLocationSettings());
      return;
    }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) {
      snack(_t('wGpsDeniedForever'),
          action: _t('openSettings'),
          onAction: () => Geolocator.openAppSettings());
      return;
    }
    if (perm == LocationPermission.denied) {
      snack(_t('wGpsDenied'));
      return;
    }

    snack(_t('wGpsFinding'));

    Position? pos;
    try {
      pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } catch (_) {
      try {
        pos = await Geolocator.getLastKnownPosition();
      } catch (_) {}
    }
    if (pos == null) {
      snack(_t('wGpsFailed'));
      return;
    }

    var placeName = _subtitleMyLocation(_lang);
    final real =
        await _svc.reverseGeocode(pos.latitude, pos.longitude, isHi: _isHi, langCode: _lang);
    if (real != null) placeName = real;

    final updated = WeatherPlace(
      name: placeName,
      subtitle: _subtitleMyLocation(_lang),
      lat: pos.latitude,
      lon: pos.longitude,
      isCurrent: true,
    );

    final idx = _places.indexWhere((p) => p.isCurrent);
    if (idx == -1) {
      _places.insert(0, updated);
    } else {
      _places[idx] = updated;
    }
    await _svc.savePlaces(_places);

    if (!mounted) return;
    setState(() {
      _selected = _places.indexWhere((p) => p.isCurrent).clamp(0, _places.length - 1);
      _data = null;
      _loading = true;
      _selectedDay = 0;
    });
    await _showFromCache();
    await _refresh(silent: _data != null);
    snack(_t('wGpsUpdated'));
  }

  Future<void> _addPlaceFlow() async {
    if (_places.length >= WeatherService.maxPlaces) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_t('wMaxPlaces'))));
      return;
    }
    final picked = await showModalBottomSheet<WeatherPlace>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CitySearchSheet(),
    );
    if (picked == null) return;

    await _svc.addPlace(picked);
    final places = await _svc.getPlaces();
    if (!mounted) return;
    setState(() {
      _places = places;
      _selected = places.indexWhere((p) => p.sameSpotAs(picked)).clamp(0, places.length - 1);
      _data = null;
      _loading = true;
      _selectedDay = 0;
    });
    await _showFromCache();
    unawaited(_refresh(silent: _data != null));
  }

  Future<void> _removePlace(WeatherPlace p) async {
    if (p.isCurrent) return;
    await _svc.removePlace(p);
    final places = await _svc.getPlaces();
    if (!mounted) return;
    setState(() {
      _places = places;
      _selected = 0;
      _data = null;
      _loading = true;
    });
    await _showFromCache();
    unawaited(_refresh(silent: _data != null));
  }

  // ── UI ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final rainy = (_data?.current.weatherCode ?? 0) >= 51;
    final sky = skyGradient(DateTime.now(), rainy: rainy);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: RefreshIndicator(
        onRefresh: () => _refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _header(sky),
            if (_loading && _data == null)
              const SliverFillRemaining(
                  hasScrollBody: false, child: _WeatherSkeleton())
            else if (_error != null && _data == null)
              SliverFillRemaining(hasScrollBody: false, child: _errorView())
            else if (_data != null) ...[
              SliverToBoxAdapter(child: _daysSection(_data!)),
              SliverToBoxAdapter(child: _hourlySection(_data!)),
              const SliverToBoxAdapter(child: SizedBox(height: 26)),
            ],
          ],
        ),
      ),
    );
  }

  /// ऊपर का हिस्सा: जगहों की पट्टी + आज का बड़ा हाल
  Widget _header(List<Color> sky) {
    final c = _data?.current;
    final w = wmoInfo(context, c?.weatherCode);

    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: sky,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(26)),
          boxShadow: [
            BoxShadow(
              color: sky.first.withValues(alpha: 0.30),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ],
        ),
        padding: EdgeInsets.fromLTRB(
            14, MediaQuery.of(context).padding.top + 6, 14, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(_t('moreWeather'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 6)
                          ])),
                ),
                if (_refreshing)
                  Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1),
                    ),
                    child: const CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                else
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
                      onPressed: () => _refresh(),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 14),

            // ── कई जगहें — High-Contrast Glassmorphic styling ──
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (int i = 0; i < _places.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => _switchPlace(i),
                        onLongPress: () => _confirmRemove(_places[i]),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: i == _selected
                                ? Colors.white
                                : Colors.black.withValues(alpha: 0.30),
                            borderRadius: BorderRadius.circular(20),
                            border: i == _selected
                                ? Border.all(color: Colors.white, width: 1.5)
                                : Border.all(color: Colors.white.withValues(alpha: 0.50), width: 1.2),
                            boxShadow: i == _selected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.20),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_places[i].isCurrent) ...[
                                Icon(Icons.my_location_rounded,
                                    size: 15,
                                    color: i == _selected
                                        ? const Color(0xFF0F766E)
                                        : Colors.white),
                                const SizedBox(width: 5),
                              ],
                              Text(
                                _places[i].name,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: i == _selected ? FontWeight.w800 : FontWeight.w700,
                                  color: i == _selected
                                      ? const Color(0xFF0F172A)
                                      : Colors.white,
                                  shadows: i == _selected
                                      ? null
                                      : const [
                                          Shadow(color: Colors.black87, blurRadius: 4)
                                        ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // ── GPS बटन ──
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: _useGpsNow,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.30),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.50), width: 1.2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.my_location_rounded, size: 15, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(
                              _t('wUseGps'),
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                shadows: [
                                  Shadow(color: Colors.black87, blurRadius: 4)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── स्थान जोड़ें बटन ──
                  if (_places.length < WeatherService.maxPlaces)
                    GestureDetector(
                      onTap: _addPlaceFlow,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.30),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.50), width: 1.2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add, size: 16, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              _t('wAddPlace'),
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                shadows: [
                                  Shadow(color: Colors.black87, blurRadius: 4)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (c != null) ...[
              Row(
                children: [
                  Text(w['emoji']!, style: const TextStyle(fontSize: 60)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${c.temp.round()}°',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 52,
                                fontWeight: FontWeight.w300,
                                height: 1)),
                        Text(w['desc']!,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
                        if (c.feelsLike != null)
                          Text('${_t('wFeels')} ${c.feelsLike!.round()}°',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _headChip('💧', '${c.humidity ?? '-'}%', _t('wHumidity')),
                  const SizedBox(width: 8),
                  _headChip('💨', '${c.windSpeed.round()}', _t('wKmh')),
                  const SizedBox(width: 8),
                  _headChip('☀️', c.uvIndex?.toStringAsFixed(0) ?? '-', 'UV'),
                ],
              ),
            ],

            const SizedBox(height: 12),
            Text(
              '${fullDate(DateTime.now(), _lang)}'
              '${_cacheAgeMin != null ? '  ·  ${agoLabel(_cacheAgeMin!, _lang)}' : ''}',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88), fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headChip(String emoji, String value, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
          ),
          child: Column(
            children: [
              Text('$emoji $value',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 11)),
            ],
          ),
        ),
      );

  // ── 10 दिन ──
  Widget _daysSection(WeatherData d) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_t('wForecast10'),
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            const SizedBox(height: 3),
            Text(_t('wTapForDetail'),
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: d.daily.length,
                itemBuilder: (_, i) => _dayCard(d.daily[i], i),
              ),
            ),
          ],
        ),
      );

  Widget _dayCard(DailyForecast day, int i) {
    final sel = i == _selectedDay;
    final w = wmoInfo(context, day.weatherCode);

    return GestureDetector(
      onTap: () => setState(() => _selectedDay = i),
      onLongPress: () => WeatherDetailSheet.show(context,
          day: day, placeName: _place?.name ?? ''),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 92,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: sel ? null : Colors.white,
          gradient: sel
              ? const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)
              : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: sel ? Colors.transparent : Colors.teal.withValues(alpha: 0.14)),
          boxShadow: sel
              ? [
                  BoxShadow(
                      color: const Color(0xFF0F766E).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]
              : [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(day.isToday ? _t('wToday') : weekdayShort(day.date, _lang),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: sel ? Colors.white : const Color(0xFF0F172A))),
            Text(dayMonthShort(day.date, _lang),
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: sel ? Colors.white70 : const Color(0xFF64748B))),
            Text(w['emoji']!, style: const TextStyle(fontSize: 26)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${day.maxTemp.round()}°',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: sel ? Colors.white : const Color(0xFFD97706))),
                Text(' / ',
                    style: TextStyle(
                        fontSize: 12,
                        color: sel ? Colors.white70 : Colors.grey.shade400)),
                Text('${day.minTemp.round()}°',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white70 : const Color(0xFF475569))),
              ],
            ),
            if ((day.rainChance ?? 0) > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: sel
                      ? Colors.white.withValues(alpha: 0.22)
                      : const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('💧 ${day.rainChance!.round()}%',
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: sel ? Colors.white : const Color(0xFF0284C7))),
              )
            else
              const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── घंटेवार ──
  Widget _hourlySection(WeatherData d) {
    if (_selectedDay >= d.daily.length) return const SizedBox.shrink();
    final day = d.daily[_selectedDay];
    final hours = day.hourly;
    if (hours.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_t('weatherHourlyForecast')} — '
                  '${day.isToday ? _t('wToday') : dayMonthShort(day.date, _lang)}',
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
              ),
              TextButton.icon(
                onPressed: () => WeatherDetailSheet.show(context,
                    day: day, placeName: _place?.name ?? ''),
                icon: const Icon(Icons.info_outline_rounded, size: 18),
                label: Text(_t('wFullDetail')),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 118,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hours.length,
              itemBuilder: (_, i) {
                final h = hours[i];
                final w = wmoInfo(context, h.weatherCode);
                return GestureDetector(
                  onTap: () => WeatherDetailSheet.show(context,
                      day: day, hour: h, placeName: _place?.name ?? ''),
                  child: Container(
                    width: 76,
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.teal.withValues(alpha: 0.12)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(hourLabel(h.time, _lang),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569))),
                        Text(w['emoji']!, style: const TextStyle(fontSize: 22)),
                        Text('${h.temp.round()}°',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                        if (h.rainChance > 0)
                          Text('💧${h.rainChance.round()}%',
                              style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0284C7)))
                        else
                          const SizedBox(height: 13),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorView() => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded,
                  size: 62, color: Colors.grey.shade400),
              const SizedBox(height: 14),
              Text(_error ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () => _refresh(),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(_t('tryAgain')),
              ),
            ],
          ),
        ),
      );

  Future<void> _confirmRemove(WeatherPlace p) async {
    if (p.isCurrent) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(_t('wRemovePlace')),
        content: Text(p.name),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(_t('cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(_t('pashuDelete'),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true) await _removePlace(p);
  }
}

/// पहली बार खुलने पर — ख़ाली स्क्रीन की जगह ढाँचा
class _WeatherSkeleton extends StatelessWidget {
  const _WeatherSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar(double w, double h) => Container(
          width: w,
          height: h,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
        );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bar(150, 20),
          bar(double.infinity, 128),
          const SizedBox(height: 14),
          bar(130, 20),
          bar(double.infinity, 110),
        ],
      ),
    );
  }
}

/// शहर खोजकर जोड़ने की परत — तीन source एक साथ:
///
///  1. **Offline भारतीय सूची** (`kIndiaCities`, 200+ शहर) — तुरंत, बिना internet
///  2. **Open-Meteo geocoding** — दुनिया भर के छोटे-बड़े स्थान
///  3. **हाल में देखी जगहें** — जब text खाली हो, तो पहले जिन्हें खोजा उनकी सूची
///
/// पहले सिर्फ़ Open-Meteo था — internet न हो तो कुछ नहीं मिलता था, और छोटे
/// भारतीय गाँव इसमें अक्सर नहीं होते।
class _CitySearchSheet extends StatefulWidget {
  const _CitySearchSheet();

  @override
  State<_CitySearchSheet> createState() => _CitySearchSheetState();
}

class _CitySearchSheetState extends State<_CitySearchSheet> {
  final _ctrl = TextEditingController();
  final _svc = WeatherService.instance;
  Timer? _debounce;

  /// Offline (`kIndiaCities`) से मिले तुरंत सुझाव
  List<IndiaCity> _local = [];
  /// Open-Meteo से आए online सुझाव (देर से आते हैं)
  List<WeatherPlace> _online = [];
  /// हाल में खोजी गई जगहें (SharedPreferences में)
  List<WeatherPlace> _recent = [];
  bool _onlineBusy = false;

  String _t(String k) => AppLocalizations.get(context, k);
  bool get _isHi => AppLocalizations.isHindiLike(context);

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final r = await _svc.getRecentSearches();
    if (mounted) setState(() => _recent = r);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String q) {
    // Layer 1 — local: तुरंत, कोई देर नहीं
    setState(() {
      _local = q.trim().length >= 1 ? searchIndiaCities(q, limit: 10) : const [];
      _online = const [];
    });

    // Layer 2 — online (Open-Meteo): 400ms debounce, दो अक्षर से शुरू
    _debounce?.cancel();
    if (q.trim().length < 2) return;
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (mounted) setState(() => _onlineBusy = true);
      final r = await _svc.searchCity(q);
      if (mounted) {
        setState(() {
          _online = r;
          _onlineBusy = false;
        });
      }
    });
  }

  Future<void> _pickLocal(IndiaCity c) async {
    final p = WeatherPlace(
      name: c.name(_isHi),
      subtitle: c.stateName(_isHi),
      lat: c.lat,
      lon: c.lon,
    );
    await _svc.addRecentSearch(p);
    if (!mounted) return;
    Navigator.pop(context, p);
  }

  Future<void> _pickOnline(WeatherPlace p) async {
    await _svc.addRecentSearch(p);
    if (!mounted) return;
    Navigator.pop(context, p);
  }

  @override
  Widget build(BuildContext context) {
    final query = _ctrl.text.trim();
    final showRecent = query.isEmpty && _recent.isNotEmpty;
    final noResults = query.isNotEmpty &&
        _local.isEmpty &&
        _online.isEmpty &&
        !_onlineBusy;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _ctrl,
              autofocus: true,
              onChanged: _onChanged,
              decoration: InputDecoration(
                hintText: _t('wSearchHint'),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: DairyTheme.primaryTeal),
                suffixIcon: _onlineBusy
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: DairyTheme.primaryTeal)),
                      )
                    : (_ctrl.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              _ctrl.clear();
                              _onChanged('');
                            })),
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── हाल में देखी जगहें (सिर्फ़ खाली query पर) ──
                    if (showRecent) ...[
                      _sectionHead(_t('wSearchRecent'), Icons.history_rounded),
                      for (final p in _recent)
                        _tile(
                          icon: Icons.history_rounded,
                          iconColor: Colors.grey,
                          title: p.name,
                          subtitle: p.subtitle,
                          badge: null,
                          onTap: () => _pickOnline(p),
                        ),
                      const SizedBox(height: 4),
                    ],

                    // ── Layer 1: Offline भारतीय सूची ──
                    if (_local.isNotEmpty) ...[
                      _sectionHead(_t('wSearchOffline'),
                          Icons.download_done_rounded),
                      for (final c in _local)
                        _tile(
                          icon: Icons.location_city_rounded,
                          iconColor: DairyTheme.primaryTeal,
                          title: c.name(_isHi),
                          subtitle: c.stateName(_isHi),
                          badge: _t('wSearchOfflineBadge'),
                          badgeColor: DairyTheme.primaryTeal,
                          onTap: () => _pickLocal(c),
                        ),
                      const SizedBox(height: 4),
                    ],

                    // ── Layer 2: Online (Open-Meteo, दुनिया-भर) ──
                    if (_online.isNotEmpty) ...[
                      _sectionHead(_t('wSearchOnline'), Icons.public_rounded),
                      for (final p in _online)
                        _tile(
                          icon: Icons.public_rounded,
                          iconColor: Colors.blueGrey,
                          title: p.name,
                          subtitle: p.subtitle,
                          badge: _t('wSearchOnlineBadge'),
                          badgeColor: Colors.blueGrey,
                          onTap: () => _pickOnline(p),
                        ),
                    ],

                    // ── कुछ नहीं मिला ──
                    if (noResults)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.search_off_rounded,
                                  size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 10),
                              Text(_t('wSearchNoResult'),
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                      ),

                    // ── खाली + कोई recent नहीं: hint ──
                    if (query.isEmpty && _recent.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.location_searching_rounded,
                                  size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 10),
                              Text(_t('wSearchStartHint'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade600,
                                      height: 1.35)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHead(String title, IconData icon) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: Colors.grey.shade700)),
          ],
        ),
      );

  Widget _tile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String? badge,
    Color? badgeColor,
    required VoidCallback onTap,
  }) =>
      InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    if (subtitle.isNotEmpty)
                      Text(subtitle,
                          style: TextStyle(
                              fontSize: 12.5, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? Colors.grey).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(badge,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: badgeColor ?? Colors.grey.shade700)),
                ),
            ],
          ),
        ),
      );
}
