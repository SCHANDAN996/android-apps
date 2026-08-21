import 'package:flutter/material.dart';

import 'screens/aaj_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/muhurta_screen.dart';
import 'screens/sankalp_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/vidhi_list_screen.dart';
import 'state/settings.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await settings.load();
  runApp(const VidhivatApp());
}

class VidhivatApp extends StatelessWidget {
  const VidhivatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => MaterialApp(
        title: 'विधिवत',
        debugShowCheckedModeBanner: false,
        theme: VidhivatTheme.light(),
        darkTheme: VidhivatTheme.dark(),
        home: const HomeShell(),
      ),
    );
  }
}

/// नीचे की पट्टी और उसके पाँच पन्ने।
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  // विधि सबसे पहले — यही ऐप का दिल है (→ D-002) और यही इकलौती चीज़ है
  // जो किसी प्रतियोगी के पास नहीं (→ D-012)। पंचांग सहारा है, बिकने
  // वाली चीज़ नहीं।
  static const _pages = [
    VidhiListScreen(),
    AajScreen(),
    CalendarScreen(),
    SankalpScreen(),
    MuhurtaScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.local_fire_department_outlined),
            selectedIcon: Icon(Icons.local_fire_department),
            label: 'विधि',
          ),
          NavigationDestination(
            icon: Icon(Icons.wb_sunny_outlined),
            selectedIcon: Icon(Icons.wb_sunny),
            label: 'आज',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'कैलेंडर',
          ),
          NavigationDestination(
            icon: Icon(Icons.water_drop_outlined),
            selectedIcon: Icon(Icons.water_drop),
            label: 'संकल्प',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule),
            label: 'चौघड़िया',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'सेटिंग',
          ),
        ],
      ),
    );
  }
}
