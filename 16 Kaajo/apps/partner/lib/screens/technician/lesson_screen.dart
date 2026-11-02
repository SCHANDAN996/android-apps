import 'package:flutter/material.dart';

import 'package:kaajo_core/app/app_scope.dart';
import 'package:kaajo_core/app/theme.dart';
import 'package:kaajo_core/widgets/common.dart';

import '../../training/curriculum.dart';
import '../../training/training_rules.dart';
import 'widgets/training_bits.dart';

/// एक पाठ, हमेशा एक ही ढाँचे में:
/// 🎯 आज क्या सीखेंगे → 📋 मुख्य बातें → ✅ ऐसे करें → ❌ ऐसा कभी न करें → 💡 क्यों ज़रूरी → 🧠 याद रखें।
class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.dayId, required this.lessonId});

  final String dayId;
  final String lessonId;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  bool _saving = false;

  Future<void> _understood(TrainingDay day, Lesson lesson) async {
    setState(() => _saving = true);
    final app = AppScope.read(context);
    await app.markLessonDone(lesson.id);
    if (!mounted) return;

    final navigator = Navigator.of(context);
    final i = day.lessons.indexWhere((l) => l.id == lesson.id);
    if (i >= 0 && i + 1 < day.lessons.length) {
      final next = day.lessons[i + 1];
      navigator.pushReplacement(
        MaterialPageRoute<void>(builder: (_) => LessonScreen(dayId: day.id, lessonId: next.id)),
      );
      return;
    }

    // दिन का आख़िरी पाठ: वापस दिन वाली स्क्रीन पर।
    final allRead = allLessonsRead(app.training, day);
    showMessage(
      context,
      allRead ? 'शाबाश! आज के सारे पाठ पूरे हुए। अब "क्विज़ दें" दबाएँ।' : 'पाठ पूरा हुआ। बाकी पाठ भी पढ़ें।',
    );
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final day = dayById(widget.dayId);
    final lesson = day == null ? null : lessonById(day, widget.lessonId);
    if (day == null || lesson == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('पाठ')),
        body: const EmptyState(
          icon: Icons.menu_book,
          title: 'यह पाठ नहीं मिला',
          message: 'वापस जाकर दिन की सूची से पाठ चुनें।',
        ),
      );
    }

    final done = AppScope.of(context).training.completedLessons.contains(lesson.id);
    final index = day.lessons.indexWhere((l) => l.id == lesson.id);

    return Scaffold(
      appBar: AppBar(title: Text('पाठ ${lessonNumber(day, lesson)}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.l, AppSpace.l, AppSpace.xl),
        children: [
          Text('दिन ${day.number} · पाठ ${index + 1} / ${day.lessons.length}', style: AppText.muted),
          const SizedBox(height: AppSpace.xs),
          Text(lesson.title, style: AppText.h1),
          const SizedBox(height: AppSpace.s),
          Wrap(
            spacing: AppSpace.s,
            runSpacing: AppSpace.s,
            children: [
              StatusChip('करीब ${lesson.minutes} मिनट', tone: ChipTone.info),
              if (done) const StatusChip('पढ़ लिया ✓', tone: ChipTone.success),
            ],
          ),
          const SizedBox(height: AppSpace.l),

          // 🎯
          LessonBox(
            title: '🎯 आज क्या सीखेंगे',
            background: AppColors.primarySoft,
            foreground: AppColors.primaryDark,
            text: lesson.goal,
          ),
          const SizedBox(height: AppSpace.l),

          // 📋
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📋 मुख्य बातें', style: TrainingText.boxTitle.copyWith(color: AppColors.text)),
                const SizedBox(height: AppSpace.s),
                for (var i = 0; i < lesson.points.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpace.m),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NumberBadge(
                          label: '${i + 1}',
                          size: 30,
                          background: AppColors.primarySoft,
                          foreground: AppColors.primaryDark,
                        ),
                        const SizedBox(width: AppSpace.m),
                        Expanded(child: Text(lesson.points[i], style: TrainingText.reading)),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ✅
          if (lesson.doList.isNotEmpty) ...[
            const SizedBox(height: AppSpace.l),
            LessonBox(
              title: '✅ ऐसे करें',
              background: AppColors.successSoft,
              foreground: AppColors.success,
              items: lesson.doList,
              bullet: '✓',
            ),
          ],

          // ❌
          if (lesson.dontList.isNotEmpty) ...[
            const SizedBox(height: AppSpace.l),
            LessonBox(
              title: '❌ ऐसा कभी न करें',
              background: AppColors.dangerSoft,
              foreground: AppColors.danger,
              items: lesson.dontList,
              bullet: '✗',
            ),
          ],

          // 💡
          const SizedBox(height: AppSpace.l),
          LessonBox(
            title: '💡 क्यों ज़रूरी',
            background: AppColors.sunSoft,
            foreground: AppColors.warning,
            text: lesson.why,
          ),

          // 🧠
          const SizedBox(height: AppSpace.l),
          AppCard(
            color: AppColors.primary,
            borderColor: AppColors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🧠 याद रखें',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white70),
                ),
                const SizedBox(height: AppSpace.s),
                Text(
                  lesson.remember,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        child: AppButton(
          label: _saving ? 'सेव हो रहा है…' : 'समझ गया, आगे बढ़ें',
          icon: Icons.check_circle_outline,
          onPressed: _saving ? null : () => _understood(day, lesson),
        ),
      ),
    );
  }
}
