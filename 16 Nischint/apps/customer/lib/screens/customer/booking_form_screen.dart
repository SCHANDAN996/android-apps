import 'package:flutter/material.dart';
import 'package:nischint_core/models/service_item.dart';

/// TODO: एजेंट इस स्क्रीन को PLAN.md के हिसाब से बनाएगा।
class BookingFormScreen extends StatelessWidget {
  const BookingFormScreen({super.key, required this.service});

  final ServiceItem service;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('BookingFormScreen')));
  }
}
