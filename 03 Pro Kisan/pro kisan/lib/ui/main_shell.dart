import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/permission_service.dart';
import '../services/report_archive_service.dart';

import 'home_screen.dart';
import 'dashboard_screen.dart';
import 'kheti_screen.dart';
import 'more_screen.dart';
import 'pashu/pashu_screen.dart';
import '../db/dao/settings_dao.dart';
import 'widgets/drive_restore_prompt.dart';
import 'widgets/pro_tour.dart';

/// Bottom-navigation shell holding the 5 main sections.
///
/// tab के index: 0=घर, 1=दूध, 2=पशु, 3=खेती, 4=और
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  /// किसी भी screen से nav-tab बदलने का रास्ता।
  ///
  /// पहले dashboard के बड़े कार्ड सीधे andar वाली screen (`/entry`, `/pashu`…)
  /// पर पुश करते थे — इसलिए किसान को "दो अलग दूध पेज" लगते थे (एक tab वाला,
  /// एक कार्ड वाला)। अब कार्ड इसी notifier से सही tab पर ले जाते हैं, तो हमेशा
  /// एक ही जगह पहुँचते हैं और नीचे का tab भी हाइलाइट रहता है।
  static final ValueNotifier<int> goToTab = ValueNotifier<int>(0);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  /// नीचे वाले पाँच tab के लिए — पहली बार आने वाले किसान को यही समझाना है।
  ///
  /// ⚠️ यही ऐप का असली नक़्शा है। पहले कोई तौर-तरीक़ा नहीं था कि नया किसान
  /// समझे कि नीचे के पाँच निशान क्या हैं — वह पहली screen पर ही अटक जाता था।
  final List<GlobalKey> _tabKeys = List.generate(5, (_) => GlobalKey());

  /// आख़िरी बार back कब दबा — "फिर दबाएँ, ऐप बंद होगा" के लिए
  DateTime? _lastBackPress;

  late final List<Widget> _pages = const [
    DashboardScreen(),
    HomeScreen(),
    PashuScreen(),
    KhetiScreen(),
    MoreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    MainShell.goToTab.addListener(_onGoToTab);

    // अनुमतियाँ यहाँ माँगते हैं (splash पर नहीं) — तब तक ऐप की असली screen
    // दिख चुकी होती है, इसलिए "कौन सी अनुमति क्यों चाहिए" वाला हमारा dialog
    // ठीक से दिखता है। onboarding वाले नए उपयोगकर्ता भी यहीं पहुँचते हैं।
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await PermissionService.instance.requestAllOnStartup(context);
      // अनुमतियों के बाद — रोज़ का बैकअप + पिछले महीने की रिपोर्ट
      if (mounted) ReportArchiveService.instance.runOnAppOpen(context);

      // 🛡️ नया फ़ोन? — "आपका पुराना हिसाब मिला है, वापस लाएँ?"
      //
      // सिर्फ़ तब पूछता है जब Google खाता जुड़ा हो **और फ़ोन का हिसाब ख़ाली
      // हो**। दूसरी शर्त ज़रूरी है — वरना जिस किसान के फ़ोन में पहले से काम
      // है, उसका आज का काम Drive वाले पुराने backup से मिट सकता था।
      if (mounted) DriveRestorePrompt.poochhoAgarZaroorat(context);

      // 🧭 पहली बार आने वाले किसान को ऐप का नक़्शा दिखाओ
      if (mounted) _pehliBaarRastaDikhao();
    });
  }

  /// नीचे के पाँच tab एक-एक करके समझाओ — सिर्फ़ पहली बार।
  ///
  /// यह सबसे ज़रूरी रास्ता है: किसान को पता ही नहीं चलता था कि दूध कहाँ
  /// लिखें, पशु कहाँ जोड़ें, मंडी भाव कहाँ है। पाँच क़दम में पूरा ऐप समझ
  /// आ जाता है।
  ///
  /// अनुमति वाले dialog और Drive वाले सवाल के **बाद** चलता है, ताकि दो
  /// चीज़ें एक साथ न दिखें।
  Future<void> _pehliBaarRastaDikhao() async {
    try {
      final dao = SettingsDao();
      if (await dao.getValue(_kShellTourKey) == 'yes') return;
      if (!mounted) return;

      // tab के icon बन चुके हों, तब घेरना — वरना जगह ग़लत निकलेगी
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      ProTour.dikhao(
        context,
        steps: [
          ProTourStep(
              key: _tabKeys[0],
              title: _t('tour_nav_home_title'),
              desc: _t('tour_nav_home_desc')),
          ProTourStep(
              key: _tabKeys[1],
              title: _t('tour_nav_milk_title'),
              desc: _t('tour_nav_milk_desc')),
          ProTourStep(
              key: _tabKeys[2],
              title: _t('tour_nav_pashu_title'),
              desc: _t('tour_nav_pashu_desc')),
          ProTourStep(
              key: _tabKeys[3],
              title: _t('tour_nav_kheti_title'),
              desc: _t('tour_nav_kheti_desc')),
          ProTourStep(
              key: _tabKeys[4],
              title: _t('tour_nav_more_title'),
              desc: _t('tour_nav_more_desc')),
        ],
        onKhatam: () => dao.setValue(_kShellTourKey, 'yes'),
      );
    } catch (_) {
      // रास्ता न दिखा पाएँ तो ऐप रुकना नहीं चाहिए
    }
  }

  static const _kShellTourKey = 'seen_shell_tour';

  @override
  void dispose() {
    MainShell.goToTab.removeListener(_onGoToTab);
    super.dispose();
  }

  void _onGoToTab() {
    final i = MainShell.goToTab.value;
    if (i >= 0 && i < _pages.length && i != _index) {
      setState(() => _index = i);
    }
  }

  String _t(String k) => AppLocalizations.get(context, k);

  /// Android का back बटन — साफ़ नियम:
  ///  • घर वाले tab पर नहीं हैं → पहले घर लौटो (ऐप बंद मत करो)
  ///  • घर पर हैं → 2 सेकंड में दोबारा दबाने पर ही बंद हो
  ///
  /// पहले किसी भी tab पर back दबाते ही ऐप सीधे बंद हो जाता था — किसान का
  /// आधा काम बीच में छूट जाता था।
  Future<void> _handleBack(bool didPop, Object? result) async {
    if (didPop) return;

    if (_index != 0) {
      setState(() => _index = 0);
      return;
    }

    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_t('pressBackAgain')),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    // दूसरी बार 2 सेकंड के अंदर — अब बंद होने दो
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // हम खुद तय करेंगे कि कब बंद होना है
      canPop: false,
      onPopInvokedWithResult: _handleBack,
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      // SafeArea bottom: false — NavigationBar handles its own bottom inset.
      // This prevents system nav-bar from overlapping page content.
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _index, children: _pages),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
            ),
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF15803D),
                  );
                }
                return const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                );
              }),
            ),
            child: NavigationBar(
              backgroundColor: Colors.white,
              elevation: 0,
              height: 72,
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              indicatorColor: const Color(0xFFDCFCE7),
              destinations: [
                NavigationDestination(
                    icon: KeyedSubtree(key: _tabKeys[0], child: const Icon(Icons.home_outlined, color: Color(0xFF64748B), size: 26)),
                    selectedIcon: const Icon(Icons.home_rounded, color: Color(0xFF15803D), size: 28),
                    tooltip: _t('navHomeHint'),
                    label: _t('navHome')),
                NavigationDestination(
                    icon: KeyedSubtree(key: _tabKeys[1], child: const Icon(Icons.local_drink_outlined, color: Color(0xFF64748B), size: 26)),
                    selectedIcon: const Icon(Icons.local_drink_rounded, color: Color(0xFF15803D), size: 28),
                    tooltip: _t('navMilkHint'),
                    label: _t('navMilk')),
                NavigationDestination(
                    icon: KeyedSubtree(key: _tabKeys[2], child: const Icon(Icons.pets_outlined, color: Color(0xFF64748B), size: 26)),
                    selectedIcon: const Icon(Icons.pets_rounded, color: Color(0xFF15803D), size: 28),
                    tooltip: _t('navPashuHint'),
                    label: _t('navPashu')),
                NavigationDestination(
                    icon: KeyedSubtree(key: _tabKeys[3], child: const Icon(Icons.grass_outlined, color: Color(0xFF64748B), size: 26)),
                    selectedIcon: const Icon(Icons.grass_rounded, color: Color(0xFF15803D), size: 28),
                    tooltip: _t('navKhetiHint'),
                    label: _t('navKheti')),
                NavigationDestination(
                    icon: KeyedSubtree(key: _tabKeys[4], child: const Icon(Icons.menu_rounded, color: Color(0xFF64748B), size: 26)),
                    selectedIcon: const Icon(Icons.menu_rounded, color: Color(0xFF15803D), size: 28),
                    tooltip: _t('navMoreHint'),
                    label: _t('navMore')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
