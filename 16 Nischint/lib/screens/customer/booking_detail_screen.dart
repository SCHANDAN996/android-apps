import 'package:flutter/material.dart';

/// TODO: एजेंट इस स्क्रीन को PLAN.md के हिसाब से बनाएगा।
class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('BookingDetailScreen')));
  }
}
