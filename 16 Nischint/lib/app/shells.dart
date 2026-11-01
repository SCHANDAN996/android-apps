import 'package:flutter/material.dart';

import '../screens/common/help_screen.dart';
import '../screens/customer/customer_home_screen.dart';
import '../screens/customer/my_bookings_screen.dart';
import '../screens/vendor/rate_card_screen.dart';
import '../screens/vendor/vendor_home_screen.dart';

/// नीचे वाले टैब का मौजूदा नंबर। किसी भी स्क्रीन से टैब बदलने के लिए [ShellNav]।
final ValueNotifier<int> shellTab = ValueNotifier<int>(0);

class ShellNav {
  ShellNav._();

  /// ऊपर खुली सारी स्क्रीनें बंद करके टैब [index] पर जाएँ।
  /// घर वाला: 0 होम, 1 मेरी बुकिंग, 2 मदद। वेंडर: 0 शिकायतें, 1 रेट कार्ड, 2 मदद।
  static void goToTab(BuildContext context, int index) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    shellTab.value = index;
  }
}

/// घर वाले का ढाँचा: होम | मेरी बुकिंग | मदद
class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
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
            children: const [CustomerHomeScreen(), MyBookingsScreen(), HelpScreen()],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (i) => shellTab.value = i,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'होम'),
              NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'मेरी बुकिंग'),
              NavigationDestination(icon: Icon(Icons.support_agent_outlined), selectedIcon: Icon(Icons.support_agent), label: 'मदद'),
            ],
          ),
        );
      },
    );
  }
}

/// वेंडर का ढाँचा: शिकायतें | रेट कार्ड | मदद
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
            children: const [VendorHomeScreen(), RateCardScreen(), HelpScreen()],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (i) => shellTab.value = i,
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'शिकायतें'),
              NavigationDestination(
                  icon: Icon(Icons.request_quote_outlined), selectedIcon: Icon(Icons.request_quote), label: 'रेट कार्ड'),
              NavigationDestination(icon: Icon(Icons.support_agent_outlined), selectedIcon: Icon(Icons.support_agent), label: 'मदद'),
            ],
          ),
        );
      },
    );
  }
}
