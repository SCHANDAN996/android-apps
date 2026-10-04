import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/strings.dart';
import 'core/services/ad_service.dart';
import 'core/services/storage_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize services
  final storage = StorageService();
  await storage.init();

  // Set language from stored preference
  AppStrings.setLanguage(storage.language);
  AppTheme.mode.value = storage.themeMode;

  // Initialize ads
  try {
    await AdService().initialize(storage);
  } catch (_) {
    // Ad init failure shouldn't crash the app
  }

  runApp(MistriCalculatorApp(storage: storage));
}

class MistriCalculatorApp extends StatefulWidget {
  final StorageService storage;

  const MistriCalculatorApp({super.key, required this.storage});

  @override
  State<MistriCalculatorApp> createState() => _MistriCalculatorAppState();
}

class _MistriCalculatorAppState extends State<MistriCalculatorApp>
    with WidgetsBindingObserver {
  final _exitObserver = CalculatorExitObserver();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppStrings.localeNotifier.addListener(_refreshEverything);
    AppTheme.mode.addListener(_refreshEverything);
    AppColors.dark = _wantsDark;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppStrings.localeNotifier.removeListener(_refreshEverything);
    AppTheme.mode.removeListener(_refreshEverything);
    super.dispose();
  }

  /// The phone switched between its light and dark mode.
  @override
  void didChangePlatformBrightness() => _refreshEverything();

  bool get _wantsDark => switch (AppTheme.mode.value) {
    'dark' => true,
    'light' => false,
    _ =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark,
  };

  /// Language and colours are plain statics read while building, so a change
  /// has to reach every widget on every open screen — including `const` ones,
  /// which an ordinary rebuild from the top would skip.
  void _refreshEverything() {
    if (!mounted) return;
    setState(() => AppColors.dark = _wantsDark);
    void rebuild(Element element) {
      element.markNeedsBuild();
      element.visitChildren(rebuild);
    }

    context.visitChildElements(rebuild);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mistri Calculator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      navigatorObservers: [_exitObserver],
      home: HomeScreen(storage: widget.storage),
    );
  }
}
