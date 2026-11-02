import 'package:flutter/material.dart';

import 'package:nischint_core/app/theme.dart';
import 'package:nischint_core/widgets/common.dart';

import '../../../training/training_rules.dart';

/// ट्रेनिंग में पढ़ने वाले बड़े टेक्स्ट।
class TrainingText {
  TrainingText._();

  /// पाठ की बातें: बड़े अक्षर, ताकि आराम से पढ़ा जा सके।
  static const TextStyle reading = TextStyle(fontSize: 18, color: AppColors.text, height: 1.5);

  /// बॉक्स के शीर्षक।
  static const TextStyle boxTitle = TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.3);
}

/// दिन की स्थिति का लेबल: पूरा / चालू / बंद 🔒
class DayStatusChip extends StatelessWidget {
  const DayStatusChip(this.status, {super.key});

  final DayStatus status;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      DayStatus.done => const StatusChip('पूरा', tone: ChipTone.success),
      DayStatus.open => const StatusChip('चालू', tone: ChipTone.info),
      DayStatus.locked => const StatusChip('बंद 🔒'),
    };
  }
}

/// गोल बिल्ला: अंदर नंबर या आइकन।
class NumberBadge extends StatelessWidget {
  const NumberBadge({
    super.key,
    this.label,
    this.icon,
    this.background = AppColors.primary,
    this.foreground = Colors.white,
    this.size = 44,
  });

  final String? label;
  final IconData? icon;
  final Color background;
  final Color foreground;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: icon != null
          ? Icon(icon, color: foreground, size: size * 0.5)
          : Text(
              label ?? '',
              style: TextStyle(color: foreground, fontSize: size * 0.4, fontWeight: FontWeight.w800),
            ),
    );
  }
}

/// रंगीन बॉक्स: ऊपर शीर्षक (इमोजी के साथ), नीचे बिंदु या एक लाइन।
class LessonBox extends StatelessWidget {
  const LessonBox({
    super.key,
    required this.title,
    required this.background,
    required this.foreground,
    this.items = const [],
    this.text,
    this.bullet = '•',
  });

  final String title;
  final Color background;
  final Color foreground;
  final List<String> items;
  final String? text;
  final String bullet;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpace.l),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpace.radius),
        border: Border.all(color: foreground.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TrainingText.boxTitle.copyWith(color: foreground)),
          const SizedBox(height: AppSpace.s),
          if (text != null) Text(text!, style: TrainingText.reading),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(top: AppSpace.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      bullet,
                      style: TrainingText.reading.copyWith(color: foreground, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Expanded(child: Text(item, style: TrainingText.reading)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
