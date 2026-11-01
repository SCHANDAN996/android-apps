import 'package:flutter/material.dart';

import 'app/app_scope.dart';
import 'app/app_state.dart';
import 'app/shells.dart';
import 'app/theme.dart';
import 'content/config.dart';
import 'models/profiles.dart';
import 'screens/onboarding_screen.dart';
import 'screens/vendor/vendor_profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  runApp(NischintApp(state: state));
  state.load();
}

class NischintApp extends StatelessWidget {
  const NischintApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const RootGate(),
      ),
    );
  }
}

/// तय करता है कि पहली स्क्रीन कौन-सी हो।
class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    if (!app.loaded) return const SplashView();
    if (!app.onboarded || app.role == null) return const OnboardingScreen();
    if (app.role == AppRole.vendor) {
      if (!app.vendor.isComplete) return const VendorProfileScreen(firstTime: true);
      return const VendorShell();
    }
    return const CustomerShell();
  }
}

/// ऐप खुलते समय एक पल के लिए।
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
              child: const Icon(Icons.solar_power, size: 48, color: Colors.white),
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
