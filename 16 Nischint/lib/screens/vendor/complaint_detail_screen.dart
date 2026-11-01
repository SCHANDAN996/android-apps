import 'package:flutter/material.dart';

/// TODO: एजेंट इस स्क्रीन को PLAN.md के हिसाब से बनाएगा।
class ComplaintDetailScreen extends StatelessWidget {
  const ComplaintDetailScreen({super.key, required this.complaintId});

  final String complaintId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('ComplaintDetailScreen')));
  }
}
