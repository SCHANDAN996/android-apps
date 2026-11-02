import 'package:flutter/material.dart';
import 'package:kaajo_core/app/app_scope.dart';
import 'package:kaajo_core/app/theme.dart';
import 'package:kaajo_core/models/booking.dart';
import 'package:kaajo_core/utils/format.dart';
import 'package:kaajo_core/widgets/common.dart';

import '../../app/shells.dart';
import 'booking_detail_screen.dart';
import 'widgets/customer_bits.dart';

/// "मेरी बुकिंग" टैब: फ़ोन में सेव सारी बुकिंग, नई सबसे ऊपर।
class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookings = AppScope.of(context).bookings;
    return Scaffold(
      appBar: AppBar(title: const Text('मेरी बुकिंग')),
      body: bookings.isEmpty
          ? Center(
              child: SingleChildScrollView(
                child: EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'अभी कोई बुकिंग नहीं',
                  message: 'सोलर की सफ़ाई या जाँच बुक करें। आपकी सारी बुकिंग यहाँ दिखेंगी।',
                  actionLabel: 'सेवा बुक करें',
                  onAction: () => ShellNav.goToTab(context, 0),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.l, AppSpace.l, AppSpace.xl),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpace.m),
              itemBuilder: (context, i) => _BookingCard(booking: bookings[i]),
            ),
    );
  }
}

/// एक बुकिंग का कार्ड: सेवा, तारीख और समय, बुकिंग नंबर, स्थिति।
class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => BookingDetailScreen(bookingId: booking.id)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBubble(serviceIconFor(booking.serviceId), size: 44),
          const SizedBox(width: AppSpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(booking.serviceTitle, style: AppText.h3)),
                    const SizedBox(width: AppSpace.s),
                    StatusChip(booking.status.label, tone: bookingStatusTone(booking.status)),
                  ],
                ),
                const SizedBox(height: AppSpace.xs),
                Text('${hindiDate(booking.date)} · ${booking.timeSlot}', style: AppText.body),
                const SizedBox(height: AppSpace.xs),
                Text('बुकिंग नंबर: ${booking.id}', style: AppText.small),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.xs),
          const Padding(
            padding: EdgeInsets.only(top: AppSpace.m),
            child: Icon(Icons.chevron_right, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
