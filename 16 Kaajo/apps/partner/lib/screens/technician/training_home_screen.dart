import 'package:flutter/material.dart';

import 'package:kaajo_core/app/app_scope.dart';
import 'package:kaajo_core/app/theme.dart';
import 'package:kaajo_core/content/config.dart';
import 'package:kaajo_core/models/training.dart';
import 'package:kaajo_core/widgets/common.dart';

import '../../training/curriculum.dart';
import '../../training/training_rules.dart';
import '../common/settings_screen.dart';
import 'certificate_screen.dart';
import 'lesson_screen.dart';
import 'practical_checklist_screen.dart';
import 'quiz_screen.dart';
import 'training_day_screen.dart';
import 'widgets/training_bits.dart';

/// टेक्नीशियन का पहला टैब: प्रगति, सीखने का तरीका और 6 दिन।
class TrainingHomeScreen extends StatelessWidget {
  const TrainingHomeScreen({super.key});

  static void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  /// नीचे वाले बटन का अगला क़दम: अगला पाठ, क्विज़, फ़ील्ड ट्रायल या सर्टिफ़िकेट।
  static _NextStep _nextStep(TrainingProgress p) {
    if (p.isCertified) {
      return const _NextStep('सर्टिफ़िकेट देखें', Icons.workspace_premium, CertificateScreen());
    }
    for (final day in trainingDays) {
      if (isDayPassed(p, day.id)) continue;
      // पहला बिना पास वाला दिन हमेशा खुला होता है (उससे पहले वाला पास है)।
      for (final lesson in day.lessons) {
        if (!p.completedLessons.contains(lesson.id)) {
          return _NextStep(
            'आगे पढ़ें: पाठ ${lessonNumber(day, lesson)}',
            Icons.menu_book,
            LessonScreen(dayId: day.id, lessonId: lesson.id),
          );
        }
      }
      return _NextStep('दिन ${day.number} की क्विज़ दें', Icons.quiz_outlined, QuizScreen(dayId: day.id));
    }
    return _NextStep(
      allPracticalDone(p) ? 'ट्रेनिंग पूरी करें' : 'फ़ील्ड ट्रायल खोलें',
      Icons.fact_check_outlined,
      const PracticalChecklistScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final name = app.technician.name.trim();
    final p = app.training;
    final next = _nextStep(p);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ट्रेनिंग'),
        actions: [
          IconButton(
            tooltip: 'सेटिंग',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _open(context, const SettingsScreen()),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.l, AppSpace.l, AppSpace.xl),
        children: [
          if (p.isCertified) ...[
            _CertifiedCard(onTap: () => _open(context, const CertificateScreen())),
            const SizedBox(height: AppSpace.l),
          ],
          Text(name.isEmpty ? 'नमस्ते!' : 'नमस्ते, $name!', style: AppText.h1),
          const SizedBox(height: AppSpace.xs),
          Text(
            p.isCertified
                ? 'आपकी ट्रेनिंग पूरी हो गई है। शाबाश!'
                : 'आपकी पूरी ट्रेनिंग इसी ऐप में होगी: 6 दिन, रोज़ थोड़ा-थोड़ा।',
            style: AppText.muted,
          ),
          const SizedBox(height: AppSpace.l),
          _ProgressCard(progress: p),
          const SizedBox(height: AppSpace.m),
          const _HowToLearnCard(),
          const SectionHeader('6 दिन का पाठ्यक्रम'),
          for (var i = 0; i < trainingDays.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.m),
              child: _DayCard(
                number: trainingDays[i].number,
                title: trainingDays[i].title,
                subtitle: _daySubtitle(p, trainingDays[i]),
                status: dayStatus(p, i),
                onTap: () {
                  if (!isDayUnlocked(p, i)) {
                    showMessage(context, 'यह दिन अभी बंद है। पहले दिन ${trainingDays[i - 1].number} की क्विज़ पास करें।');
                    return;
                  }
                  _open(context, TrainingDayScreen(dayId: trainingDays[i].id));
                },
              ),
            ),
          _DayCard(
            number: fieldTrialDayNumber,
            title: fieldTrialTitle,
            subtitle: '${practicalItems.length} काम, हर काम सुपरवाइज़र कोड से पास · '
                'पूरे: ${practicalDoneCount(p)}/${practicalItems.length}',
            status: fieldTrialStatus(p),
            onTap: () {
              if (!isFieldTrialUnlocked(p) && !p.isCertified) {
                showMessage(context, 'फ़ील्ड ट्रायल अभी बंद है। पहले दिन ${trainingDays.last.number} की क्विज़ पास करें।');
                return;
              }
              _open(context, const PracticalChecklistScreen());
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        child: AppButton(
          label: next.label,
          icon: next.icon,
          onPressed: () => _open(context, next.screen),
        ),
      ),
    );
  }

  static String _daySubtitle(TrainingProgress p, TrainingDay day) {
    final read = lessonsReadIn(p, day);
    final best = p.quizBest[day.id];
    final parts = <String>[
      'पाठ पढ़े: $read/${day.lessons.length}',
      best == null ? 'क्विज़ बाकी' : 'क्विज़: $best%',
    ];
    return parts.join(' · ');
  }
}

/// नीचे वाले बटन का अगला काम।
class _NextStep {
  const _NextStep(this.label, this.icon, this.screen);

  final String label;
  final IconData icon;
  final Widget screen;
}

/// ट्रेनिंग पूरी होने पर सबसे ऊपर हरा कार्ड।
class _CertifiedCard extends StatelessWidget {
  const _CertifiedCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      color: AppColors.successSoft,
      borderColor: AppColors.success,
      child: const Row(
        children: [
          NumberBadge(icon: Icons.workspace_premium, background: AppColors.success, size: 52),
          SizedBox(width: AppSpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'आप प्रशिक्षित टेक्नीशियन हैं',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.success, height: 1.3),
                ),
                SizedBox(height: AppSpace.xs),
                Text('सर्टिफ़िकेट देखें और मालिक को रिपोर्ट भेजें', style: AppText.small),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.success),
        ],
      ),
    );
  }
}

