import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../data/weather_models.dart';
import '../../l10n/app_localizations.dart';
import '../theme/dairy_theme.dart';
import 'weather_common.dart';

/// किसी दिन या घंटे के card पर touch करने से खुलने वाली पूरी जानकारी।
class WeatherDetailSheet extends StatefulWidget {
  final DailyForecast day;
  final HourlyForecast? hour;
  final String placeName;

  const WeatherDetailSheet({
    super.key,
    required this.day,
    this.hour,
    required this.placeName,
  });

  static Future<void> show(
    BuildContext context, {
    required DailyForecast day,
    HourlyForecast? hour,
    required String placeName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          WeatherDetailSheet(day: day, hour: hour, placeName: placeName),
    );
  }

  @override
  State<WeatherDetailSheet> createState() => _WeatherDetailSheetState();
}

class _WeatherDetailSheetState extends State<WeatherDetailSheet> {
  final _tts = FlutterTts();
  bool _speaking = false;

  String _t(String k) => AppLocalizations.get(context, k);
  String get _lang => AppLocalizations.langCode(context);

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (_speaking) {
      await _tts.stop();
      if (mounted) setState(() => _speaking = false);
      return;
    }
    final ttsLocales = {
      'hi': 'hi-IN', 'bho': 'hi-IN', 'mr': 'mr-IN',
      'bn': 'bn-IN', 'te': 'te-IN', 'ta': 'ta-IN',
      'gu': 'gu-IN', 'kn': 'kn-IN', 'pa': 'pa-IN',
      'en': 'en-IN'
    };
    await _tts.setLanguage(ttsLocales[_lang] ?? 'en-IN');
    await _tts.setSpeechRate(0.55);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _speaking = false);
    });
    if (mounted) setState(() => _speaking = true);
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.day;
    final h = widget.hour;
    final isHourly = h != null;
    final code = isHourly ? h.weatherCode : d.weatherCode;
    final w = wmoInfo(context, code);
    final advice = farmAdvice(d, _lang);

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.94,
      expand: false,
      builder: (context, scroll) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),

            // ── शीर्षक: कौन सा दिन/घंटा, कहाँ का ──
            Text(
              isHourly
                  ? '${hourLabel(h.time, _lang)} · ${dayMonthShort(d.date, _lang)}'
                  : fullDate(d.date, _lang),
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            Text('📍 ${widget.placeName}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 18),

            // ── बड़ा तापमान + हाल ──
            Row(
              children: [
                Text(w['emoji']!, style: const TextStyle(fontSize: 56)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHourly
                            ? '${h.temp.round()}°'
                            : '${d.maxTemp.round()}° / ${d.minTemp.round()}°',
                        style: const TextStyle(
                            fontSize: 38, fontWeight: FontWeight.w800, height: 1),
                      ),
                      const SizedBox(height: 4),
                      Text(w['desc']!,
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey.shade700)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── ब्यौरा ──
            _grid(isHourly ? _hourlyTiles(h, d) : _dailyTiles(d)),

            const SizedBox(height: 22),

            // ── किसान के काम की सलाह ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: DairyTheme.primaryTeal.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: DairyTheme.primaryTeal.withValues(alpha: 0.18)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.agriculture_rounded,
                          size: 20, color: DairyTheme.primaryTeal),
                      const SizedBox(width: 8),
                      Text(_t('wFarmAdvice'),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: DairyTheme.primaryTeal)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...advice.map((a) => Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: Text(a,
                            style: const TextStyle(fontSize: 15, height: 1.4)),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _speak(_speechText(d, h, w['desc']!, advice)),
                icon: Icon(_speaking
                    ? Icons.stop_circle_rounded
                    : Icons.volume_up_rounded),
                label: Text(_speaking ? _t('yStop') : _t('ySpeak')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// पूरे दिन के लिए क्या-क्या दिखाएँ
  List<_Tile> _dailyTiles(DailyForecast d) => [
        if (d.rainChance != null)
          _Tile('🌧️', _t('weatherPrecipitation'), '${d.rainChance!.round()}%'),
        _Tile('💧', _t('wRainAmount'), '${d.precipitation.toStringAsFixed(1)} ${_t('wMm')}'),
        if (d.windMax != null)
          _Tile('💨', _t('wWind'), '${d.windMax!.round()} ${_t('wKmh')}'),
        _Tile('☀️', _t('wUV'), d.uvIndex.toStringAsFixed(1)),
        if (d.feelsMax != null)
          _Tile('🌡️', _t('wFeels'), '${d.feelsMax!.round()}° / ${d.feelsMin?.round() ?? '-'}°'),
        if (d.sunrise != null)
          _Tile('🌅', _t('weatherSunrise'), _clock(d.sunrise!)),
        if (d.sunset != null)
          _Tile('🌇', _t('weatherSunset'), _clock(d.sunset!)),
      ];

  /// एक घंटे के लिए
  List<_Tile> _hourlyTiles(HourlyForecast h, DailyForecast d) => [
        _Tile('🌧️', _t('weatherPrecipitation'), '${h.rainChance.round()}%'),
        if (h.rainMm != null)
          _Tile('💧', _t('wRainAmount'), '${h.rainMm!.toStringAsFixed(1)} ${_t('wMm')}'),
        _Tile('💨', _t('wWind'),
            '${h.windSpeed.round()} ${_t('wKmh')} ${windDirectionName(h.windDirection, _lang == 'hi' || _lang == 'bho')}'),
        if (h.humidity != null) _Tile('💦', _t('wHumidity'), '${h.humidity}%'),
        if (h.feelsLike != null)
          _Tile('🌡️', _t('wFeels'), '${h.feelsLike!.round()}°'),
        if (d.sunrise != null)
          _Tile('🌅', _t('weatherSunrise'), _clock(d.sunrise!)),
        if (d.sunset != null)
          _Tile('🌇', _t('weatherSunset'), _clock(d.sunset!)),
      ];

  Widget _grid(List<_Tile> tiles) => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: tiles
            .map((t) => SizedBox(
                  width: (MediaQuery.of(context).size.width - 50) / 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 11),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Text(t.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600)),
                              Text(t.value,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      );

  String _clock(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String _speechText(
      DailyForecast d, HourlyForecast? h, String desc, List<String> advice) {
    final b = StringBuffer();
    if (h != null) {
      b.writeln('${hourLabel(h.time, _lang)}, $desc, ${h.temp.round()} degrees.');
    } else {
      b.writeln(
          '${fullDate(d.date, _lang)}. $desc. Max ${d.maxTemp.round()}, min ${d.minTemp.round()} degrees.');
    }
    for (final a in advice) {
      b.writeln(a.replaceAll(RegExp(r'[^ऀ-ॿ -~]'), '').trim());
    }
    return b.toString();
  }
}

class _Tile {
  final String emoji, label, value;
  const _Tile(this.emoji, this.label, this.value);
}

