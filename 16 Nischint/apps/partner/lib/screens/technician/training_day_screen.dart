import 'package:flutter/material.dart';

import 'package:nischint_core/app/app_scope.dart';
import 'package:nischint_core/app/theme.dart';
import 'package:nischint_core/widgets/common.dart';

import '../../training/curriculum.dart';
import '../../training/training_rules.dart';
import 'lesson_screen.dart';
import 'quiz_screen.dart';
import 'widgets/training_bits.dart';

/// एक दिन (1–5): लक्ष्य, पाठों की सूची (पढ़े हुए पर ✓), और "क्विज़ दें"।
class TrainingDayScreen extends StatelessWidget {
  const TrainingDayScreen({super.key, required this.dayId});

  final String dayId;

  @override
  Widget build(BuildContext context) {
    final day = dayById(dayId);
    if (day == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('ट्रेनिंग')),
        body: const EmptyState(
          icon: Icons.menu_book,
          title: 'यह दिन नहीं मिला',
          message: 'वापस जाकर ट्रेनिंग की सूची से दिन चुनें।',
        ),
      );
    }

    final p = AppScope.of(context).training;
    final allRead = allLessonsRead(p, day);
    final passed = isDayPassed(p, day.id);
    final best = p.quizBest[day.id];
    final pass = passPercentFor(day.id);

    final String buttonLabel;
    if (!allRead) {
      buttonLabel = 'क्विज़ के लिए पहले सारे पाठ पढ़ें';
    } else if (passed) {
      buttonLabel = 'क्विज़ दोबारा दें';
    } else {
      buttonLabel = 'क्विज़ दें';
    }

    return Scaffold(
      appBar: AppBar(title: Text('दिन ${day.number}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.l, AppSpace.l, AppSpace.xl),
        children: [
          Text(day.title, style: AppText.h1),
          const SizedBox(height: AppSpace.m),
          LessonBox(
            title: '🎯 आज का लक्ष्य',
            background: AppColors.primarySoft,
            foreground: AppColors.primaryDark,
            text: day.goal,
          ),
          if (pass >= 100) ...[
            const SizedBox(height: AppSpace.m),
            const InfoBanner(
              tone: ChipTone.danger,
              icon: Icons.health_and_safety_outlined,
              title: 'आज की क्विज़ में 100% ज़रूरी',
              text: 'सुरक्षा में "लगभग सही" नहीं चलता। हर सवाल सही होना चाहिए।',
            ),
          ],
          SectionHeader(
            'आज के पाठ',
            trailing: Text('${lessonsReadIn(p, day)}/${day.lessons.length} पढ़े', style: AppText.muted),
          ),
          for (final lesson in day.lessons)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.m),
              child: _LessonTile(
                number: lessonNumber(day, lesson),
                title: lesson.title,
                minutes: lesson.minutes,
                done: p.completedLessons.contains(lesson.id),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => LessonScreen(dayId: day.id, lessonId: lesson.id),
                  ),
                ),
              ),
            ),
          const SectionHeader('शाम की क्विज़'),
          AppCard(
            child: Row(
              children: [
                NumberBadge(
                  icon: passed ? Icons.emoji_events_outlined : Icons.quiz_outlined,
                  background: passed ? AppColors.success : AppColors.sun,
                ),
                const SizedBox(width: AppSpace.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${day.quiz.length} सवाल · पास होने के लिए $pass%', style: AppText.h3),
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        best == null
                            ? 'अभी क्विज़ नहीं दी। जितनी बार चाहें दे सकते हैं।'
                            : (passed
                                ? 'आपका सबसे अच्छा स्कोर: $best% — पास'
                                : 'आपका सबसे अच्छा स्कोर: $best% — अभी पास नहीं, दोबारा दें'),
                        style: AppText.muted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.m),
          const InfoBanner(
            icon: Icons.engineering,
            title: 'आज फ़ील्ड में',
            text: 'मालिक या सीनियर के साथ जाकर यही काम अपनी आँखों से देखें। ऐप किताब है, हुनर छत पर आता है।',
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        child: AppButton(
          label: buttonLabel,
          icon: allRead ? Icons.quiz_outlined : Icons.lock_outline,
          onPressed: allRead
              ? () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => QuizScreen(dayId: day.id)),
                  )
              : null,
        ),
      ),
    );
  }
}

/// सूची में एक पाठ।
class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.number,
    required this.title,
    required this.minutes,
    required this.done,
    required this.onTap,
  });

  final String number;
  final String title;
  final int minutes;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      borderColor: done ? AppColors.success : AppColors.border,
      child: Row(
        children: [
          done
              ? const NumberBadge(icon: Icons.check, background: AppColors.success)
              : NumberBadge(label: number, background: AppColors.primarySoft, foreground: AppColors.primaryDark),
          const SizedBox(width: AppSpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('पाठ $number', style: AppText.small),
                const SizedBox(height: 2),
                Text(title, style: AppText.h3),
                const SizedBox(height: 2),
                Text(done ? 'पढ़ लिया ✓' : 'करीब $minutes मिनट', style: AppText.small),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
