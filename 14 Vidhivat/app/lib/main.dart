import 'package:flutter/material.dart';

import 'services/device_location_service.dart';
import 'screens/calendar_screen.dart';
import 'screens/home_dashboard_screen.dart';
import 'screens/more_screen.dart';
import 'screens/vidhi_list_screen.dart';
import 'state/settings.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await settings.load();
  runApp(const VidhivatApp());
}

class VidhivatApp extends StatefulWidget {
  const VidhivatApp({super.key});

  @override
  State<VidhivatApp> createState() => _VidhivatAppState();
}

class _VidhivatAppState extends State<VidhivatApp> {
  /// ⚠️ यह key इसलिए चाहिए कि पहली बार वाला dialog **MaterialApp के नीचे**
  /// से खुले।
  ///
  /// पहले `showDialog(context: context)` लिखा था, जहाँ `context` इसी
  /// State का था — यानी MaterialApp के *ऊपर*। वहाँ `MaterialLocalizations`
  /// होती ही नहीं, इसलिए हर बार ऐप खुलते ही exception फिंकता था और
  /// **नए यूज़र से शहर कभी पूछा ही नहीं जाता था।** ऊपर से
  /// `markLocationPermissionPromptSeen()` भी कभी नहीं चलता था, तो यह हर
  /// launch पर दोहराता रहता।
  ///
  /// यह बग `flutter analyze` और सारी जाँचों के रहते भी छिपा रहा — असली
  /// फ़ोन के logcat में ही दिखा।
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _requestInitialLocation());
  }

  Future<void> _requestInitialLocation() async {
    if (!mounted || settings.locationPermissionPromptSeen) return;
    final navigatorContext = _navigatorKey.currentContext;
    if (navigatorContext == null) return;
    final wantsLocation = await showDialog<bool>(
      context: navigatorContext,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('अपना स्थान पहचानने दें?'),
        content: const Text(
          'सूर्योदय, तिथि और चौघड़िया आपके स्थान के अनुसार बदलते हैं। '
          'विधिवत सिर्फ़ app खुले रहने पर एक बार स्थान लेगा; location कहीं भेजी नहीं जाएगी।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('अभी नहीं'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('स्थान अनुमति दें'),
          ),
        ],
      ),
    );
    await settings.markLocationPermissionPromptSeen();
    if (wantsLocation != true) return;

    final result = await const DeviceLocationService().getCurrentLocation();
    if (result.hasPosition) {
      await settings.setCityFromDeviceLocation(
        latitude: result.latitude!,
        longitude: result.longitude!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => MaterialApp(
        title: 'विधिवत',
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: VidhivatTheme.light(),
        darkTheme: VidhivatTheme.dark(),
        // Phase 1 establishes dark as the product's default visual language.
        // Both themes stay available so a later user preference can be added
        // without a navigation or business-logic migration.
        themeMode: ThemeMode.dark,
        home: const HomeShell(),
      ),
    );
  }
}

/// The compact four-tab shell. Secondary tools live under Home quick actions
/// and More instead of competing for six narrow navigation destinations.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // City is one shared setting. Recreate page widgets after an automatic
      // or manual location change so Panchang, calendar, Sankalp and Muhurta
      // all recalculate together instead of showing mixed-city results.
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => KeyedSubtree(
          key: ValueKey(settings.city.cacheKey),
          child: IndexedStack(
            index: _index,
            children: [
              HomeDashboardScreen(
                onOpenPujaLibrary: () => setState(() => _index = 1),
              ),
              const VidhiListScreen(),
              const CalendarScreen(),
              const MoreScreen(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'होम',
          ),
          NavigationDestination(
            icon: Text('🪔', style: TextStyle(fontSize: 22)),
            selectedIcon: Text('🪔', style: TextStyle(fontSize: 25)),
            label: 'पूजा',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'कैलेंडर',
          ),
          NavigationDestination(
            icon: Icon(Icons.apps_outlined),
            selectedIcon: Icon(Icons.apps),
            label: 'अधिक',
          ),
        ],
      ),
    );
  }
}
