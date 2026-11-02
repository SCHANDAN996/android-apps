import 'package:flutter/material.dart';
import 'package:nischint_core/screens/common/help_screen.dart';

import '../screens/customer/customer_home_screen.dart';
import '../screens/customer/my_bookings_screen.dart';

/// नीचे वाले टैब का मौजूदा नंबर।
final ValueNotifier<int> shellTab = ValueNotifier<int>(0);

class ShellNav {
  ShellNav._();

  /// ऊपर खुली सारी स्क्रीनें बंद करके टैब [index] पर जाएँ: 0 होम, 1 मेरी बुकिंग, 2 मदद।
  static void goToTab(BuildContext context, int index) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    shellTab.value = index;
  }
}

/// होम | मेरी बुकिंग | मदद
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
              NavigationDestination(
                  icon: Icon(Icons.support_agent_outlined), selectedIcon: Icon(Icons.support_agent), label: 'मदद'),
            ],
          ),
        );
      },
    );
  }
}
