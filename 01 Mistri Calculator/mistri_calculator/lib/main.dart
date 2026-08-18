import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/strings.dart';
import 'core/services/ad_service.dart';
import 'core/services/storage_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prevent google_fonts from downloading fonts at runtime (offline app)
  GoogleFonts.config.allowRuntimeFetching = false;

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Status bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize services
  final storage = StorageService();
  await storage.init();

  // Set language from stored preference
  AppStrings.setLanguage(storage.language);

  // Initialize ads
  try {
    await AdService().initialize(storage);
  } catch (_) {
    // Ad init failure shouldn't crash the app
  }

  runApp(MistriCalculatorApp(storage: storage));
}

class MistriCalculatorApp extends StatelessWidget {
  final StorageService storage;

  const MistriCalculatorApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    // Rebuild the whole app when the language changes (live, no restart).
    return ValueListenableBuilder<String>(
      valueListenable: AppStrings.localeNotifier,
      builder: (context, lang, child) {
        return MaterialApp(
          title: 'Mistri Calculator',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: HomeScreen(storage: storage),
        );
      },
    );
  }
}
