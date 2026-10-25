import 'dart:async';

import 'package:flutter/foundation.dart'
    show
        LicenseEntryWithLineBreaks,
        LicenseRegistry,
        TargetPlatform,
        defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'services/dakshina_service.dart';
import 'services/device_location_service.dart';
import 'services/pitru_reminders.dart';
import 'services/vinati_service.dart';
import 'screens/calendar_screen.dart';
import 'screens/home_dashboard_screen.dart';
import 'screens/more_screen.dart';
import 'screens/vidhi_list_screen.dart';
import 'state/settings.dart';
import 'state/shell_tab.dart';
import 'state/ancestor_profiles.dart';
import 'theme.dart';
import 'widgets/design_system.dart';
import 'widgets/vinati_sheet.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // गाँव-क़स्बों की सूची (assets/jagah) का श्रेय — उसके लाइसेंस की शर्त (→ D-128)।
  // सिर्फ़ सेटिंग → लाइसेंस वाले पन्ने पर; ऐप के पाठ में कहीं नहीं।
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(
      ['गाँव और क़स्बों की सूची'],
      'भारत की बसी जगहों के नाम और अक्षांश-देशांतर: GeoNames (geonames.org), '
      'Creative Commons Attribution 4.0 लाइसेंस के अंतर्गत। ऐप में सूची छोटी करके '
      'और बदले हुए ढाँचे में रखी गई है।',
    );
    // → D-129: «इंटरनेट पर भी खोजें» के नतीजे
    yield const LicenseEntryWithLineBreaks(
      ['इंटरनेट पर जगह की खोज'],
      'जगहों का डेटा © OpenStreetMap contributors, Open Database License (ODbL) '
      'के अंतर्गत (openstreetmap.org/copyright)। खोज komoot की Photon सेवा से — '
      'सिर्फ़ लिखा हुआ नाम जाता है।',
    );
  });
  await settings.load();
  await ancestorProfiles.load();
  // केवल पहले से opt-in किए reminder दोबारा तय होते हैं; अनुमति नहीं माँगी जाती।
  pitruReminders.refresh();
  await dakshina.load();

  // ── दक्षिणा की विनती की गिनती (→ D-132) ──
  // ऐप का ठंडा खुलना = एक बैठक। notification दबाकर खुला हो तो उस बैठक में
  // विनती नहीं (आदमी स्मरण के लिए आया है)।
  await vinati.load();
  await vinati.baithakShuru(DateTime.now());
  pitruReminders.notificationDabaya =
      () => vinati.notificationSeAaya(DateTime.now());
  if (await pitruReminders.notificationSeKhula()) {
    vinati.notificationSeAaya(DateTime.now());
  }

  // दक्षिणा का द्वार — PayU का पन्ना बाहर खुलता है (→ D-090)। सिर्फ़
  // फ़ोन पर; desktop पर चलाने/जाँचने में कोई पन्ना नहीं खुलना चाहिए।
  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    dakshina.shuru(PayuDwar());
  }

  runApp(const VidhivatApp());
}

class VidhivatApp extends StatefulWidget {
  const VidhivatApp({super.key});

  @override
  State<VidhivatApp> createState() => _VidhivatAppState();
}

/// होम पर लौटना पहचानने के लिए — दक्षिणा की विनती सिर्फ़ तभी (→ D-132)।
///
/// सिर्फ़ **पन्ने** (`PageRoute`) — dialog या नीचे की पट्टी बंद होना "लौटना" नहीं
/// (पहली बार वाला स्थान-अनुमति dialog बंद होते ही विनती का timer बन जाता था)।
final vinatiRouteObserver = RouteObserver<PageRoute<dynamic>>();

class _VidhivatAppState extends State<VidhivatApp>
    with WidgetsBindingObserver {
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
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _requestInitialLocation());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// आधे घंटे से ज़्यादा पीछे पड़ा रहकर सामने आया = नई बैठक (→ D-132)।
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        vinati.peechhe(DateTime.now());
      case AppLifecycleState.resumed:
        vinati.saamne(DateTime.now());
      default:
        break;
    }
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
        navigatorObservers: [vinatiRouteObserver],
        // Flutter के अपने डिब्बे भी हिंदी में — जन्म की तारीख़ और समय चुनते हुए
        // पहले "Mon, Jan 1 … Cancel / OK" आता था (फ़ोन पर पकड़ा, 18 अक्टूबर 2026)।
        locale: const Locale('hi', 'IN'),
        supportedLocales: const [Locale('hi', 'IN')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
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

class _HomeShellState extends State<HomeShell> with RouteAware {
  int _index = 0;
  final Set<int> _visitedTabs = {0};

  @override
  void initState() {
    super.initState();
    shellTabMaang.addListener(_maangaTab);
  }

  /// किसी और पन्ने ने tab माँगा — जैसे पूजा पूरी होने पर «होम पर लौटें» (UX-017)।
  void _maangaTab() {
    final i = shellTabMaang.lo();
    if (i != null && mounted && i != _index) _onTabSelected(i);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) vinatiRouteObserver.subscribe(this, route);
  }

  Timer? _vinatiTimer;

  @override
  void dispose() {
    _vinatiTimer?.cancel();
    shellTabMaang.removeListener(_maangaTab);
    vinatiRouteObserver.unsubscribe(this);
    super.dispose();
  }

  /// किसी पन्ने से लौटकर मुख्य पन्ने पर आए — काम पूरा करके (→ D-132)।
  ///
  /// ⛔ ऐप खुलते ही नहीं (यह सिर्फ़ लौटने पर चलता है), notification वाली बैठक में
  /// नहीं, पूजा-पूर्ण का डिब्बा देख चुकी बैठक में नहीं — नियम `VinatiBahi` में।
  /// दो सेकंड रुककर, और तभी जब ऊपर कोई और पन्ना या dialog न हो।
  @override
  void didPopNext() {
    // पहले सस्ती जाँच — लगभग हर बार यहीं ख़त्म, कोई timer नहीं बनता
    if (!vinati.dakshinaPoochhen(DateTime.now(),
        kabhiDiThi: dakshina.kabhiDiThi)) {
      return;
    }
    _vinatiTimer?.cancel();
    _vinatiTimer = Timer(const Duration(seconds: 2), () async {
      if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
      final ab = DateTime.now();
      if (!vinati.dakshinaPoochhen(ab, kabhiDiThi: dakshina.kabhiDiThi)) return;
      await vinati.dakshinaPoochhi(ab);
      if (!mounted) return;
      await dakshinaVinatiDikhao(context);
    });
  }

  void _onTabSelected(int i) {
    setState(() {
      _index = i;
      _visitedTabs.add(i);
    });
  }

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
                onOpenPujaLibrary: () => _onTabSelected(1),
              ),
              _visitedTabs.contains(1)
                  ? const VidhiListScreen()
                  : const SizedBox.shrink(),
              _visitedTabs.contains(2)
                  ? const CalendarScreen()
                  : const SizedBox.shrink(),
              _visitedTabs.contains(3)
                  ? const MoreScreen()
                  : const SizedBox.shrink(),
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
          onDestinationSelected: _onTabSelected,
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
