import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../data/app_language.dart';
import '../data/app_links.dart';
import '../data/land_units.dart';
import '../data/map_strings.dart';
import '../data/saved_measurements.dart';
import '../data/tool_strings.dart';
import '../geo/geo_math.dart';
import '../geo/measure_session.dart';
import '../services/ad_service.dart';
import '../services/location_service.dart';
import '../widgets/map_result_sheet.dart';
import 'batwara_screen.dart';
import 'irregular_plot_screen.dart';

const _green = Color(0xFF2E7D32);
const _darkGreen = Color(0xFF1B5E20);

/// 📍 नक्शे पर नापना — तीनों तरीक़े एक ही screen में।
///
/// * [MeasureMethod.tap] — नक्शे पर उंगली से, रकबा या दूरी। GPS ज़रूरी नहीं;
///   "मेरी जगह" दबाने पर ही लोकेशन पूछी जाती है।
/// * [MeasureMethod.walkCorners] — हर कोने पर 5 सेकंड की readings का औसत।
///   Pro Kisan हर 1-2 मी पर अपने आप बिंदु जोड़ता था, जिससे GPS की हलचल से
///   खेत टेढ़ा-मेढ़ा बनता था। यहाँ वो "लगातार" वाले विकल्प में है।
/// * [MeasureMethod.track] — चलते/गाड़ी से, GPS रेखा अपने आप। [TrackFilter]
///   छलांग और खड़े-खड़े की हलचल छानता है।
///
/// नक्शे की tiles: सैटेलाइट Esri World Imagery, सादा OpenStreetMap — दोनों
/// बिना API key। दोनों की शर्तें attribution माँगती हैं (नीचे कोने में), और
/// OSM की tile policy भारी इस्तेमाल पर रोक लगा सकती है — इसलिए default
/// सैटेलाइट है और कोई tile पहले से download (bulk) नहीं की जाती।
class MapMeasureScreen extends StatefulWidget {
  const MapMeasureScreen({
    super.key,
    required this.method,
    this.kind = MeasureKind.area,
    this.saved,
  });

  final MeasureMethod method;
  final MeasureKind kind;

  /// सहेजा हुआ नाप खोलना हो — तब screen tap वाली रहती है ताकि बिंदु सुधारे जा सकें
  final SavedMeasurement? saved;

  @override
  State<MapMeasureScreen> createState() => _MapMeasureScreenState();
}

