import 'package:flutter/material.dart';

/// TODO: एजेंट इस स्क्रीन को docs/TECHNICIAN_TRAINING_PLAN.md के हिसाब से बनाएगा।
class TechnicianSignupScreen extends StatelessWidget {
  const TechnicianSignupScreen({super.key, this.firstTime = false});

  final bool firstTime;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('TechnicianSignupScreen')));
  }
}
