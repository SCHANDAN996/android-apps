import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../blocs/app_cubit.dart';
import '../db/dao/saved_field_dao.dart';
import '../l10n/app_localizations.dart';
import '../services/land_measurement_service.dart';
import '../services/whatsapp_service.dart';
import 'khaad/khaad_screen.dart';
import 'lw_calculator_screen.dart';
import 'theme/dairy_theme.dart';

/// 📐 खेत नापें — असली नक्शे पर।
///
/// पहले यहाँ सिर्फ़ सादे background पर रेखाएँ खिंचती थीं, किसान को अपना खेत
/// पहचानना मुश्किल था। अब satellite नक्शा है (Esri की मुफ़्त टाइल्स — कोई
/// API key नहीं, कोई बिल नहीं), उस पर अपनी जगह और खिंचती हुई सीमा दिखती है।
///
/// **v2 — 5 नए फ़ीचर्स:**
/// 1. ✋ Tap Mode — नक्शे पर टच करके पॉइंट लगाओ + drag
/// 2. 📐 L×W Calculator — लट्ठा/फ़ीट/मीटर/गज में लंबाई×चौड़ाई
/// 3. 📏 Fencing cost — तारबंदी अनुमान
/// 4. 🌾 Khaad link — नापा हुआ रकबा → KhaadScreen
/// 5. 💾 Save fields — SQLite में खेत सेव + इतिहास
class LandMeasurementScreen extends StatefulWidget {
  const LandMeasurementScreen({super.key});

  @override
  State<LandMeasurementScreen> createState() => _LandMeasurementScreenState();
}

class _LandMeasurementScreenState extends State<LandMeasurementScreen> {
  final _service = LandMeasurementService.instance;
  final _map = MapController();

  StreamSubscription<Position>? _posStream;
  Position? _pos;

  /// नक्शा अपने आप चलती जगह के पीछे-पीछे चले?
  bool _followMe = true;

  /// satellite या सादा नक्शा
  bool _satellite = true;

  /// ✋ Tap Mode — true = नक्शे पर टच करके पॉइंट, false = GPS walk
  bool _tapMode = false;

  /// तारबंदी दर (₹/फ़ीट) — default ₹150
  double _fencingRate = 150;

  String? _permError;

