import 'package:flutter/material.dart';
import 'package:kaajo_core/app/theme.dart';
import 'package:kaajo_core/content/config.dart';
import 'package:kaajo_core/models/booking.dart';
import 'package:kaajo_core/utils/format.dart';
import 'package:kaajo_core/widgets/common.dart';

import '../../app/shells.dart';
import 'widgets/customer_bits.dart';

/// "बुकिंग भेज दी गई": हरा टिक, बुकिंग नंबर, सेवा-तारीख-समय, और आगे कहाँ जाएँ।
/// फ़ोन का "वापस" बटन सीधे होम पर ले जाता है (फ़ॉर्म पर नहीं)।
class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) ShellNav.goToTab(context, 0);
      },
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.xxl, AppSpace.l, AppSpace.xl),
            children: [
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: AppColors.successSoft, shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle, size: 84, color: AppColors.success),
                ),
              ),
              const SizedBox(height: AppSpace.xl),
              const Text('बुकिंग भेज दी गई', style: AppText.h1, textAlign: TextAlign.center),
              const SizedBox(height: AppSpace.s),
              const Text(
                AppConfig.callbackPromise,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textMuted, height: 1.45),
              ),
              const SizedBox(height: AppSpace.xl),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('बुकिंग नंबर', style: AppText.small),
                    const SizedBox(height: 2),
                    SelectableText(
                      booking.id,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Divider(height: AppSpace.xl),
                    DetailRow(
                      label: 'सेवा',
                      value: booking.serviceTitle,
                      icon: serviceIconFor(booking.serviceId),
                    ),
                    DetailRow(label: 'तारीख', value: hindiDate(booking.date), icon: Icons.calendar_today),
                    DetailRow(label: 'समय', value: booking.timeSlot, icon: Icons.schedule),
                    DetailRow(
                      label: 'अनुमानित रेट',
                      value: '${rupees(booking.estimatedPrice)} · पैसा काम के बाद',
                      icon: Icons.currency_rupee,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.l),
              const InfoBanner(
                text: 'WhatsApp में मैसेज का "भेजें" बटन दबाना न भूलें। '
                    'मैसेज न गया हो तो "मेरी बुकिंग" से दोबारा भेज सकते हैं।',
                icon: Icons.chat,
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomActionBar(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                label: 'मेरी बुकिंग देखें',
                icon: Icons.receipt_long,
                onPressed: () => ShellNav.goToTab(context, 1),
              ),
              const SizedBox(height: AppSpace.s),
              AppButton(
                label: 'होम पर जाएँ',
                icon: Icons.home_outlined,
                outlined: true,
                onPressed: () => ShellNav.goToTab(context, 0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
