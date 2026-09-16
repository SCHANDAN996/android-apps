import 'package:flutter/material.dart';

import '../data/app_language.dart';
import '../data/land_units.dart';
import '../data/map_strings.dart';
import '../data/plot_units.dart';
import '../data/tool_strings.dart';
import '../geo/geo_math.dart';
import 'accent_card.dart';

/// रकबा दिखाने के लिए सबसे समझ आने वाली इकाई।
///
/// पहले राज्य की अपनी इकाइयाँ (बीघा, कट्ठा, गुंठा…) — उनमें सबसे बड़ी जिसमें
/// संख्या कम से कम 1 हो। "0.004 बीघा" से "5.4 धुर" ज़्यादा समझ आता है। राज्य
/// की कोई इकाई फिट न हो तो एकड़ → डिसमिल → वर्ग फीट।
LandUnit primaryUnitFor(String state, double sqft) {
  LandUnit? best;
  for (final u in stateUnits[state] ?? const <LandUnit>[]) {
    if (sqft / u.sqft >= 1 && (best == null || u.sqft > best.sqft)) best = u;
  }
  if (best != null) return best;
  LandUnit std(String en) => standardUnits.firstWhere((u) => u.en == en);
  if (sqft >= 43560) return std('Acre');
  if (sqft >= 435.6) return std('Dismil / Decimal');
  return std('Sq. Feet');
}

/// "850 मीटर (2,789 फीट)" या "2.35 किमी"
String formatDistance(AppStrings s, double meters) {
  if (meters >= 1000) {
    return '${(meters / 1000).toStringAsFixed(2)} ${s.mapKilometer}';
  }
  final m = meters.round();
  final ft = (meters * feetPerMeter).round();
  return '${formatIndian(m.toDouble())} ${s.plotUnitName(PlotUnit.meter)} '
      '(${formatIndian(ft.toDouble())} ${s.plotUnitName(PlotUnit.feet)})';
}

/// छोटी संख्याओं को 2 दशमलव तक — नक्शे की नाप में 6 दशमलव झूठी सटीकता है
String formatMeasured(double v) {
  if (v >= 1000) return formatIndian(v.roundToDouble());
  return formatIndian(double.parse(v.toStringAsFixed(2)));
}

/// "सभी इकाइयों में देखें" — राज्य बदलकर सारी इकाइयाँ।
Future<void> showAllUnitsSheet(
  BuildContext context, {
  required AppStrings strings,
  required double sqft,
  required double perimeterMeters,
  required String initialState,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (ctx) {
      var state = initialState;
      return StatefulBuilder(
        builder: (ctx, setSheet) {
          final units = unitsForState(state);
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            maxChildSize: 0.95,
            builder: (ctx, scroll) => ListView(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                Text(
                  '${formatMeasured(sqft)} ${strings.sqFt}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20)),
                ),
                const SizedBox(height: 4),
                Text(
                  '${strings.mapPerimeter}: ${formatDistance(strings, perimeterMeters)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: state,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: strings.stateLabel,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: standardStateKey,
                      child: Text(strings.stateDisplayName(standardStateKey),
                          overflow: TextOverflow.ellipsis),
                    ),
                    ...stateUnits.keys.map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(strings.stateDisplayName(s),
                              overflow: TextOverflow.ellipsis),
                        )),
                  ],
                  onChanged: (s) {
                    if (s != null) setSheet(() => state = s);
                  },
                ),
                const SizedBox(height: 12),
                for (final u in units.reversed)
                  AccentCard(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        formatMeasured(sqft / u.sqft),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                            fontSize: 17),
                      ),
                      subtitle: Text(u.label,
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 12)),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    },
  );
}