  String _t(String k) => AppLocalizations.get(context, k);

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _posStream?.cancel();
    _service.stopMeasurement();
    _map.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      if (mounted) setState(() => _permError = _t('landMeasureGpsOff'));
      return;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      if (mounted) setState(() => _permError = _t('landMeasureGpsOff'));
      return;
    }
    if (mounted) setState(() => _permError = null);
    _startTracking();
  }

  void _startTracking() {
    _posStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
      ),
    ).listen((p) {
      if (!mounted) return;
      final here = LatLng(p.latitude, p.longitude);
      setState(() {
        _pos = p;
        // Tap Mode में auto-add बंद — सिर्फ़ GPS Walk Mode में
        if (_service.isMeasuring && !_tapMode) _service.addPoint(here);
      });
      if (_followMe) _map.move(here, _map.camera.zoom);
    });
  }

  void _toggleMeasuring() {
    setState(() {
      if (_service.isMeasuring) {
        _service.stopMeasurement();
      } else {
        _service.startMeasurement();
        _followMe = true;
      }
    });
  }

  /// हाथ से एक बिंदु जोड़ो — जब किसान चल न सके, या GPS कमज़ोर हो
  void _addPointHere() {
    if (_pos == null) return;
    setState(() {
      if (!_service.isMeasuring) _service.startMeasurement();
      // हाथ से डालते समय दूरी की शर्त मत लगाओ
      _service.addPoint(LatLng(_pos!.latitude, _pos!.longitude),
          minGapMeters: 0);
    });
  }

  /// ✋ Tap Mode — नक्शे पर टच करके पॉइंट लगाओ
  void _onMapTap(TapPosition tapPos, LatLng latLng) {
    if (!_tapMode) return;
    setState(() {
      if (!_service.isMeasuring) _service.startMeasurement();
      _service.addPoint(latLng, minGapMeters: 0);
    });
  }

  void _undo() => setState(() => _service.removeLastPoint());

  void _reset() => setState(() => _service.reset());

  // ── 💾 Save Field ──
  Future<void> _saveField(AreaResult r) async {
    final nameCtrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_t('landSaveField')),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: _t('landFieldNameHint'),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_t('cancel')),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(ctx, nameCtrl.text.trim()),
            style: ElevatedButton.styleFrom(
                backgroundColor: DairyTheme.primaryTeal),
            child: Text(_t('landMeasureSave')),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;

    final stateCode = context.read<AppCubit>().state.stateCode;
    await SavedFieldDao().saveField(
      name: name,
      areaSqM: r.squareMeters,
      perimeterM: r.perimeterMeters,
      points: r.points,
      stateCode: stateCode,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_t('landFieldSaved')),
          backgroundColor: DairyTheme.primaryTeal,
        ),
      );
    }
  }

  // ── 📋 Saved Fields History ──
  void _showSavedFields() async {
    final fields = await SavedFieldDao().getAll();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SavedFieldsSheet(
        fields: fields,
        t: _t,
        onLoad: (field) {
          Navigator.pop(context);
          setState(() {
            _service.loadPoints(field.points);
            // zoom to field
            if (field.points.isNotEmpty) {
              _followMe = false;
              _map.move(field.points.first, 18);
            }
          });
        },
        onDelete: (id) async {
          await SavedFieldDao().deleteField(id);
          // refresh
          Navigator.pop(context);
          _showSavedFields();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pts = _service.points;
    final stateCode = context.watch<AppCubit>().state.stateCode;
    final result = _service.getAreaInAllUnits(stateCode: stateCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(_t('navLand')),
        actions: [
          // 📐 L×W Calculator बटन
          IconButton(
            tooltip: _t('landLxW'),
            icon: const Icon(Icons.straighten_rounded),
            onPressed: () => LWCalculatorSheet.show(context),
          ),
          // 📋 Saved Fields बटन
          IconButton(
            tooltip: _t('landSavedFields'),
            icon: const Icon(Icons.folder_open_rounded),
            onPressed: _showSavedFields,
          ),
          // Satellite/Plain toggle
          IconButton(
            tooltip: _satellite ? _t('mapPlain') : _t('mapSatellite'),
            icon: Icon(
                _satellite ? Icons.map_outlined : Icons.satellite_alt_rounded),
            onPressed: () => setState(() => _satellite = !_satellite),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMap(pts)),
          _buildBottomPanel(result, pts.length),
        ],
      ),
    );
  }

  // ── नक्शा ──
  Widget _buildMap(List<LatLng> pts) {
    final here = _pos == null ? null : LatLng(_pos!.latitude, _pos!.longitude);

    return Stack(
      children: [
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            // कोई जगह न मिली हो तो भारत के बीच से शुरू
            initialCenter: here ?? const LatLng(23.0, 80.0),
            initialZoom: here != null ? 18 : 5,
            maxZoom: 19,
            // ✋ Tap Mode — नक्शे पर टच करके पॉइंट
            onTap: _tapMode ? _onMapTap : null,
            // उंगली से नक्शा हिलाते ही "पीछे-पीछे चलना" बंद
            onPointerDown: (_, __) {
              if (_followMe) setState(() => _followMe = false);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: _satellite
                  // Esri World Imagery — मुफ़्त, key नहीं चाहिए
                  ? 'https://server.arcgisonline.com/ArcGIS/rest/services/'
                      'World_Imagery/MapServer/tile/{z}/{y}/{x}'
                  : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.prokisan.app',
              maxNativeZoom: 19,
            ),

            // नापी हुई सीमा — भरा हुआ हरा
            if (pts.length >= 3)
              PolygonLayer(polygons: [
                Polygon(
                  points: pts,
                  color: DairyTheme.primaryTeal.withValues(alpha: 0.30),
                  borderColor: DairyTheme.primaryTeal,
                  borderStrokeWidth: 3,
                ),
              ]),

            // 2 बिंदु हों तो सिर्फ़ रेखा
            if (pts.length == 2)
              PolylineLayer(polylines: [
                Polyline(
                    points: pts,
                    color: DairyTheme.primaryTeal,
                    strokeWidth: 3),
              ]),

            // हर बिंदु पर छोटा गोला + नंबर, और मेरी अपनी जगह
            MarkerLayer(
              markers: [
                for (int i = 0; i < pts.length; i++)
                  Marker(
                    point: pts[i],
                    width: 26,
                    height: 26,
                    child: GestureDetector(
                      onPanUpdate: _tapMode
                          ? (details) {
                              // ड्रैग करके पॉइंट सरकाओ
                              final cam = _map.camera;
                              final pixelPos = cam.latLngToScreenPoint(pts[i]);
                              final newPixel = pixelPos +
                                  math.Point<double>(details.delta.dx,
                                      details.delta.dy);
                              final newLatLng =
                                  cam.pointToLatLng(newPixel);
                              setState(
                                  () => _service.updatePoint(i, newLatLng));
                            }
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: DairyTheme.primaryTeal, width: 2.5),
                        ),
                        alignment: Alignment.center,
                        child: Text('${i + 1}',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: DairyTheme.primaryTeal)),
                      ),
                    ),
                  ),
                if (here != null)
                  Marker(
                    point: here,
                    width: 30,
                    height: 30,
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
              ],
            ),
          ],
        ),

        // GPS की हालत — ऊपर बाईं ओर
        Positioned(top: 10, left: 10, child: _gpsChip()),

        // ✋/🚶 Mode Toggle — ऊपर बीच में
        Positioned(
          top: 10,
          right: 60,
          child: _modeToggle(),
        ),

        // "मेरी जगह पर वापस" बटन
        Positioned(
          right: 10,
          bottom: 10,
          child: FloatingActionButton.small(
            heroTag: 'locateMe',
            backgroundColor: Colors.white,
            foregroundColor: _followMe ? DairyTheme.primaryTeal : Colors.grey,
            onPressed: here == null
                ? null
                : () {
                    setState(() => _followMe = true);
                    _map.move(here, 18);
                  },
            child: Icon(_followMe
                ? Icons.my_location_rounded
                : Icons.location_searching_rounded),
          ),
        ),
      ],
    );
  }

  /// ✋/🚶 Mode Toggle chip
  Widget _modeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _modeChip(
            icon: Icons.directions_walk_rounded,
            label: _t('landWalkMode'),
            selected: !_tapMode,
            onTap: () => setState(() => _tapMode = false),
          ),
          _modeChip(
            icon: Icons.touch_app_rounded,
            label: _t('landTapMode'),
            selected: _tapMode,
            onTap: () => setState(() => _tapMode = true),
          ),
        ],
      ),
    );
  }

  Widget _modeChip({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? DairyTheme.primaryTeal.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color:
                    selected ? DairyTheme.primaryTeal : Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? DairyTheme.primaryTeal
                        : Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  /// GPS चालू है या नहीं + कितनी सटीकता
  Widget _gpsChip() {
    late final Color c;
    late final String txt;

    if (_permError != null) {
      c = Colors.red;
      txt = _permError!;
    } else if (_pos == null) {
      c = Colors.orange;
      txt = _t('landMeasureGpsConnecting');
    } else {
      final acc = _pos!.accuracy;
      // 10 मी से कम = अच्छा, 25 तक ठीक, उससे ज़्यादा = कमज़ोर
      c = acc <= 10
          ? Colors.green.shade700
          : (acc <= 25 ? Colors.orange.shade800 : Colors.red.shade700);
      txt = '${_t('landMeasureGpsActive')} ±${acc.toStringAsFixed(0)} ${_t('mapMetre')}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Text(txt,
              style:
                  const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── नीचे का पैनल: नतीजा + बटन ──
  Widget _buildBottomPanel(AreaResult r, int count) {
    final measuring = _service.isMeasuring;
    final perimeterFt = r.perimeterMeters / 0.3048;
    final fencingCost = perimeterFt * _fencingRate;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 12)
        ],
      ),
      padding: EdgeInsets.fromLTRB(
          16, 14, 16, 14 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // नतीजा — बड़े आँकड़े
          if (!r.isEmpty) ...[
            Row(
              children: [
                if (r.bigha != null)
                  _stat(_t('landMeasureBigha'), r.bigha!.toStringAsFixed(2)),
                _stat(_t('landMeasureAcres'), r.acres.toStringAsFixed(3)),
                _stat(_t('landMeasureHectares'), r.hectares.toStringAsFixed(3)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${r.squareMeters.toStringAsFixed(0)} ${_t('landMeasureSquareMeters')}'
              '   ·   ${_t('mapPerimeter')} ${r.perimeterMeters.toStringAsFixed(0)} ${_t('mapMetre')}'
              ' (${perimeterFt.toStringAsFixed(0)} ${_t('landUnit_feet')})'
              '${r.bighaSqFt != null ? '\n1 ${_t('bigha')} = ${r.bighaSqFt!.toStringAsFixed(0)} ${_t('unitSqft')}' : ''}',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12.5, color: Colors.grey.shade600, height: 1.35),
            ),

            // 🪵 तारबंदी अनुमान
            const SizedBox(height: 4),
            GestureDetector(
              onTap: _editFencingRate,
              child: Text(
                '🪵 ${_t('landFencing')}: ₹${fencingCost.toStringAsFixed(0)}'
                ' (@₹${_fencingRate.toStringAsFixed(0)}/${_t('landUnit_feet')})',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w600),
              ),
            ),

            const Divider(height: 20),
          ] else ...[
            Text(
              count == 0
                  ? (_tapMode
                      ? _t('landTapHint')
                      : _t('landMeasureWalk'))
                  : '$count ${_t('landMeasurePoints')} — ${_t('landMeasureMinPoints')}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
          ],

          // बटन Row — GPS Walk/Tap + Add + Undo + Reset
          Row(
            children: [
              // Tap Mode में Start/Stop बटन नहीं चाहिए
              if (!_tapMode)
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _pos == null ? null : _toggleMeasuring,
                    icon: Icon(
                        measuring ? Icons.stop_rounded : Icons.play_arrow_rounded),
                    label: Text(measuring
                        ? _t('landMeasureStop')
                        : _t('landMeasureStart')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: measuring
                          ? Colors.red.shade700
                          : DairyTheme.primaryTeal,
                    ),
                  ),
                ),
              if (!_tapMode) const SizedBox(width: 8),
              if (!_tapMode)
                _iconBtn(
                  icon: Icons.add_location_alt_rounded,
                  tooltip: _t('mapAddPoint'),
                  onTap: _pos == null ? null : _addPointHere,
                ),
              if (_tapMode)
                Expanded(
                  flex: 2,
                  child: Text(
                    _t('landTapInstruction'),
                    style: TextStyle(
                        fontSize: 13,
                        color: DairyTheme.primaryTeal,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              const SizedBox(width: 8),
              _iconBtn(
                icon: Icons.undo_rounded,
                tooltip: _t('mapUndoPoint'),
                onTap: count == 0 ? null : _undo,
              ),
              const SizedBox(width: 8),
              _iconBtn(
                icon: Icons.delete_outline_rounded,
                tooltip: _t('landMeasureReset'),
                onTap: count == 0 ? null : _reset,
              ),
            ],
          ),

          // Action buttons — Share + Khaad + Save
          if (!r.isEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                // Share
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _share(r),
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: Text(_t('landMeasureShare'),
                        style: const TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 8),
                // 🌾 खाद कैलकुलेटर
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => KhaadScreen(
                            prefilledArea: r.bigha ?? r.acres,
                            prefilledUnit: r.bigha != null ? 'bigha' : 'acre',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.grass_rounded, size: 16),
                    label: Text(_t('landToKhaad'),
                        style: const TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 8),
                // 💾 Save
                _iconBtn(
                  icon: Icons.save_rounded,
                  tooltip: _t('landSaveField'),
                  onTap: () => _saveField(r),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── तारबंदी दर बदलने का dialog ──
  void _editFencingRate() {
    final ctrl = TextEditingController(text: _fencingRate.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_t('landFencingRate')),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            prefixText: '₹ ',
            suffixText: '/${_t('landUnit_feet')}',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_t('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text.trim());
              if (v != null && v > 0) {
                setState(() => _fencingRate = v);
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: DairyTheme.primaryTeal),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) => Expanded(
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: DairyTheme.primaryTeal)),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      );

  Widget _iconBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onTap,
  }) =>
      Tooltip(
        message: tooltip,
        child: SizedBox(
          width: 52,
          height: 52,
          child: OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(52, 52),
            ),
            child: Icon(icon, size: 22),
          ),
        ),
      );

  void _share(AreaResult r) {
    final perimeterFt = r.perimeterMeters / 0.3048;
    final b = StringBuffer()
      ..writeln('📐 *${_t('navLand')}*')
      ..writeln()
      ..writeln('${_t('landMeasureArea')}:');
    if (r.bigha != null) {
      b.writeln('• ${r.bigha!.toStringAsFixed(2)} ${_t('landMeasureBigha')}');
    }
    b
      ..writeln('• ${r.acres.toStringAsFixed(3)} ${_t('landMeasureAcres')}')
      ..writeln(
          '• ${r.hectares.toStringAsFixed(3)} ${_t('landMeasureHectares')}')
      ..writeln(
          '• ${r.squareMeters.toStringAsFixed(0)} ${_t('landMeasureSquareMeters')}')
      ..writeln()
      ..writeln('📏 ${_t('mapPerimeter')}: ${r.perimeterMeters.toStringAsFixed(0)} ${_t('mapMetre')} (${perimeterFt.toStringAsFixed(0)} ${_t('landUnit_feet')})')
      ..writeln('🪵 ${_t('landFencing')}: ₹${(perimeterFt * _fencingRate).toStringAsFixed(0)}')
      ..writeln()
      ..writeln('📲 ${_t('appName')}');
    WhatsAppService.sendMessage(text: b.toString());
  }
}

// ── 📋 Saved Fields BottomSheet ──
class _SavedFieldsSheet extends StatelessWidget {
  final List<SavedField> fields;
  final String Function(String) t;
  final void Function(SavedField) onLoad;
  final void Function(int) onDelete;

  const _SavedFieldsSheet({
    required this.fields,
    required this.t,
    required this.onLoad,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.folder_open_rounded,
                    color: DairyTheme.primaryTeal),
                const SizedBox(width: 8),
                Text(t('landSavedFields'),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (fields.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Text(t('landNoSavedFields'),
                  style: TextStyle(color: Colors.grey.shade500)),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: fields.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final f = fields[i];
                  final sqFt = f.areaSqM * 10.7639;
                  final date = '${f.savedAt.day}/${f.savedAt.month}/${f.savedAt.year}';
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          DairyTheme.primaryTeal.withValues(alpha: 0.12),
                      child: const Icon(Icons.landscape_rounded,
                          color: DairyTheme.primaryTeal),
                    ),
                    title: Text(f.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      '${f.areaSqM.toStringAsFixed(0)} m² · ${sqFt.toStringAsFixed(0)} ft² · $date',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Colors.red, size: 20),
                      onPressed: () => onDelete(f.id!),
                    ),
                    onTap: () => onLoad(f),
                  );
                },
              ),
            ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}
