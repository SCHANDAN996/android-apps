import 'package:flutter/material.dart';

import 'package:nischint_core/app/app_scope.dart';
import 'package:nischint_core/app/theme.dart';
import 'package:nischint_core/content/config.dart';
import 'package:nischint_core/services/contact_service.dart';
import 'package:nischint_core/utils/format.dart';
import 'package:nischint_core/widgets/common.dart';

import '../../training/curriculum.dart';
import '../../training/training_rules.dart';
import 'widgets/training_bits.dart';

/// "प्रशिक्षित टेक्नीशियन" सर्टिफ़िकेट और मालिक को WhatsApp रिपोर्ट।
class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  bool _sending = false;

  Future<void> _sendReport() async {
    final app = AppScope.read(context);
    setState(() => _sending = true);
    final opened = await ContactService.whatsApp(trainingReportMessage(app.technician, app.training));
    if (!mounted) return;
    setState(() => _sending = false);
    if (!opened) showMessage(context, whatsAppFailedMessage);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = app.technician;
    final p = app.training;
    final certifiedAt = p.certifiedAt;

    if (certifiedAt == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('सर्टिफ़िकेट')),
        body: const EmptyState(
          icon: Icons.workspace_premium,
          title: 'अभी सर्टिफ़िकेट नहीं मिला',
          message: 'सारी क्विज़ और फ़ील्ड ट्रायल के 7 काम पास होने पर यहाँ आपका सर्टिफ़िकेट दिखेगा।',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('सर्टिफ़िकेट')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.l, AppSpace.l, AppSpace.xl),
        children: [
          // बाहरी सुनहरी पट्टी + अंदर सफ़ेद, ताकि सर्टिफ़िकेट जैसा दिखे।
          Container(
            padding: const EdgeInsets.all(AppSpace.s),
            decoration: BoxDecoration(
              color: AppColors.sunSoft,
              borderRadius: BorderRadius.circular(AppSpace.radius),
              border: Border.all(color: AppColors.sun, width: 2),
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.xl, AppSpace.l, AppSpace.xl),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSpace.radius - 4),
                border: Border.all(color: AppColors.sun.withAlpha(120)),
              ),
              child: Column(
                children: [
                  const NumberBadge(icon: Icons.workspace_premium, background: AppColors.sun, size: 72),
                  const SizedBox(height: AppSpace.m),
                  const Text(
                    AppConfig.appName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: AppSpace.xs),
                  const Text(
                    'प्रशिक्षित टेक्नीशियन',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.text, height: 1.3),
                  ),
                  const SizedBox(height: AppSpace.l),
                  const Text('यह प्रमाणित किया जाता है कि', textAlign: TextAlign.center, style: AppText.muted),
                  const SizedBox(height: AppSpace.s),
                  Text(
                    t.name.trim().isEmpty ? '—' : t.name.trim(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: AppSpace.xs),
                  Text('मोबाइल: ${t.mobile.isEmpty ? '—' : t.mobile}', textAlign: TextAlign.center, style: AppText.body),
                  const SizedBox(height: AppSpace.m),
                  const Text(
                    'ने 6 दिन की ट्रेनिंग, सारी क्विज़ और मालिक के सामने फ़ील्ड ट्रायल पास किया है।',
                    textAlign: TextAlign.center,
                    style: AppText.body,
                  ),
                  const SizedBox(height: AppSpace.l),
                  const Divider(),
                  const SizedBox(height: AppSpace.s),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('क्विज़ के स्कोर', style: AppText.h3),
                  ),
                  const SizedBox(height: AppSpace.xs),
                  for (final d in trainingDays)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpace.xs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 56, child: Text('दिन ${d.number}', style: AppText.muted)),
                          Expanded(child: Text(d.title, style: AppText.body)),
                          const SizedBox(width: AppSpace.s),
                          Text(
                            '${p.quizBest[d.id] ?? 0}%',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpace.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 56, child: Text('दिन $fieldTrialDayNumber', style: AppText.muted)),
                        const Expanded(child: Text('फ़ील्ड ट्रायल', style: AppText.body)),
                        const SizedBox(width: AppSpace.s),
                        Text(
                          '${practicalDoneCount(p)}/${practicalItems.length}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.success),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpace.s),
                  const Divider(),
                  const SizedBox(height: AppSpace.s),
                  Text(
                    'तारीख: ${hindiDateYear(certifiedAt)}',
                    textAlign: TextAlign.center,
                    style: AppText.h3,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpace.l),
          const InfoBanner(
            icon: Icons.photo_camera_outlined,
            title: 'आगे क्या',
            text: 'पहले 10 काम मालिक की निगरानी में होंगे — हर काम की फ़ोटो मालिक देखेंगे। '
                'ग़लती हो तो वही पाठ दोबारा पढ़ना होगा।',
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        child: AppButton(
          label: _sending ? 'WhatsApp खुल रहा है…' : 'मालिक को रिपोर्ट भेजें',
          icon: Icons.send,
          onPressed: _sending ? null : _sendReport,
        ),
      ),
    );
  }
}
