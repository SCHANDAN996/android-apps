import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';

import 'services/dakshina_service.dart';
import 'services/device_location_service.dart';
import 'screens/calendar_screen.dart';
import 'screens/home_dashboard_screen.dart';
import 'screens/more_screen.dart';
import 'screens/vidhi_list_screen.dart';
import 'state/settings.dart';
import 'theme.dart';
import 'widgets/design_system.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await settings.load();
  await dakshina.load();

  // दक्षिणा का द्वार सिर्फ़ उन्हीं platform पर, जहाँ दुकान होती है।
  // ⚠️ `PlayBillingDwar()` बनते ही `InAppPurchase.instance` छू जाता है,
  // जो desktop पर फिंकता है — इसीलिए यह जाँच पहले।
  //
  // पहरा ऐप खुलते ही बैठता है, बटन दबने पर नहीं: UPI वाली ख़रीद कुछ
  // मिनट बाद पूरी होती है, और तब तक यूज़र पन्ना छोड़ चुका होता है।
  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    dakshina.shuru(PlayBillingDwar());
  }

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
          'विधिवत सिर्फ़ ऐप खुले रहने पर एक बार स्थान लेता है, और वह कहीं भेजा नहीं जाता।',
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
      // ⚠️ `SafeArea(top: false)` के बिना यह पट्टी Android के नीचे वाले
      // नेविगेशन बार (होम/बैक) के **पीछे** चली जाती थी, और टैब के नाम
      // उससे टकराते थे।
      //
      // वजह: Android 15 से ऐप ज़बरदस्ती edge-to-edge चलता है — यानी
      // उसे पूरी स्क्रीन मिलती है (यहाँ 720×1600), सिस्टम बार के नीचे
      // की जगह समेत। बाक़ी हर नीचे वाली पट्टी में यह पहले से लगा था
      // (विधि पन्ना, प्लेयर, सामग्री, completion) — बस यही छूट गई थी,
      // और यही चारों टैब पर हमेशा दिखती है, इसलिए टकराव हर जगह दिखा।
      //
      // फ़ोन पर पकड़ा गया (4 सित 2026), vivo V2553 · तीन-बटन वाला बार।
      bottomNavigationBar: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: _index,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'होम',
            ),
            // यहाँ पहले `Text('🪔')` था। बाक़ी तीनों टैब रेखा-वाले
            // Material चिह्न हैं, इसलिए बीच में एक भरा-पूरा रंगीन emoji
            // अटपटा लगता था — और हर फ़ोन पर अपनी शक़्ल का दिखता था।
            // अब वही दीया, उसी नाप और उसी मोटाई की रेखा से बना हुआ।
            NavigationDestination(
              icon: VidhivatDiyaIcon(),
              selectedIcon: VidhivatDiyaIcon(bhara: true),
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
      ),
    );
  }
}
