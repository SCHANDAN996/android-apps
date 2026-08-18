import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/app_cubit.dart';
import '../data/india_states.dart';
import '../l10n/app_localizations.dart';
import 'theme/dairy_theme.dart';

import '../services/backup_service.dart';
import '../blocs/backup_cubit.dart';

/// First-run onboarding: language → state. बस दो step।
///
/// पहले तीसरा step था — "आप दूध के साथ क्या करते हैं?" (बेचते/ख़रीदते/दोनों)।
/// हटा दिया: ग्राहक जोड़ते समय ख़रीदार/आपूर्तिकर्ता चुनते ही हैं और एंट्री
/// करते समय बेचना/ख़रीदना — शुरुआत में यह सवाल सिर्फ़ भ्रम बढ़ाता था।
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  String _stateQuery = '';
  Map<String, dynamic>? _detectedBackup;

  String _t(String k) => AppLocalizations.get(context, k);

  @override
  void initState() {
    super.initState();
    _checkBackup();
  }

  Future<void> _checkBackup() async {
    final backup = await BackupService().detectExistingBackup();
    if (mounted && backup != null) {
      setState(() {
        _detectedBackup = backup;
      });
    }
  }

  void _finish() async {
    final cubit = context.read<AppCubit>();
    await cubit.setOccupations(const ['dudh', 'pashu', 'kheti']);
    await cubit.completeFirstRun();
    if (mounted) Navigator.pushReplacementNamed(context, '/shell');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _StepDots(current: _step, total: 2),
            Expanded(child: _buildStep()),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    if (_step == 0) {
      return _languageStep();
    }
    return _stateStep();
  }

  // All 10 supported languages — order: Hindi, Bhojpuri, English, then the rest.
  // Each: code, name in its own script, English subtitle.
  static const List<List<String>> _languages = [
    ['hi', 'हिंदी', 'Hindi'],
    ['bho', 'भोजपुरी', 'Bhojpuri'],
    ['en', 'English', 'अंग्रेज़ी'],
    ['bn', 'বাংলা', 'Bengali'],
    ['mr', 'मराठी', 'Marathi'],
    ['pa', 'ਪੰਜਾਬੀ', 'Punjabi'],
    ['gu', 'ગુજરાતી', 'Gujarati'],
    ['te', 'తెలుగు', 'Telugu'],
    ['ta', 'தமிழ்', 'Tamil'],
    ['kn', 'ಕನ್ನಡ', 'Kannada'],
  ];

  // ---------- Step 0: Language ----------
  Widget _languageStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: DairyTheme.primaryTeal.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/icon/app_icon.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.agriculture_rounded,
                size: 48,
                color: DairyTheme.primaryTeal,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Pro Kisan',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: DairyTheme.primaryTeal,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select Your Language',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        if (_detectedBackup != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Card(
              color: Colors.teal.shade50,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.find_in_page_rounded, color: DairyTheme.primaryTeal, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _t('backupFoundTitle'),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: DairyTheme.primaryTeal),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _t('backupFoundDesc'),
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade800, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final ok = await context.read<BackupCubit>().runAutoDetectRestore();
                          if (mounted && ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(_t('restoreSuccessAlert'))),
                            );
                            _finish();
                          }
                        },
                        icon: const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
                        label: Text(_t('restoreOneClickBtn'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DairyTheme.primaryTeal,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 14),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _languages.length,
            itemBuilder: (context, i) {
              final l = _languages[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _langCard(l[1], l[2], () => _pickLanguage(l[0])),
              );
            },
          ),
        ),
      ],
    );
  }

  void _pickLanguage(String lang) async {
    await context.read<AppCubit>().setLanguage(lang);
    if (mounted) setState(() => _step = 1);
  }

  Widget _langCard(String title, String sub, VoidCallback onTap) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          child: Row(
            children: [
              const Icon(Icons.translate_rounded, color: DairyTheme.primaryTeal),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  Text(sub, style: const TextStyle(fontSize: 13, color: DairyTheme.textLight)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: DairyTheme.textLight),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Step 1: State ----------
  Widget _stateStep() {
    final filtered = kIndiaStates.where((s) {
      final q = _stateQuery.trim().toLowerCase();
      if (q.isEmpty) return true;
      return s.hi.contains(q) || s.en.toLowerCase().contains(q);
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_t('selectState'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(_t('stateHint'),
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: _t('searchState'),
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => _stateQuery = v),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final s = filtered[i];
                return ListTile(
                  title: Text(s.hi, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(s.en),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _pickState(s.code),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _pickState(String code) async {
    await context.read<AppCubit>().setStateCode(code);
    // राज्य चुनते ही onboarding पूरा — अब कोई तीसरा सवाल नहीं
    _finish();
  }
}

class _StepDots extends StatelessWidget {
  final int current;
  final int total;
  const _StepDots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (i) {
          final active = i <= current;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 26 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: active ? DairyTheme.primaryTeal : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(5),
            ),
          );
        }),
      ),
    );
  }
}
