import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:nischint_core/app/app_scope.dart';
import 'package:nischint_core/app/theme.dart';
import 'package:nischint_core/content/config.dart';
import 'package:nischint_core/widgets/common.dart';

import '../../training/curriculum.dart';
import '../../training/training_rules.dart';
import 'certificate_screen.dart';
import 'widgets/training_bits.dart';

/// दिन 6: फ़ील्ड ट्रायल। हर काम मालिक/सीनियर सुपरवाइज़र कोड डालकर पास (या वापस) करते हैं।
/// सारे काम + सारी क्विज़ पास होने पर "ट्रेनिंग पूरी करें"।
class PracticalChecklistScreen extends StatefulWidget {
  const PracticalChecklistScreen({super.key});

  @override
  State<PracticalChecklistScreen> createState() => _PracticalChecklistScreenState();
}

class _PracticalChecklistScreenState extends State<PracticalChecklistScreen> {
  bool _busy = false;

  Future<void> _toggle(PracticalItem item, bool currentlyDone) async {
    final app = AppScope.read(context);
    if (app.training.isCertified) {
      showMessage(context, 'ट्रेनिंग पूरी हो चुकी है। बदलाव के लिए सेटिंग से ट्रेनिंग दोबारा शुरू करें।');
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _SupervisorCodeDialog(item: item, unmark: currentlyDone),
    );
    if (ok != true) return;
    if (!mounted) return;
    setState(() => _busy = true);
    await app.setPracticalDone(item.id, !currentlyDone);
    if (!mounted) return;
    setState(() => _busy = false);
    showMessage(context, currentlyDone ? 'यह काम वापस "बाकी" में डाल दिया' : 'शाबाश! यह काम पास हो गया');
  }

  Future<void> _certify() async {
    final app = AppScope.read(context);
    if (!canCertify(app.training)) return;
    setState(() => _busy = true);
    await app.certifyTraining();
    if (!mounted) return;
    setState(() => _busy = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const CertificateScreen()),
    );
  }

  void _openCertificate() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const CertificateScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = AppScope.of(context).training;
    final doneCount = practicalDoneCount(p);
    final quizzesOk = allQuizzesPassed(p);
    final allDone = allPracticalDone(p);

    final String label;
    final VoidCallback? onPressed;
    if (p.isCertified) {
      label = 'सर्टिफ़िकेट देखें';
      onPressed = _openCertificate;
    } else if (!allDone) {
      label = '${practicalItems.length} में से $doneCount काम पास हुए';
      onPressed = null;
    } else if (!quizzesOk) {
      label = 'पहले दिन 1–${trainingDays.length} की सारी क्विज़ पास करें';
      onPressed = null;
    } else {
      label = 'ट्रेनिंग पूरी करें';
      onPressed = _busy ? null : _certify;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('दिन $fieldTrialDayNumber — फ़ील्ड ट्रायल')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.l, AppSpace.l, AppSpace.xl),
        children: [
          const Text(fieldTrialTitle, style: AppText.h1),
          const SizedBox(height: AppSpace.m),
          const LessonBox(
            title: '🎯 आज क्या होगा',
            background: AppColors.primarySoft,
            foreground: AppColors.primaryDark,
            text: fieldTrialGoal,
          ),
          const SizedBox(height: AppSpace.m),
          const InfoBanner(
            tone: ChipTone.warning,
            icon: Icons.lock_outline,
            title: 'सुपरवाइज़र कोड',
            text: 'कोड सिर्फ़ मालिक या सीनियर डालेंगे। काम ठीक लगे तभी वे उसे पास करेंगे। '
                'ग़लती से पास हो जाए तो वे उसी कोड से वापस भी कर सकते हैं।',
          ),
          if (!quizzesOk && !p.isCertified) ...[
            const SizedBox(height: AppSpace.m),
            const InfoBanner(
              tone: ChipTone.danger,
              icon: Icons.quiz_outlined,
              text: 'सर्टिफ़िकेट के लिए दिन 1 से 5 तक की सारी क्विज़ पास होनी चाहिए।',
            ),
          ],
          SectionHeader(
            'ट्रायल के 7 काम',
            trailing: Text('$doneCount/${practicalItems.length} पास', style: AppText.muted),
          ),
          for (var i = 0; i < practicalItems.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.m),
              child: _PracticalCard(
                number: i + 1,
                item: practicalItems[i],
                done: p.practicalDone.contains(practicalItems[i].id),
                locked: p.isCertified,
                onToggle: _busy
                    ? null
                    : () => _toggle(practicalItems[i], p.practicalDone.contains(practicalItems[i].id)),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        child: AppButton(
          label: label,
          icon: p.isCertified ? Icons.workspace_premium : Icons.verified_outlined,
          color: (allDone && quizzesOk) ? AppColors.success : null,
          onPressed: onPressed,
        ),
      ),
    );
  }
}

