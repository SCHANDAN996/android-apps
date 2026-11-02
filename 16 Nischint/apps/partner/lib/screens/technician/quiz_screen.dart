import 'package:flutter/material.dart';

import 'package:nischint_core/app/app_scope.dart';
import 'package:nischint_core/app/theme.dart';
import 'package:nischint_core/widgets/common.dart';

import '../../app/shells.dart';
import '../../training/curriculum.dart';
import 'widgets/training_bits.dart';

/// विकल्पों के आगे लिखे अक्षर।
const List<String> _optionLetters = ['क', 'ख', 'ग', 'घ', 'ङ', 'च'];

/// दिन की क्विज़: एक बार में एक सवाल। जवाब पक्का करते ही सही/ग़लत और वजह दिखती है।
/// आख़िर में स्कोर, पास/फ़ेल, और दोबारा देने का बटन।
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.dayId});

  final String dayId;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _index = 0;
  int? _selected;
  bool _checked = false;
  int _correct = 0;

  bool _finished = false;
  int _percent = 0;
  bool _saving = false;

  void _select(int i) {
    if (_checked) return;
    setState(() => _selected = i);
  }

  void _check(QuizQuestion q) {
    final selected = _selected;
    if (selected == null || _checked) return;
    setState(() {
      _checked = true;
      if (selected == q.correctIndex) _correct++;
    });
  }

  Future<void> _next(TrainingDay day) async {
    if (_index + 1 < day.quiz.length) {
      setState(() {
        _index++;
        _selected = null;
        _checked = false;
      });
      return;
    }
    // आख़िरी सवाल: नतीजा।
    final total = day.quiz.length;
    final percent = total == 0 ? 0 : (_correct * 100 / total).round();
    setState(() {
      _finished = true;
      _percent = percent;
      _saving = true;
    });
    await AppScope.read(context).saveQuizScore(day.id, percent);
    if (!mounted) return;
    setState(() => _saving = false);
  }

  void _retry() {
    setState(() {
      _index = 0;
      _selected = null;
      _checked = false;
      _correct = 0;
      _finished = false;
      _percent = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final day = dayById(widget.dayId);
    if (day == null || day.quiz.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('क्विज़')),
        body: const EmptyState(
          icon: Icons.quiz_outlined,
          title: 'यह क्विज़ नहीं मिली',
          message: 'वापस जाकर ट्रेनिंग की सूची से दिन चुनें।',
        ),
      );
    }
    return _finished ? _buildResult(context, day) : _buildQuestion(context, day);
  }

  // ---------------------------------------------------------------- सवाल

  Widget _buildQuestion(BuildContext context, TrainingDay day) {
    final q = day.quiz[_index];
    final total = day.quiz.length;
    final selected = _selected;
    final isRight = _checked && selected == q.correctIndex;
    final isLast = _index + 1 >= total;

    final String buttonLabel;
    final VoidCallback? onPressed;
    if (!_checked) {
      buttonLabel = selected == null ? 'पहले एक जवाब चुनें' : 'जवाब पक्का करें';
      onPressed = selected == null ? null : () => _check(q);
    } else {
      buttonLabel = isLast ? 'नतीजा देखें' : 'अगला सवाल';
      onPressed = () => _next(day);
    }

    return Scaffold(
      appBar: AppBar(title: Text('दिन ${day.number} की क्विज़')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.l, AppSpace.l, AppSpace.xl),
        children: [
          Row(
            children: [
              Expanded(child: Text('सवाल ${_index + 1} / $total', style: AppText.h3)),
              Text('सही: $_correct', style: AppText.muted),
            ],
          ),
          const SizedBox(height: AppSpace.s),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_index + (_checked ? 1 : 0)) / total,
              minHeight: 8,
              backgroundColor: AppColors.primarySoft,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpace.xl),
          Text(
            q.question,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: AppColors.text, height: 1.4),
          ),
          const SizedBox(height: AppSpace.l),
          for (var i = 0; i < q.options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.m),
              child: _OptionCard(
                letter: i < _optionLetters.length ? _optionLetters[i] : '${i + 1}',
                text: q.options[i],
                state: _optionState(i, q),
                onTap: _checked ? null : () => _select(i),
              ),
            ),
          if (_checked) ...[
            const SizedBox(height: AppSpace.s),
            InfoBanner(
              tone: isRight ? ChipTone.success : ChipTone.danger,
              icon: isRight ? Icons.check_circle : Icons.cancel,
              title: isRight ? 'सही जवाब! शाबाश' : 'ग़लत जवाब',
              text: isRight ? q.explanation : 'सही जवाब: ${q.correctOption}\n\n${q.explanation}',
            ),
          ],
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        child: AppButton(
          label: buttonLabel,
          icon: _checked ? Icons.arrow_forward : Icons.check,
          onPressed: onPressed,
        ),
      ),
    );
  }

  _OptionState _optionState(int i, QuizQuestion q) {
    if (!_checked) return i == _selected ? _OptionState.selected : _OptionState.normal;
    if (i == q.correctIndex) return _OptionState.correct;
    if (i == _selected) return _OptionState.wrong;
    return _OptionState.dimmed;
  }

  // ---------------------------------------------------------------- नतीजा

  Widget _buildResult(BuildContext context, TrainingDay day) {
    final total = day.quiz.length;
    final pass = passPercentFor(day.id);
    final passed = _percent >= pass;
    final best = AppScope.of(context).training.quizBest[day.id];
    final isLastDay = day.id == trainingDays.last.id;
    final color = passed ? AppColors.success : AppColors.danger;
    final soft = passed ? AppColors.successSoft : AppColors.dangerSoft;

    final String message;
    if (passed) {
      message = isLastDay
          ? 'अब फ़ील्ड ट्रायल खुल गया है — मालिक के सामने असली काम।'
          : 'दिन ${day.number + 1} के पाठ खुल गए हैं।';
    } else {
      message = 'पास होने के लिए कम से कम $pass% चाहिए। पाठ दोबारा पढ़ें और फिर से क्विज़ दें — '
          'जितनी बार चाहें।';
    }

    return Scaffold(
      appBar: AppBar(title: Text('दिन ${day.number} का नतीजा')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.xl, AppSpace.l, AppSpace.xl),
        children: [
          Center(
            child: Container(
              width: 150,
              height: 150,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: soft,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 4),
              ),
              child: Text(
                '$_percent%',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: color),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.l),
          Text(
            passed ? 'पास! शाबाश 🎉' : 'अभी पास नहीं',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color, height: 1.3),
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            '$total में से ${_correct.clamp(0, total)} सही',
            textAlign: TextAlign.center,
            style: AppText.h3,
          ),
          const SizedBox(height: AppSpace.l),
          InfoBanner(
            tone: passed ? ChipTone.success : ChipTone.warning,
            icon: passed ? Icons.lock_open : Icons.refresh,
            text: message,
          ),
          if (pass >= 100) ...[
            const SizedBox(height: AppSpace.m),
            const InfoBanner(
              tone: ChipTone.danger,
              icon: Icons.health_and_safety_outlined,
              title: 'सुरक्षा में 100% ज़रूरी',
              text: 'सुरक्षा में "लगभग सही" नहीं चलता। एक भी ग़लती छत पर हादसा बन सकती है, इसलिए हर सवाल सही होना चाहिए।',
            ),
          ],
          if (best != null) ...[
            const SizedBox(height: AppSpace.l),
            Text('आपका सबसे अच्छा स्कोर: $best%', textAlign: TextAlign.center, style: AppText.muted),
          ],
          const SizedBox(height: AppSpace.l),
          Center(
            child: passed
                ? TextButton.icon(
                    onPressed: _saving ? null : _retry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('क्विज़ दोबारा दें'),
                  )
                : TextButton.icon(
                    onPressed: _saving ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.menu_book),
                    label: const Text('पाठ दोबारा पढ़ें'),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        child: passed
            ? AppButton(
                label: _saving ? 'सेव हो रहा है…' : 'ट्रेनिंग पर वापस जाएँ',
                icon: Icons.school,
                onPressed: _saving ? null : () => ShellNav.goToTab(context, 0),
              )
            : AppButton(
                label: _saving ? 'सेव हो रहा है…' : 'क्विज़ दोबारा दें',
                icon: Icons.refresh,
                onPressed: _saving ? null : _retry,
              ),
      ),
    );
  }
}

