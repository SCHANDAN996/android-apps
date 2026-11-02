import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kaajo_core/app/app_scope.dart';
import 'package:kaajo_core/app/app_state.dart';
import 'package:kaajo_core/app/theme.dart';
import 'package:kaajo_core/content/config.dart';
import 'package:kaajo_core/models/profiles.dart';

import 'app/shells.dart';
import 'screens/partner_role_screen.dart';
import 'screens/technician/technician_signup_screen.dart';
import 'screens/vendor/vendor_profile_screen.dart';
import 'screens/vendor/widgets/partner_brand.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  runApp(KaajoPartnerApp(state: state));
  state.load();
}

/// पार्टनर ऐप: सोलर वेंडर (आगे टेक्नीशियन भी)।
class KaajoPartnerApp extends StatelessWidget {
  const KaajoPartnerApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: partnerAppName,
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

/// पहली बार भूमिका (वेंडर / टेक्नीशियन) चुनना, फिर उसकी जानकारी, फिर होम।
class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    if (!app.loaded) return const SplashView();
    switch (app.role) {
      case AppRole.vendor:
        if (!app.vendor.isComplete) return const VendorProfileScreen(firstTime: true);
        return const VendorShell();
      case AppRole.technician:
        if (!app.technician.isComplete) return const TechnicianSignupScreen(firstTime: true);
        return const TechnicianShell();
      case AppRole.customer:
      case null:
        return const PartnerRoleScreen();
    }
  }
}

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: AppColors.sun, shape: BoxShape.circle),
              child: const Icon(Icons.engineering, size: 48, color: Colors.white),
            ),
            const SizedBox(height: AppSpace.l),
            const Text(
              partnerAppName,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: AppSpace.s),
            const Text(AppConfig.vendorLine, style: TextStyle(fontSize: 16, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