/// ट्रायल का एक काम।
class _PracticalCard extends StatelessWidget {
  const _PracticalCard({
    required this.number,
    required this.item,
    required this.done,
    required this.locked,
    required this.onToggle,
  });

  final int number;
  final PracticalItem item;
  final bool done;
  final bool locked;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderColor: done ? AppColors.success : AppColors.border,
      color: done ? AppColors.successSoft : AppColors.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              done
                  ? const NumberBadge(icon: Icons.check, background: AppColors.success, size: 36)
                  : NumberBadge(label: '$number', size: 36),
              const SizedBox(width: AppSpace.m),
              Expanded(child: Text(item.title, style: AppText.h3)),
            ],
          ),
          const SizedBox(height: AppSpace.s),
          Text('कैसे जाँचें: ${item.howToCheck}', style: AppText.body),
          const SizedBox(height: AppSpace.m),
          Row(
            children: [
              Expanded(
                child: done
                    ? const Align(
                        alignment: Alignment.centerLeft,
                        child: StatusChip('पास (सुपरवाइज़र)', tone: ChipTone.success),
                      )
                    : const Align(
                        alignment: Alignment.centerLeft,
                        child: StatusChip('बाकी'),
                      ),
              ),
              if (!locked)
                done
                    ? TextButton(onPressed: onToggle, child: const Text('वापस करें'))
                    : FilledButton.icon(
                        onPressed: onToggle,
                        icon: const Icon(Icons.verified_outlined, size: 18),
                        label: const Text('पास करें'),
                      ),
            ],
          ),
        ],
      ),
    );
  }
}

/// सुपरवाइज़र कोड माँगने वाला डायलॉग। सही कोड पर true लौटाता है।
class _SupervisorCodeDialog extends StatefulWidget {
  const _SupervisorCodeDialog({required this.item, required this.unmark});

  final PracticalItem item;

  /// true = पास किया हुआ काम वापस "बाकी" करना।
  final bool unmark;

  @override
  State<_SupervisorCodeDialog> createState() => _SupervisorCodeDialogState();
}

class _SupervisorCodeDialogState extends State<_SupervisorCodeDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'कोड डालें');
      return;
    }
    if (code != AppConfig.supervisorPin) {
      setState(() => _error = 'कोड ग़लत है। सिर्फ़ मालिक या सीनियर ही सही कोड डालें।');
      _controller.clear();
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.unmark ? 'काम वापस "बाकी" करें?' : 'सुपरवाइज़र कोड डालें'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.item.title, style: AppText.h3),
            const SizedBox(height: AppSpace.s),
            Text(
              widget.unmark
                  ? 'इसे वापस करने के लिए मालिक/सीनियर अपना कोड डालें।'
                  : 'मालिक/सीनियर: काम ठीक हुआ हो तभी अपना कोड डालकर पास करें।',
              style: AppText.muted,
            ),
            const SizedBox(height: AppSpace.l),
            TextField(
              controller: _controller,
              autofocus: true,
              obscureText: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [LengthLimitingTextInputFormatter(12)],
              style: const TextStyle(fontSize: 22, letterSpacing: 6, color: AppColors.text),
              decoration: InputDecoration(
                labelText: 'सुपरवाइज़र कोड',
                errorText: _error,
                errorMaxLines: 3,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('रद्द करें'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.unmark ? 'वापस करें' : 'पास करें'),
        ),
      ],
    );
  }
}
