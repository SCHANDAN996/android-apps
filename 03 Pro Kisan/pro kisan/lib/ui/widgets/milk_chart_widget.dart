import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../db/models/milk_entry.dart';
import '../theme/dairy_theme.dart';
import '../../l10n/app_localizations.dart';

/// Reusable Milk Chart Widget displaying daily milk production/supply trend.
class MilkChartWidget extends StatelessWidget {
  final List<MilkEntry> entries;
  final String title;
  final bool isCompact;

  const MilkChartWidget({
    super.key,
    required this.entries,
    this.title = '',
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              AppLocalizations.get(context, 'report_no_entries'),
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
        ),
      );
    }

    // Group entries by date (DD-MM-YYYY) -> total litres per date
    final Map<String, double> dailyTotals = {};
    for (final e in entries) {
      dailyTotals[e.date] = (dailyTotals[e.date] ?? 0.0) + e.qtyL;
    }

    // Sort entries chronologically (oldest to newest for graph X-axis)
    final sortedDates = dailyTotals.keys.toList()
      ..sort((a, b) {
        try {
          final dA = DateFormat('dd-MM-yyyy').parse(a);
          final dB = DateFormat('dd-MM-yyyy').parse(b);
          return dA.compareTo(dB);
        } catch (_) {
          return a.compareTo(b);
        }
      });

    // Take the latest 7-10 data points for optimal mobile graph display
    final displayDates = sortedDates.length > 10
        ? sortedDates.sublist(sortedDates.length - 10)
        : sortedDates;

    double maxLitres = 0;
    final List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < displayDates.length; i++) {
      final dateStr = displayDates[i];
      final litres = dailyTotals[dateStr] ?? 0.0;
      if (litres > maxLitres) maxLitres = litres;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: litres,
              gradient: const LinearGradient(
                colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: displayDates.length > 7 ? 14 : 18,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        ),
      );
    }

    final maxY = maxLitres > 0 ? (maxLitres * 1.25).ceilToDouble() : 10.0;
    final displayTitle = title.isNotEmpty
        ? title
        : AppLocalizations.isHindiLike(context)
            ? '📈 दूध आपूर्ति ट्रेंड (लीटर)'
            : '📈 Milk Supply Trend (Litres)';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  displayTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: DairyTheme.primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${displayDates.length} ${AppLocalizations.isHindiLike(context) ? "दिन" : "Days"}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: DairyTheme.primaryTeal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: isCompact ? 160 : 200,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final dateStr = displayDates[group.x.toInt()];
                        final dayShort = dateStr.length >= 5 ? dateStr.substring(0, 5) : dateStr;
                        return BarTooltipItem(
                          '$dayShort\n${rod.toY.toStringAsFixed(1)} L',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: (maxY / 4).clamp(1, 100).toDouble(),
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox.shrink();
                          return Text(
                            '${value.toInt()}L',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < displayDates.length) {
                            final rawDate = displayDates[idx];
                            // Format DD-MM to DD/MM
                            final shortDate = rawDate.length >= 5
                                ? rawDate.substring(0, 5).replaceAll('-', '/')
                                : rawDate;
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                shortDate,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxY / 4).clamp(1, 100).toDouble(),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withValues(alpha: 0.15),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: barGroups,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
