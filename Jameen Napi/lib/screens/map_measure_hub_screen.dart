import 'package:flutter/material.dart';

import '../data/app_language.dart';
import '../data/map_strings.dart';
import '../data/saved_measurements.dart';
import '../data/tool_strings.dart';
import '../geo/measure_session.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/map_result_sheet.dart';
import 'map_measure_screen.dart';

/// नक्शे वाली नाप के तीन साफ़ entry-points और फ़ोन में सहेजा हुआ इतिहास।
class MapMeasureHubScreen extends StatefulWidget {
  const MapMeasureHubScreen({super.key});

  @override
  State<MapMeasureHubScreen> createState() => _MapMeasureHubScreenState();
}

class _MapMeasureHubScreenState extends State<MapMeasureHubScreen> {
  late Future<List<SavedMeasurement>> _saved =
      SavedMeasurementStore.instance.loadAll();

  void _reload() {
    setState(() => _saved = SavedMeasurementStore.instance.loadAll());
  }

  Future<void> _open(MapMeasureScreen screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    if (mounted) _reload();
  }

  Future<void> _delete(SavedMeasurement item, AppStrings strings) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.mapDelete),
        content: Text(strings.mapDeleteConfirm(item.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(strings.mapCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(strings.mapDelete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await SavedMeasurementStore.instance.delete(item.id);
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLang>(
      valueListenable: LanguageNotifier.instance,
      builder: (context, lang, _) {
        final strings = AppStrings(lang);
        return Scaffold(
          appBar: AppBar(title: Text(strings.toolMap)),
          // नापने वाली screen पर banner जान-बूझकर नहीं है (वहाँ नक्शा पूरा
          // चाहिए, और चलते-चलते ad पर उंगली पड़ जाती है) — इसलिए यहाँ है।
          bottomNavigationBar: const BannerAdWidget(),
          body: RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                _ChoiceCard(
                  icon: Icons.touch_app_rounded,
                  color: const Color(0xFF1565C0),
                  title: strings.mapTapTitle,
                  body: strings.mapTapBody,
                  onTap: () => _open(const MapMeasureScreen(
                    method: MeasureMethod.tap,
                  )),
                ),
                _ChoiceCard(
                  icon: Icons.directions_walk_rounded,
                  color: const Color(0xFF2E7D32),
                  title: strings.mapWalkTitle,
                  body: strings.mapWalkBody,
                  onTap: () => _open(const MapMeasureScreen(
                    method: MeasureMethod.walkCorners,
                  )),
                ),
                _ChoiceCard(
                  icon: Icons.route_rounded,
                  color: const Color(0xFFE65100),
                  title: strings.mapRoadTitle,
                  body: strings.mapRoadBody,
                  onTap: () => _open(const MapMeasureScreen(
                    method: MeasureMethod.track,
                    kind: MeasureKind.distance,
                  )),
                ),
                _Note(text: strings.mapAccuracyNote, icon: Icons.info_outline),
                _Note(text: strings.mapInternetNote, icon: Icons.wifi_off_rounded),
                const SizedBox(height: 14),
                Text(strings.mapSavedTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1B5E20))),
                const SizedBox(height: 8),
                FutureBuilder<List<SavedMeasurement>>(
                  future: _saved,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final items = snapshot.data ?? const <SavedMeasurement>[];
                    if (items.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Text(strings.mapNoSaved,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black54)),
                      );
                    }
                    return Column(
                      children: [
                        for (final item in items)
                          Card(
                            child: ListTile(
                              leading: Icon(
                                item.session.kind == MeasureKind.area
                                    ? Icons.crop_square_rounded
                                    : Icons.timeline_rounded,
                                color: const Color(0xFF2E7D32),
                              ),
                              title: Text(item.name),
                              subtitle: Text(_savedSubtitle(item, strings)),
                              onTap: () => _open(MapMeasureScreen(
                                method: MeasureMethod.tap,
                                kind: item.session.kind,
                                saved: item,
                              )),
                              trailing: IconButton(
                                tooltip: strings.mapDelete,
                                icon: const Icon(Icons.delete_outline_rounded),
                                onPressed: () => _delete(item, strings),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _savedSubtitle(SavedMeasurement item, AppStrings strings) {
    final session = item.session;
    if (session.kind == MeasureKind.area) {
      return '${strings.mapKindArea}: ${formatMeasured(session.areaSqFt)} '
          '${strings.sqFt} • ${strings.mapPointCount(session.pointCount)}';
    }
    return '${strings.mapKindDistance}: '
        '${formatDistance(strings, session.lengthMeters)}';
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(body,
                          style: const TextStyle(
                              color: Colors.black54, height: 1.3)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              ],
            ),
          ),
        ),
      );
}

class _Note extends StatelessWidget {
  const _Note({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1565C0).withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF1565C0), size: 19),
            const SizedBox(width: 8),
            Expanded(
                child: Text(text,
                    style: const TextStyle(color: Colors.black87, height: 1.3))),
          ],
        ),
      );
}