enum _OptionState { normal, selected, correct, wrong, dimmed }

/// एक विकल्प: दबाने लायक बड़ा कार्ड।
class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.letter,
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String letter;
  final String text;
  final _OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color border, Color fg) = switch (state) {
      _OptionState.normal => (AppColors.card, AppColors.border, AppColors.text),
      _OptionState.selected => (AppColors.primarySoft, AppColors.primary, AppColors.primaryDark),
      _OptionState.correct => (AppColors.successSoft, AppColors.success, AppColors.success),
      _OptionState.wrong => (AppColors.dangerSoft, AppColors.danger, AppColors.danger),
      _OptionState.dimmed => (AppColors.card, AppColors.border, AppColors.textMuted),
    };
    final IconData? trailing = switch (state) {
      _OptionState.correct => Icons.check_circle,
      _OptionState.wrong => Icons.cancel,
      _OptionState.selected => Icons.radio_button_checked,
      _OptionState.normal => Icons.radio_button_unchecked,
      _OptionState.dimmed => null,
    };
    final strong = state == _OptionState.selected || state == _OptionState.correct || state == _OptionState.wrong;

    return AppCard(
      onTap: onTap,
      color: bg,
      borderColor: border,
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.l, vertical: AppSpace.m),
      child: Row(
        children: [
          NumberBadge(
            label: letter,
            size: 34,
            background: strong ? border : AppColors.background,
            foreground: strong ? Colors.white : AppColors.textMuted,
          ),
          const SizedBox(width: AppSpace.m),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18,
                height: 1.4,
                color: fg,
                fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpace.s),
            Icon(trailing, color: strong ? border : AppColors.textMuted),
          ],
        ],
      ),
    );
  }
}
