import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kaajo_core/app/app_scope.dart';
import 'package:kaajo_core/app/app_state.dart';
import 'package:kaajo_core/app/theme.dart';
import 'package:kaajo_core/content/config.dart';

import 'app/shells.dart';
import 'screens/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  runApp(KaajoApp(state: state));
  state.load();
}

/// ग्राहक ऐप: काजो
class KaajoApp extends StatelessWidget {
  const KaajoApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        locale: const Locale('hi', 'IN'),
        supportedLocales: const [Locale('hi', 'IN'), Locale('en', 'IN')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const RootGate(),
      ),
    );
  }
}

/// पहली बार ऑनबोर्डिंग, उसके बाद होम।
class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    if (!app.loaded) return const SplashView();
    if (!app.onboarded) return const OnboardingScreen();
    return const CustomerShell();
  }
}

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: AppColors.sun, shape: BoxShape.circle),
              child: const Icon(Icons.bolt_rounded, size: 48, color: Colors.white),
            ),
            const SizedBox(height: AppSpace.l),
            const Text(
              AppConfig.appName,
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: AppSpace.s),
            const Text(AppConfig.tagline, style: TextStyle(fontSize: 16, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
