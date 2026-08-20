import 'package:flutter/material.dart';

import '../theme.dart';

/// समय को "14:35" की तरह दिखाओ।
String hm(DateTime? t) => t == null
    ? '—'
    : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// "14:35:07"
String hms(DateTime? t) =>
    t == null ? '—' : '${hm(t)}:${t.second.toString().padLeft(2, '0')}';

const _mahine = [
  '', 'जनवरी', 'फ़रवरी', 'मार्च', 'अप्रैल', 'मई', 'जून',
  'जुलाई', 'अगस्त', 'सितम्बर', 'अक्टूबर', 'नवम्बर', 'दिसम्बर',
];

const _mahineChhote = [
  '', 'जन', 'फ़र', 'मार्च', 'अप्रैल', 'मई', 'जून',
  'जुल', 'अग', 'सित', 'अक्तू', 'नव', 'दिस',
];

String tarikh(DateTime d) => '${d.day} ${_mahine[d.month]} ${d.year}';
String tarikhChhoti(DateTime d) => '${d.day} ${_mahineChhote[d.month]}';

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

/// एक खंड — शीर्षक और उसके नीचे का हिस्सा।
class Khand extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;

  const Khand({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: VidhivatTheme.haldi,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.7),
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Card(child: child),
        ],
      ),
    );
  }
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
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.65),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
                    color: valueColour,
                  ),
                ),
                if (note != null)
                  Text(
                    note!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.6),
                    ),
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
    final colour = serious
        ? Theme.of(context).colorScheme.secondary
        : VidhivatTheme.haldi;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: colour, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colour),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
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
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 32),
  });

  @override
  Widget build(BuildContext context) => ListView(
        padding: padding,
        children: children,
      );
}