class _MapMeasureScreenState extends State<MapMeasureScreen>
    with WidgetsBindingObserver {
  final MapController _map = MapController();
  late MeasureMethod _method = widget.method;
  late MeasureSession _session =
      widget.saved?.session ?? MeasureSession(widget.kind);

  bool _satellite = true;
  bool _mapReady = false;
  DateTime? _lastTileError;

  // ── GPS ──
  LocationAccess? _access;
  bool _askingLocation = false;
  StreamSubscription<GpsFix>? _fixSub;
  GpsFix? _fix;
  bool _followMe = true;
  bool _centeredOnce = false;

  // ── कोने ──
  List<GpsFix>? _cornerSamples;
  Timer? _cornerTimer;
  int _cornerSecondsLeft = 0;

  /// हर बिंदु की अनुमानित सटीकता (मी) — [_session] के बिंदुओं के क्रम में।
  /// Tap वाले बिंदुओं के लिए null।
  final List<double?> _pointAccuracy = [];
  bool _lastCornerWeak = false;

  // ── Track ──
  bool _recording = false;
  bool _vehicle = false;
  TrackFilter _filter = TrackFilter.walking();

  // ── नतीजा ──
  String _state = standardStateKey;

  /// आख़िरी बार सहेजने के बाद कुछ बदला?
  bool _dirty = false;

  int? _draggingIndex;

  bool get _usesGps => _method != MeasureMethod.tap;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    for (var i = 0; i < _session.pointCount; i++) {
      _pointAccuracy.add(null);
    }
    _loadState();
    if (_usesGps) {
      // user ने ख़ुद GPS वाला तरीक़ा चुना है — screen खुलते ही पूछना ठीक है
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _ensureLocation(prompt: true));
      WakelockPlus.enable();
    } else {
      // Tap में पूछेंगे नहीं; पहले से अनुमति हो तो चुपचाप अपनी जगह दिखा दें
      _ensureLocation(prompt: false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fixSub?.cancel();
    _cornerTimer?.cancel();
    WakelockPlus.disable();
    _map.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Settings से लौटने पर दोबारा देखें — शायद user ने GPS/अनुमति चालू कर दी
    if (state == AppLifecycleState.resumed &&
        _access != null &&
        _access != LocationAccess.granted) {
      _ensureLocation(prompt: false);
    }
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('converter_last_state');
      if (saved == null || !mounted) return;
      if (saved != standardStateKey && !stateUnits.containsKey(saved)) return;
      setState(() => _state = saved);
    } catch (_) {}
  }

  // ─────────────────────────── लोकेशन ───────────────────────────

  Future<void> _ensureLocation({required bool prompt}) async {
    if (_askingLocation) return;
    _askingLocation = true;
    try {
      final svc = LocationService.instance;
      var access = await svc.check();
      if (access == LocationAccess.denied && prompt && mounted) {
        final ok = await _showDisclosure();
        if (ok) access = await svc.request();
      }
      if (!mounted) return;
      if (!_usesGps && access != LocationAccess.granted) {
        // Tap में पूरा पर्दा नहीं — नापना बिना GPS भी चलता है। user ने ख़ुद
        // "मेरी जगह" दबाया था तो बस छोटा संदेश।
        if (prompt) {
          final strings = AppStrings(LanguageNotifier.instance.value);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(access == LocationAccess.serviceOff
                ? strings.mapGpsOff
                : strings.mapPermissionDenied),
            action: SnackBarAction(
              label: access == LocationAccess.serviceOff
                  ? strings.mapTurnOnGps
                  : strings.mapOpenSettings,
              onPressed: access == LocationAccess.serviceOff
                  ? LocationService.instance.openLocationSettings
                  : LocationService.instance.openAppSettings,
            ),
          ));
        }
        return;
      }
      setState(() => _access = access);
      if (access == LocationAccess.granted) _startFixes();
    } catch (_) {
      // कुछ फ़ोनों पर GPS service ही नहीं होती — tap वाला नापना फिर भी चले
      if (mounted && _usesGps) {
        setState(() => _access = LocationAccess.serviceOff);
      }
    } finally {
      _askingLocation = false;
    }
  }

  Future<bool> _showDisclosure() async {
    final strings = AppStrings(LanguageNotifier.instance.value);
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.my_location_rounded, color: _green, size: 36),
        title: Text(strings.mapDisclosureTitle),
        content: SingleChildScrollView(child: Text(strings.mapDisclosureBody)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(strings.mapNotNow),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _green),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(strings.mapDisclosureContinue),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _startFixes() {
    if (_fixSub != null) return;
    _fixSub = LocationService.instance.fixes().listen(
      _onFix,
      onError: (_) {
        if (mounted) setState(() => _fix = null);
      },
    );
  }

  void _onFix(GpsFix fix) {
    if (!mounted) return;
    setState(() {
      _fix = fix;
      _cornerSamples?.add(fix);
      if (_recording && _filter.accept(fix)) {
        _session.add(fix.position);
        _pointAccuracy.add(fix.accuracyMeters);
        _dirty = true;
      }
    });
    if (!_mapReady) return;
    if (!_centeredOnce) {
      _centeredOnce = true;
      // सहेजा नाप खुला हो तो उसी पर रहें
      if (_session.isEmpty) _map.move(fix.position, 18);
    } else if (_followMe && _usesGps) {
      _map.move(fix.position, _map.camera.zoom);
    }
  }

  void _goToMyLocation() {
    if (_access != LocationAccess.granted) {
      _ensureLocation(prompt: true);
      return;
    }
    final fix = _fix;
    if (fix == null) return;
    setState(() => _followMe = true);
    _map.move(fix.position, _map.camera.zoom < 16 ? 18 : _map.camera.zoom);
  }

  // ─────────────────────────── बिंदु ───────────────────────────

  void _onMapTap(TapPosition _, LatLng point) {
    if (_method != MeasureMethod.tap) return;
    HapticFeedback.selectionClick();
    setState(() {
      _session.add(point);
      _pointAccuracy.add(null);
      _dirty = true;
    });
  }

  void _startCorner() {
    if (_cornerTimer != null) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _cornerSamples = [];
      _cornerSecondsLeft = 5;
    });
    _cornerTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _cornerSecondsLeft--);
      if (_cornerSecondsLeft <= 0) _finishCorner();
    });
  }

  void _finishCorner() {
    _cornerTimer?.cancel();
    _cornerTimer = null;
    final samples = _cornerSamples ?? const <GpsFix>[];
    _cornerSamples = null;

    final usable = samples.isNotEmpty
        ? samples
        : [
            // 5 सेकंड में नई reading न आई (फ़ोन सिर्फ़ हिलने पर भेजता है) —
            // ताज़ा आख़िरी reading से काम चलाएँ
            if (_fix != null &&
                DateTime.now().difference(_fix!.time).inSeconds < 15)
              _fix!,
          ];
    if (usable.isEmpty) {
      setState(() {});
      final strings = AppStrings(LanguageNotifier.instance.value);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(strings.mapGpsSearching)));
      return;
    }
    final est = averageFixes(usable);
    HapticFeedback.heavyImpact();
    setState(() {
      _session.add(est.position);
      _pointAccuracy.add(est.accuracyMeters);
      _lastCornerWeak = est.isWeak;
      _dirty = true;
    });
  }

  void _toggleRecording() {
    setState(() {
      if (_recording) {
        _recording = false;
      } else {
        // रुकने के बाद का पहला बिंदु "छलांग" मानकर न छूटे; दूरी में
        // रुकने से पहले/बाद के बिंदु सीधी रेखा से न जुड़ें
        _filter.reset();
        _session.startNewSegment();
        _recording = true;
        _followMe = true;
      }
    });
  }

  void _setVehicle(bool vehicle) {
    setState(() {
      _vehicle = vehicle;
      _filter = vehicle ? TrackFilter.vehicle() : TrackFilter.walking();
    });
  }

  void _undo() {
    setState(() {
      _session.undo();
      while (_pointAccuracy.length > _session.pointCount) {
        _pointAccuracy.removeLast();
      }
      _lastCornerWeak = false;
      _dirty = !_session.isEmpty;
      // track में आख़िरी बिंदु हटने के बाद अगला बिंदु उससे जुड़े, हटे हुए से नहीं
      _filter.reset();
    });
  }

  void _clear() {
    setState(() {
      _session.clear();
      _pointAccuracy.clear();
      _recording = false;
      _lastCornerWeak = false;
      _dirty = false;
      _filter.reset();
    });
  }

  void _setKind(MeasureKind kind) {
    if (kind == _session.kind) return;
    final next = MeasureSession(kind);
    for (final p in _session.points) {
      next.add(p);
    }
    setState(() => _session = next);
  }

  /// "कोने" ↔ "लगातार" — बीच नाप में बदलने से दोनों तरह के बिंदु मिल जाते,
  /// इसलिए सिर्फ़ ख़ाली नाप पर।
  void _setWalkMethod(MeasureMethod m) {
    if (m == _method || !_session.isEmpty) return;
    setState(() {
      _method = m;
      _recording = false;
    });
  }

  void _dragPoint(int index, DragUpdateDetails d) {
    final cam = _map.camera;
    final pt = _session.points[index];
    final moved =
        cam.screenOffsetToLatLng(cam.latLngToScreenOffset(pt) + d.delta);
    setState(() {
      _session.move(index, moved);
      _dirty = true;
    });
  }

  // ─────────────────────────── सहेजना / share ───────────────────────────

  Future<void> _save(AppStrings strings) async {
    final ctrl = TextEditingController(text: widget.saved?.name ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.mapSaveName),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 40,
          decoration: InputDecoration(
            hintText: strings.mapSaveHint,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(strings.mapCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _green),
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(strings.mapSave),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (name == null || name.isEmpty || !mounted) return;
    // सहेजने के बाद भी user बिंदु बदल सकता है — इसलिए copy सहेजें
    final copy = MeasureSession.fromJson(_session.toJson())!;
    await SavedMeasurementStore.instance.save(
      name,
      copy,
      replaceId: widget.saved?.id,
    );
    if (!mounted) return;
    setState(() => _dirty = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(strings.mapSavedOk)));
  }

  String _shareText(AppStrings strings) {
    final b = StringBuffer()..writeln(strings.mapShareTitle);
    if (_session.hasArea) {
      final sqft = _session.areaSqFt;
      final main = primaryUnitFor(_state, sqft);
      b.writeln('${strings.mapKindArea}: ${formatMeasured(sqft / main.sqft)} '
          '${main.label}');
      if (main.en != 'Acre') {
        b.writeln('= ${formatMeasured(sqft / 43560)} ${_acreLabel()}');
      }
      b.writeln('= ${formatMeasured(sqft)} ${strings.sqFt}');
      b.writeln(
          '${strings.mapPerimeter}: ${formatDistance(strings, _session.lengthMeters)}');
      b.writeln('${strings.stateLabel}: ${strings.stateDisplayName(_state)}');
    } else {
      b.writeln(
          '${strings.mapKindDistance}: ${formatDistance(strings, _session.lengthMeters)}');
    }
    final pts = _session.points;
    if (pts.isNotEmpty) {
      final c = LocalProjection.around(pts);
      b.writeln('${strings.mapShareMapLink}: '
          'https://maps.google.com/?q=${c.lat0.toStringAsFixed(6)},${c.lon0.toStringAsFixed(6)}');
    }
    b
      ..writeln('--------------------------------')
      ..writeln(strings.sharedFromApp)
      ..writeln('${strings.downloadCta}: $shareReportLink');
    return b.toString();
  }

  Future<bool> _confirmLeave(AppStrings strings) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.mapLeaveTitle),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(strings.mapLeave)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _green),
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(strings.mapCancel),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  // ─────────────────────────── UI ───────────────────────────

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLang>(
      valueListenable: LanguageNotifier.instance,
      builder: (context, lang, _) {
        final strings = AppStrings(lang);
        return PopScope(
          canPop: !_dirty,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) {
              AdService.instance.showInterstitialWithCounter(() {});
              return;
            }
            final navigator = Navigator.of(context);
            if (await _confirmLeave(strings) && mounted) {
              setState(() => _dirty = false);
              navigator.pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(_title(strings)),
              actions: [
                IconButton(
                  tooltip: _satellite ? strings.mapPlain : strings.mapSatellite,
                  icon: Icon(_satellite
                      ? Icons.map_outlined
                      : Icons.satellite_alt_rounded),
                  onPressed: () => setState(() {
                    _satellite = !_satellite;
                    _lastTileError = null;
                  }),
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(child: _buildMap(strings)),
                _buildPanel(strings),
              ],
            ),
          ),
        );
      },
    );
  }

  String _title(AppStrings s) => switch (_method) {
        MeasureMethod.tap => s.mapTapTitle,
        MeasureMethod.walkCorners => s.mapWalkTitle,
        MeasureMethod.track =>
          _session.kind == MeasureKind.area ? s.mapWalkTitle : s.mapRoadTitle,
      };

  Widget _buildMap(AppStrings strings) {
    final pts = _session.points;
    final fix = _fix;
    final showNumbered =
        _method != MeasureMethod.track && pts.length <= 60;
    final initialFit = pts.length >= 2
        ? CameraFit.coordinates(
            coordinates: pts,
            padding: const EdgeInsets.all(48),
            maxZoom: 19,
          )
        : null;

    return Stack(
      children: [
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            initialCenter: pts.isNotEmpty ? pts.first : const LatLng(23.0, 80.0),
            initialZoom: pts.isNotEmpty ? 18 : 5,
            initialCameraFit: initialFit,
            minZoom: 3,
            maxZoom: 20,
            onMapReady: () => _mapReady = true,
            onTap: _onMapTap,
            onPointerDown: (_, __) {
              if (_followMe) setState(() => _followMe = false);
            },
            interactionOptions: InteractionOptions(
              // बिंदु खींचते समय नक्शा न सरके; घुमाना बंद — उत्तर हमेशा ऊपर
              flags: _draggingIndex != null
                  ? InteractiveFlag.none
                  : InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              key: ValueKey(_satellite),
              urlTemplate: _satellite
                  ? 'https://server.arcgisonline.com/ArcGIS/rest/services/'
                      'World_Imagery/MapServer/tile/{z}/{y}/{x}'
                  : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.chandansingh.kisan_calculator',
              // गाँवों में Esri की z19 tiles अक्सर नहीं होतीं — 18 को बड़ा करके दिखाएँ
              maxNativeZoom: _satellite ? 18 : 19,
              errorTileCallback: (_, __, ___) {
                final now = DateTime.now();
                final last = _lastTileError;
                // हर टूटी tile पर rebuild न हो
                if (last == null || now.difference(last).inSeconds > 3) {
                  if (mounted) setState(() => _lastTileError = now);
                }
              },
            ),
            if (_session.kind == MeasureKind.area && pts.length >= 3)
              PolygonLayer(polygons: [
                Polygon(
                  points: pts,
                  color: (_session.crossesItself ? Colors.red : Colors.yellow)
                      .withValues(alpha: 0.25),
                  borderColor:
                      _session.crossesItself ? Colors.red : Colors.yellowAccent,
                  borderStrokeWidth: 3,
                ),
              ]),
            if (_session.kind == MeasureKind.area && pts.length == 2)
              PolylineLayer(polylines: [
                Polyline(
                    points: pts, color: Colors.yellowAccent, strokeWidth: 3),
              ]),
            if (_session.kind == MeasureKind.distance)
              PolylineLayer(polylines: [
                for (final seg in _session.segments)
                  if (seg.length >= 2)
                    Polyline(
                      points: seg,
                      color: Colors.lightBlueAccent,
                      strokeWidth: 5,
                      borderColor: Colors.black54,
                      borderStrokeWidth: 1.5,
                    ),
              ]),
            if (fix != null)
              CircleLayer(circles: [
                CircleMarker(
                  point: fix.position,
                  radius: fix.accuracyMeters,
                  useRadiusInMeter: true,
                  color: Colors.blue.withValues(alpha: 0.15),
                  borderColor: Colors.blue.withValues(alpha: 0.5),
                  borderStrokeWidth: 1,
                ),
              ]),
            MarkerLayer(markers: [
              if (showNumbered)
                for (var i = 0; i < pts.length; i++)
                  Marker(
                    point: pts[i],
                    width: 44,
                    height: 44,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (_) => setState(() => _draggingIndex = i),
                      onPanUpdate: (d) => _dragPoint(i, d),
                      onPanEnd: (_) => setState(() => _draggingIndex = null),
                      onPanCancel: () => setState(() => _draggingIndex = null),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          width: _draggingIndex == i ? 34 : 26,
                          height: _draggingIndex == i ? 34 : 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: _green, width: 2.5),
                            boxShadow: const [
                              BoxShadow(color: Colors.black38, blurRadius: 4)
                            ],
                          ),
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: _darkGreen),
                          ),
                        ),
                      ),
                    ),
                  )
              else if (pts.isNotEmpty) ...[
                _endMarker(pts.first, Colors.green),
                if (pts.length > 1) _endMarker(pts.last, Colors.red),
              ],
              if (fix != null)
                Marker(
                  point: fix.position,
                  width: 22,
                  height: 22,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [
                        BoxShadow(color: Colors.black38, blurRadius: 5)
                      ],
                    ),
                  ),
                ),
            ]),
            SimpleAttributionWidget(
              backgroundColor: Colors.white70,
              source: Text(
                _satellite
                    ? 'Powered by Esri · Esri, Maxar, Earthstar Geographics'
                    : '© OpenStreetMap contributors',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),

        // ऊपर: रकबा/दूरी या कोने/लगातार या पैदल/गाड़ी
        Positioned(
          top: 8,
          left: 8,
          right: 8,
          child: Column(
            children: [
              _topSwitch(strings),
              if (_usesGps) ...[
                const SizedBox(height: 6),
                _gpsChip(strings),
              ],
              if (_lastTileError != null &&
                  DateTime.now().difference(_lastTileError!).inSeconds < 20) ...[
                const SizedBox(height: 6),
                _mapNote(strings.mapTilesFailing, Icons.cloud_off_rounded),
              ],
            ],
          ),
        ),

        Positioned(
          right: 10,
          bottom: 28,
          child: FloatingActionButton.small(
            heroTag: 'map_measure_locate',
            tooltip: strings.mapMyLocation,
            backgroundColor: Colors.white,
            foregroundColor: _followMe && _fix != null ? Colors.blue : Colors.black54,
            onPressed: _goToMyLocation,
            child: Icon(_fix == null
                ? Icons.location_searching_rounded
                : Icons.my_location_rounded),
          ),
        ),

        if (_usesGps &&
            _access != null &&
            _access != LocationAccess.granted)
          Positioned.fill(child: _locationBlocked(strings)),
      ],
    );
  }

  Marker _endMarker(LatLng p, Color color) => Marker(
        point: p,
        width: 18,
        height: 18,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
        ),
      );

  Widget _topSwitch(AppStrings strings) {
    Widget seg<T>(T value, Set<T> selected, List<(T, String, IconData)> items,
            void Function(T) onChanged,
            {bool enabled = true}) =>
        Material(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(24),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: SegmentedButton<T>(
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: _green,
                selectedForegroundColor: Colors.white,
                visualDensity: VisualDensity.compact,
              ),
              segments: [
                for (final it in items)
                  ButtonSegment(
                    value: it.$1,
                    label: Text(it.$2),
                    icon: Icon(it.$3, size: 18),
                    enabled: enabled || selected.contains(it.$1),
                  ),
              ],
              selected: selected,
              onSelectionChanged: (s) => onChanged(s.first),
            ),
          ),
        );

    switch (_method) {
      case MeasureMethod.tap:
        return seg(
          _session.kind,
          {_session.kind},
          [
            (MeasureKind.area, strings.mapKindArea, Icons.crop_square_rounded),
            (MeasureKind.distance, strings.mapKindDistance,
                Icons.timeline_rounded),
          ],
          _setKind,
        );
      case MeasureMethod.walkCorners || MeasureMethod.track
          when _session.kind == MeasureKind.area:
        return seg(
          _method,
          {_method},
          [
            (MeasureMethod.walkCorners, strings.mapCornersMode,
                Icons.place_rounded),
            (MeasureMethod.track, strings.mapContinuousMode,
                Icons.route_rounded),
          ],
          _setWalkMethod,
          enabled: _session.isEmpty,
        );
      case _:
        return seg(
          _vehicle,
          {_vehicle},
          [
            (false, strings.mapOnFoot, Icons.directions_walk_rounded),
            (true, strings.mapByVehicle, Icons.two_wheeler_rounded),
          ],
          _setVehicle,
        );
    }
  }

  Widget _gpsChip(AppStrings strings) {
    final fix = _fix;
    final (Color color, String text) = fix == null
        ? (Colors.grey.shade700, strings.mapGpsSearching)
        : fix.accuracyMeters <= 10
            ? (Colors.green.shade700,
                strings.mapGpsAccuracy(fix.accuracyMeters.round()))
            : fix.accuracyMeters <= 20
                ? (Colors.orange.shade800,
                    strings.mapGpsAccuracy(fix.accuracyMeters.round()))
                : (Colors.red.shade700, strings.mapGpsWeak);
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.gps_fixed_rounded, color: Colors.white, size: 14),
              const SizedBox(width: 5),
              Flexible(
                child: Text(text,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mapNote(String text, IconData icon) => Material(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(text,
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
        ),
      );

  Widget _locationBlocked(AppStrings strings) {
    final off = _access == LocationAccess.serviceOff;
    final forever = _access == LocationAccess.deniedForever;
    return ColoredBox(
      color: Colors.white.withValues(alpha: 0.94),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(off ? Icons.location_off_rounded : Icons.lock_outline_rounded,
                  size: 56, color: Colors.orange.shade800),
              const SizedBox(height: 12),
              Text(
                off ? strings.mapGpsOff : strings.mapPermissionDenied,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: _green),
                icon: Icon(off || forever
                    ? Icons.settings_rounded
                    : Icons.refresh_rounded),
                label: Text(off
                    ? strings.mapTurnOnGps
                    : forever
                        ? strings.mapOpenSettings
                        : strings.mapTryAgain),
                onPressed: () {
                  if (off) {
                    LocationService.instance.openLocationSettings();
                  } else if (forever) {
                    LocationService.instance.openAppSettings();
                  } else {
                    _ensureLocation(prompt: true);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── नीचे का पैनल ──

  Widget _buildPanel(AppStrings strings) {
    final area = _session.kind == MeasureKind.area;
    final count = _session.pointCount;
    final warnings = <Widget>[];

    if (_session.crossesItself) {
      warnings.add(_warning(strings.mapCrossWarning, Colors.red.shade700));
    }
    if (_lastCornerWeak) {
      warnings.add(_warning(strings.mapWeakCorner, Colors.orange.shade800));
    }
    final uncertainty = _gpsUncertainty();
    if (uncertainty != null && uncertainty > gpsAreaWarnThreshold) {
      warnings.add(_warning(
        strings.mapSmallFieldWarning((uncertainty * 100).clamp(1, 99).round()),
        Colors.orange.shade800,
        action: TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const IrregularPlotScreen()),
          ),
          child: Text(strings.mapUseTape),
        ),
      ));
    }

    return Material(
      elevation: 12,
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _resultRow(strings),
              if (warnings.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: SingleChildScrollView(
                      child: Column(children: warnings)),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(flex: 3, child: _primaryButton(strings)),
                  const SizedBox(width: 8),
                  _iconAction(Icons.undo_rounded, strings.mapUndo,
                      count == 0 || _recording ? null : _undo),
                  _iconAction(Icons.delete_sweep_rounded, strings.clear,
                      count == 0 ? null : _clear),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: Text(strings.share),
                      style: _outlined,
                      onPressed: _hasResult
                          ? () => Share.share(_shareText(strings))
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.bookmark_add_rounded, size: 18),
                      label: Text(strings.mapSave),
                      style: _outlined,
                      onPressed: _hasResult && !_recording
                          ? () => _save(strings)
                          : null,
                    ),
                  ),
                  if (area) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.pie_chart_rounded, size: 18),
                        label: Text(strings.mapDivideShort,
                            overflow: TextOverflow.ellipsis),
                        style: _outlined,
                        onPressed: _session.hasArea
                            ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BatwaraScreen(
                                        initialSqFt: _session.areaSqFt),
                                  ),
                                )
                            : null,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _hasResult =>
      _session.hasArea ||
      (_session.kind == MeasureKind.distance && _session.lengthMeters > 0);

  static final ButtonStyle _outlined = OutlinedButton.styleFrom(
    foregroundColor: _green,
    side: const BorderSide(color: _green),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  /// GPS वाले बिंदुओं की औसत सटीकता से रकबे की अनिश्चितता। Tap वाले
  /// बिंदुओं का कोई GPS अनुमान नहीं, इसलिए उनमें null।
  double? _gpsUncertainty() {
    if (!_session.hasArea) return null;
    final accs = _pointAccuracy.whereType<double>().toList();
    if (accs.length < 3) return null;
    final mean = accs.reduce((a, b) => a + b) / accs.length;
    return gpsAreaUncertainty(
      perimeterMeters: _session.lengthMeters,
      areaSqMeters: _session.areaSqFt / sqFtPerSqMeter,
      accuracyMeters: mean,
    );
  }

  Widget _resultRow(AppStrings strings) {
    final area = _session.kind == MeasureKind.area;
    final String big;
    final String small;
    if (area && _session.hasArea) {
      final sqft = _session.areaSqFt;
      final u = primaryUnitFor(_state, sqft);
      big = '${formatMeasured(sqft / u.sqft)} ${u.label}';
      small = [
        if (u.en != 'Acre') '${formatMeasured(sqft / 43560)} ${_acreLabel()}',
        '${formatMeasured(sqft)} ${strings.sqFt}',
        '${strings.mapPerimeter}: ${formatDistance(strings, _session.lengthMeters)}',
      ].join(' • ');
    } else if (!area && _session.pointCount >= 2) {
      big = formatDistance(strings, _session.lengthMeters);
      small = strings.mapPointCount(_session.pointCount);
    } else {
      big = area ? strings.mapNeedThreePoints : strings.mapNeedTwoPoints;
      small = _hint(strings);
    }
    final hasNumber = _hasResult;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: area && _session.hasArea
          ? () => showAllUnitsSheet(
                context,
                strings: strings,
                sqft: _session.areaSqFt,
                perimeterMeters: _session.lengthMeters,
                initialState: _state,
              )
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    big,
                    style: TextStyle(
                      fontSize: hasNumber ? 22 : 15,
                      fontWeight: FontWeight.bold,
                      color: hasNumber ? _darkGreen : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(small,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            if (area && _session.hasArea)
              Tooltip(
                message: strings.mapAllUnits,
                child: const Icon(Icons.expand_less_rounded, color: _green),
              ),
          ],
        ),
      ),
    );
  }

  String _acreLabel() =>
      standardUnits.firstWhere((u) => u.en == 'Acre').label;

  String _hint(AppStrings s) => switch (_method) {
        MeasureMethod.tap => _session.kind == MeasureKind.area
            ? s.mapTapHintArea
            : s.mapTapHintDistance,
        MeasureMethod.walkCorners => s.mapWalkHint,
        MeasureMethod.track => '${s.mapTrackHint} ${s.mapScreenStaysOn}',
      };

  Widget _primaryButton(AppStrings strings) {
    final style = FilledButton.styleFrom(
      backgroundColor: _green,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
    final gpsOk = _access == LocationAccess.granted && _fix != null;

    switch (_method) {
      case MeasureMethod.tap:
        return FilledButton.icon(
          style: style,
          icon: const Icon(Icons.format_list_numbered_rounded),
          label: Text(_session.hasArea
              ? strings.mapAllUnits
              : strings.mapPointCount(_session.pointCount)),
          onPressed: _session.hasArea
              ? () => showAllUnitsSheet(
                    context,
                    strings: strings,
                    sqft: _session.areaSqFt,
                    perimeterMeters: _session.lengthMeters,
                    initialState: _state,
                  )
              : null,
        );
      case MeasureMethod.walkCorners:
        final busy = _cornerTimer != null;
        return FilledButton.icon(
          style: style,
          icon: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white))
              : const Icon(Icons.add_location_alt_rounded),
          label: Text(busy
              ? strings.mapHoldStill(_cornerSecondsLeft)
              : '${strings.mapAddCorner} (${_session.pointCount + 1})'),
          onPressed: gpsOk && !busy ? _startCorner : null,
        );
      case MeasureMethod.track:
        final label = _recording
            ? strings.mapPause
            : _session.isEmpty
                ? strings.mapStart
                : strings.mapResume;
        return FilledButton.icon(
          style: _recording
              ? style.copyWith(
                  backgroundColor:
                      WidgetStatePropertyAll(Colors.orange.shade800))
              : style,
          icon: Icon(_recording
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded),
          label: Text(label),
          onPressed: gpsOk || _recording ? _toggleRecording : null,
        );
    }
  }

  Widget _iconAction(IconData icon, String tooltip, VoidCallback? onTap) =>
      IconButton.filledTonal(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Icon(icon),
      );

  Widget _warning(String text, Color color, {Widget? action}) => Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.fromLTRB(10, 6, 4, 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: color, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(text, style: TextStyle(fontSize: 12, color: color)),
            ),
            if (action != null) action,
          ],
        ),
      );
}
