import 'package:flutter/material.dart';

/// TODO: एजेंट इस स्क्रीन को PLAN.md के हिसाब से बनाएगा।
class VendorProfileScreen extends StatelessWidget {
  const VendorProfileScreen({super.key, this.firstTime = false});

  final bool firstTime;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('VendorProfileScreen')));
  }
}
