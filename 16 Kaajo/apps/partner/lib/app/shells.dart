import 'package:flutter/material.dart';
import 'package:kaajo_core/screens/common/help_screen.dart';

import '../screens/technician/technician_jobs_screen.dart';
import '../screens/technician/training_home_screen.dart';
import '../screens/vendor/rate_card_screen.dart';
import '../screens/vendor/vendor_home_screen.dart';

/// नीचे वाले टैब का मौजूदा नंबर।
final ValueNotifier<int> shellTab = ValueNotifier<int>(0);

class ShellNav {
  ShellNav._();

  /// ऊपर खुली सारी स्क्रीनें बंद करके टैब [index] पर जाएँ।
  /// वेंडर: 0 शिकायतें, 1 रेट कार्ड, 2 मदद। टेक्नीशियन: 0 ट्रेनिंग, 1 काम, 2 मदद।
  static void goToTab(BuildContext context, int index) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    shellTab.value = index;
  }
}

/// शिकायतें | रेट कार्ड | मदद
class VendorShell extends StatefulWidget {
  const VendorShell({super.key});

  @override
  State<VendorShell> createState() => _VendorShellState();
}

class _VendorShellState extends State<VendorShell> {
  @override
  void initState() {
    super.initState();
    shellTab.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: shellTab,
      builder: (context, index, _) {
        return Scaffold(
          body: IndexedStack(
            index: index,
            children: const [VendorHomeScreen(), RateCardScreen(), HelpScreen(faqs: vendorFaqs)],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (i) => shellTab.value = i,
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'शिकायतें'),
              NavigationDestination(
                  icon: Icon(Icons.request_quote_outlined), selectedIcon: Icon(Icons.request_quote), label: 'रेट कार्ड'),
              NavigationDestination(
                  icon: Icon(Icons.support_agent_outlined), selectedIcon: Icon(Icons.support_agent), label: 'मदद'),
            ],
          ),
        );
      },
    );
  }
}

/// टेक्नीशियन: ट्रेनिंग | काम | मदद
class TechnicianShell extends StatefulWidget {
  const TechnicianShell({super.key});

  @override
  State<TechnicianShell> createState() => _TechnicianShellState();
}

class _TechnicianShellState extends State<TechnicianShell> {
  @override
  void initState() {
    super.initState();
    shellTab.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: shellTab,
      builder: (context, index, _) {
        return Scaffold(
          body: IndexedStack(
            index: index,
            children: const [TrainingHomeScreen(), TechnicianJobsScreen(), HelpScreen(faqs: technicianFaqs)],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (i) => shellTab.value = i,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school), label: 'ट्रेनिंग'),
              NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'काम'),
              NavigationDestination(
                  icon: Icon(Icons.support_agent_outlined), selectedIcon: Icon(Icons.support_agent), label: 'मदद'),
            ],
          ),
        );
      },
    );
  }
}
