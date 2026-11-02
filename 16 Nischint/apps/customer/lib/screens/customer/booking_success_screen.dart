import 'package:flutter/material.dart';
import 'package:nischint_core/models/booking.dart';

/// TODO: एजेंट इस स्क्रीन को PLAN.md के हिसाब से बनाएगा।
class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('BookingSuccessScreen')));
  }
}
