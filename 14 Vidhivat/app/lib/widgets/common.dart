import 'package:flutter/material.dart';

import '../theme.dart';
import 'design_system.dart';

/// समय को "14:35" की तरह दिखाओ।
String hm(DateTime? t) => t == null
    ? '—'
    : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// "14:35:07"
String hms(DateTime? t) =>
    t == null ? '—' : '${hm(t)}:${t.second.toString().padLeft(2, '0')}';

const _mahine = [
  '',
  'जनवरी',
  'फ़रवरी',
  'मार्च',
  'अप्रैल',
  'मई',
  'जून',
  'जुलाई',
  'अगस्त',
  'सितम्बर',
  'अक्टूबर',
  'नवम्बर',
  'दिसम्बर',
];

const _mahineChhote = [
  '',
  'जन',
  'फ़र',
  'मार्च',
  'अप्रैल',
  'मई',
  'जून',
  'जुल',
  'अग',
  'सित',
  'अक्तू',
  'नव',
  'दिस',
];

String tarikh(DateTime d) => '${d.day} ${_mahine[d.month]} ${d.year}';
String tarikhChhoti(DateTime d) => '${d.day} ${_mahineChhote[d.month]}';

/// समय — और अगर वो [aadhar] वाले दिन का न हो तो तारीख़ भी।
///
/// ⚠️ **यह ग्रहण के सूतक में ज़रूरी है, और फ़ोन पर पकड़ा गया था।**
/// 21 मई 2031 के सूर्यग्रहण का सूतक **एक दिन पहले** 21:17 पर लगता है।
/// बिना तारीख़ के कार्ड पर लिखा आता था *"सूतक 21:17 बजे से 15:07 बजे
/// तक"* — जो उल्टा पढ़ा जाता है, जैसे समय पीछे चल रहा हो।
String samayAurDin(DateTime pal, DateTime aadhar) =>
    _usiDinKa(pal, aadhar)
        ? '${hm(pal)} बजे'
        : '${tarikhChhoti(pal)} को ${hm(pal)} बजे';

/// वही बात, पर `Pankti` के मान वाले खाने के लिए — "बजे" के बिना।
///
/// ⚠️ चंद्रग्रहण आधी रात के आर-पार चलता है। 16 जून 2030 के कार्ड पर
/// स्पर्श 22:50 (15 जून का) और मध्य 00:02 (16 जून का) एक साथ लिखे थे,
/// दोनों बिना तारीख़ के।
String samayAurDinChhota(DateTime pal, DateTime aadhar) =>
    _usiDinKa(pal, aadhar)
        ? hm(pal)
        : '${tarikhChhoti(pal)}, ${hm(pal)}';

bool _usiDinKa(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// समय आज का है, कल का, या बीती रात का — यह बताना ज़रूरी है।
///
/// हिंदू दिन सूर्योदय से अगले सूर्योदय तक चलता है, इसलिए आख़िरी अंग अक्सर
/// अगली सुबह ख़त्म होता है। बिना निशान के यूज़र समझेगा कि आज ही ख़त्म हुआ।
String dinKaNishan(DateTime? t, DateTime aaj) {
  if (t == null) return '';
  final farq = DateTime(t.year, t.month, t.day)
      .difference(DateTime(aaj.year, aaj.month, aaj.day))
      .inDays;
  if (farq == 1) return ' (कल)';
  if (farq == 2) return ' (परसों)';
  if (farq == -1) return ' (बीती रात)';
  if (farq < -1) return ' (${-farq} दिन पहले)';
  if (farq > 2) return ' (+$farq दिन)';
  return '';
}

/// एक पंक्ति — बाईं तरफ़ नाम, दाईं तरफ़ मान।
class Pankti extends StatelessWidget {
  final String label;
  final String value;
  final String? note;
  final Color? valueColour;
  final bool bold;

  const Pankti(
    this.label,
    this.value, {
    super.key,
    this.note,
    this.valueColour,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: VidhivatSpacing.md,
        vertical: VidhivatSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(
              label,
              style: type.bodyMedium.copyWith(color: colors.textSecondary),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: type.bodyLarge.copyWith(
                    fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
                    color: valueColour,
                  ),
                ),
                if (note != null)
                  Text(
                    note!,
                    style: type.bodySmall.copyWith(color: colors.textTertiary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// चेतावनी या ध्यान देने वाली बात।
class Chetavni extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool serious;

  const Chetavni(
    this.text, {
    super.key,
    this.icon = Icons.info_outline,
    this.serious = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final colour = serious ? colors.warning : colors.info;

    return Padding(
      padding: const EdgeInsets.only(bottom: VidhivatSpacing.sm),
      child: Semantics(
        container: true,
        liveRegion: serious,
        label: serious ? 'चेतावनी। $text' : text,
        excludeSemantics: true,
        child: VidhivatSurfaceCard(
          variant: serious
              ? VidhivatCardVariant.warning
              : VidhivatCardVariant.information,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: VidhivatIconSize.medium, color: colour),
              const SizedBox(width: VidhivatSpacing.sm),
              Expanded(
                child: Text(
                  text,
                  style: VidhivatTheme.typographyOf(context).bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// पूरे ऐप में एक जैसा पन्ना — ऊपर-नीचे बराबर जगह।
class Panna extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;

  const Panna({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(
      VidhivatSpacing.md,
      VidhivatSpacing.xs,
      VidhivatSpacing.md,
      VidhivatSpacing.xxl,
    ),
  });

  @override
  Widget build(BuildContext context) => ListView(
        padding: padding,
        children: children,
      );
}