/// कुल प्रगति: पट्टी और तीन गिनतियाँ।
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.progress});

  final TrainingProgress progress;

  @override
  Widget build(BuildContext context) {
    final p = progress;
    final value = overallProgress(p);
    final percent = (value * 100).round();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Text('आपकी प्रगति', style: AppText.h3)),
              Text('$percent%', style: AppText.price),
            ],
          ),
          const SizedBox(height: AppSpace.s),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor: AppColors.primarySoft,
              color: p.isCertified ? AppColors.success : AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpace.l),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _Stat(value: '${lessonsDone(p)}/$totalLessons', label: 'पाठ पढ़े')),
              Expanded(child: _Stat(value: '${daysPassed(p)}/${trainingDays.length}', label: 'दिन पास')),
              Expanded(
                child: _Stat(value: '${practicalDoneCount(p)}/${practicalItems.length}', label: 'फ़ील्ड के काम'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
        ),
        const SizedBox(height: 2),
        Text(label, textAlign: TextAlign.center, style: AppText.small),
      ],
    );
  }
}

/// "ऐसे सीखें": रोज़ का क्रम।
class _HowToLearnCard extends StatelessWidget {
  const _HowToLearnCard();

  @override
  Widget build(BuildContext context) {
    const steps = [
      (Icons.menu_book, 'रोज़ सुबह उस दिन के पाठ पढ़ें। हर पाठ 3–5 मिनट का है।'),
      (
        Icons.quiz_outlined,
        'शाम को क्विज़ दें। ${AppConfig.quizPassPercent}% पर पास (सुरक्षा वाले दिन 100%)। जितनी बार चाहें दोबारा दें।'
      ),
      (Icons.engineering, 'मालिक या सीनियर के साथ फ़ील्ड में वही काम देखें। ऐप किताब है, हुनर छत पर आता है।'),
    ];
    return AppCard(
      color: AppColors.sunSoft,
      borderColor: AppColors.sun,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ऐसे सीखें', style: AppText.h3),
          const SizedBox(height: AppSpace.s),
          for (var i = 0; i < steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(top: AppSpace.s),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NumberBadge(label: '${i + 1}', background: AppColors.sun, size: 32),
                  const SizedBox(width: AppSpace.m),
                  Expanded(child: Text(steps[i].$2, style: AppText.body)),
                  const SizedBox(width: AppSpace.s),
                  Icon(steps[i].$1, color: AppColors.warning, size: 22),
                ],
              ),
            ),
          const SizedBox(height: AppSpace.m),
          const Text('अगले दिन के पाठ तभी खुलेंगे जब पिछले दिन की क्विज़ पास हो।', style: AppText.small),
        ],
      ),
    );
  }
}

/// एक दिन का कार्ड।
class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.onTap,
  });

  final int number;
  final String title;
  final String subtitle;
  final DayStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locked = status == DayStatus.locked;
    final badge = switch (status) {
      DayStatus.done => const NumberBadge(icon: Icons.check, background: AppColors.success),
      DayStatus.open => NumberBadge(label: '$number'),
      DayStatus.locked => const NumberBadge(
          icon: Icons.lock_outline,
          background: AppColors.border,
          foreground: AppColors.textMuted,
        ),
    };
    return AppCard(
      onTap: onTap,
      color: locked ? AppColors.background : AppColors.card,
      borderColor: status == DayStatus.open ? AppColors.primary : AppColors.border,
      child: Row(
        children: [
          badge,
          const SizedBox(width: AppSpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('दिन $number', style: AppText.small),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: AppText.h3.copyWith(color: locked ? AppColors.textMuted : AppColors.text),
                ),
                const SizedBox(height: AppSpace.xs),
                Text(subtitle, style: AppText.small),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.s),
          DayStatusChip(status),
        ],
      ),
    );
  }
}
