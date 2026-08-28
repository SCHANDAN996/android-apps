import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_language.dart';
import '../data/land_units.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String _selectedState = standardStateKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return ValueListenableBuilder<AppLang>(
      valueListenable: LanguageNotifier.instance,
      builder: (context, lang, _) {
        final strings = AppStrings(lang);

        // Localized text translations for onboarding
        final Map<AppLang, String> welcomeTexts = {
          AppLang.english: 'Welcome to Jameen Napi',
          AppLang.hindi: 'जमीन नापी ऐप में आपका स्वागत है',
          AppLang.marathi: 'जमीन नापी ॲपमध्ये आपले स्वागत आहे',
          AppLang.gujarati: 'જમીન નાપી એપમાં તમારું સ્વાગત છે',
          AppLang.punjabi: 'ਜ਼ਮੀਨ ਨਾਪੀ ਐਪ ਵਿੱਚ ਤੁਹਾਡਾ ਸਵਾਗਤ ਹੈ',
          AppLang.bengali: 'জমি নাপি অ্যাপে আপনাকে স্বাগত জানাই',
          AppLang.telugu: 'జమీన్ నాపి యాప్‌కు స్వాగతం',
          AppLang.tamil: 'ஜமீன் நாபி செயலிக்கு உங்களை வரவேற்கிறோம்',
          AppLang.kannada: 'ಜಮೀನ್ ನಾಪಿ ಆಪ್‌ಗೆ ಸುಸ್ವಾಗತ',
        };

        final Map<AppLang, String> selectLangTexts = {
          AppLang.english: 'Choose Language',
          AppLang.hindi: 'अपनी भाषा चुनें',
          AppLang.marathi: 'आपली भाषा निवडा',
          AppLang.gujarati: 'તમારી ભાષા પસંદ કરો',
          AppLang.punjabi: 'ਆਪਣੀ ਭਾਸ਼ਾ ਚੁਣੋ',
          AppLang.bengali: 'আপনার ভাষা চয়ন করুন',
          AppLang.telugu: 'మీ భాషను ఎంచుకోండి',
          AppLang.tamil: 'உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்',
          AppLang.kannada: 'ನಿಮ್ಮ ಭಾಷೆಯನ್ನು ಆರಿಸಿ',
        };

        final Map<AppLang, String> selectStateTexts = {
          AppLang.english: 'Choose State / Region',
          AppLang.hindi: 'अपना राज्य चुनें',
          AppLang.marathi: 'आपले राज्य निवडा',
          AppLang.gujarati: 'તમારું રાજ્ય પસંદ કરો',
          AppLang.punjabi: 'ਆਪਣਾ ਰਾਜ ਚੁਣੋ',
          AppLang.bengali: 'আপনার রাজ্য চয়ন করুন',
          AppLang.telugu: 'మీ రాష్ట్రాన్ని ఎంచుకోండి',
          AppLang.tamil: 'உங்கள் மாநிலத்தைத் தேர்ந்தெடுக்கவும்',
          AppLang.kannada: 'ನಿಮ್ಮ ರಾಜ್ಯವನ್ನು ಆರಿಸಿ',
        };

        final Map<AppLang, String> startButtonTexts = {
          AppLang.english: 'Get Started',
          AppLang.hindi: 'शुरू करें',
          AppLang.marathi: 'सुरू करा',
          AppLang.gujarati: 'શરૂ કરો',
          AppLang.punjabi: 'ਸ਼ੁਰੂ ਕਰੋ',
          AppLang.bengali: 'শুরু করুন',
          AppLang.telugu: 'ప్రారంభించండి',
          AppLang.tamil: 'தொடங்கவும்',
          AppLang.kannada: 'ಪ್ರಾರಂಭಿಸಿ',
        };

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE8F5E9), Color(0xFFF5F7F5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - 64,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Header Logo & Greeting
                      Column(
                        children: [
                          const SizedBox(height: 32),
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1B5E20).withValues(alpha: 0.25),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.asset(
                                'assets/icon/icon.png',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            strings.appTitle,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1B5E20),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            welcomeTexts[lang] ?? welcomeTexts[AppLang.hindi]!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),

                      // Selectors Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.shade100, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Language Selection
                            Text(
                              selectLangTexts[lang] ?? selectLangTexts[AppLang.hindi]!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<AppLang>(
                              initialValue: lang,
                              isExpanded: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                                ),
                                prefixIcon: const Icon(Icons.language, color: Color(0xFF2E7D32)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              items: AppStrings.languageNames.entries.map((e) {
                                return DropdownMenuItem(
                                  value: e.key,
                                  child: Text(e.value),
                                );
                              }).toList(),
                              onChanged: (newLang) {
                                if (newLang != null) {
                                  LanguageNotifier.instance.setLanguage(newLang);
                                }
                              },
                            ),
                            const SizedBox(height: 24),

                            // State Selection
                            Text(
                              selectStateTexts[lang] ?? selectStateTexts[AppLang.hindi]!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedState,
                              isExpanded: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                                ),
                                prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF2E7D32)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: standardStateKey,
                                  child: Text(strings.stateDisplayName(standardStateKey)),
                                ),
                                ...stateUnits.keys.map(
                                  (s) => DropdownMenuItem(value: s, child: Text(strings.stateDisplayName(s))),
                                ),
                              ],
                              onChanged: (newState) {
                                if (newState != null) {
                                  setState(() {
                                    _selectedState = newState;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),

                      // Get Started Action Button
                      Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1B5E20).withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _completeOnboarding,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                startButtonTexts[lang] ?? startButtonTexts[AppLang.hindi]!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('converter_last_state', _selectedState);
      // भाषा dropdown में जो दिख रही है वही पक्की कर दें — भले user ने उसे
      // छुआ न हो (वो फोन की भाषा से अपने आप चुनी गई हो सकती है)।
      await prefs.setString(
          LanguageNotifier.prefKey, LanguageNotifier.instance.value.name);
      await prefs.setBool('is_onboarding_completed', true);
      
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (_) {}
  }
}
