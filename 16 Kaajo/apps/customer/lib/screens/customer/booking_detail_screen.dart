import 'package:flutter/material.dart';
import 'package:kaajo_core/app/app_scope.dart';
import 'package:kaajo_core/app/theme.dart';
import 'package:kaajo_core/content/catalog.dart';
import 'package:kaajo_core/content/config.dart';
import 'package:kaajo_core/models/booking.dart';
import 'package:kaajo_core/services/contact_service.dart';
import 'package:kaajo_core/utils/format.dart';
import 'package:kaajo_core/widgets/common.dart';

import '../../app/shells.dart';
import 'widgets/customer_bits.dart';

/// एक बुकिंग की पूरी जानकारी, स्थिति बदलना, दोबारा भेजना, WhatsApp/कॉल से पूछना।
class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  static Booking? _find(List<Booking> bookings, String id) {
    for (final b in bookings) {
      if (b.id == id) return b;
    }
    return null;
  }

  static IconData _statusIcon(BookingStatus status) => switch (status) {
        BookingStatus.sent => Icons.schedule,
        BookingStatus.confirmed => Icons.event_available,
        BookingStatus.done => Icons.task_alt,
        BookingStatus.cancelled => Icons.cancel_outlined,
      };

  // ---------------- काम ----------------

  Future<void> _askOnWhatsApp(BuildContext context, Booking booking) async {
    final opened = await ContactService.whatsApp(ContactService.followUpMessage(booking.id));
    if (!context.mounted) return;
    if (!opened) showMessage(context, whatsAppFailedMessage);
  }

  Future<void> _call(BuildContext context) async {
    final opened = await ContactService.call();
    if (!context.mounted) return;
    if (!opened) showMessage(context, 'कॉल नहीं लग पाया। हमारा नंबर: ${AppConfig.businessPhone}');
  }

  Future<void> _resend(BuildContext context, Booking booking) async {
    final opened = await ContactService.whatsApp(ContactService.bookingMessage(booking));
    if (!context.mounted) return;
    if (!opened) showMessage(context, whatsAppFailedMessage);
  }

  Future<void> _markDone(BuildContext context, Booking booking) async {
    await AppScope.read(context).updateBookingStatus(booking.id, BookingStatus.done);
    if (!context.mounted) return;
    showMessage(context, 'बढ़िया! बुकिंग पूरी हुई मान ली गई।');
  }

  Future<void> _cancel(BuildContext context, Booking booking) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('बुकिंग रद्द करें?'),
        content: const Text(
          'यह बुकिंग रद्द हो जाएगी। फिर हमें बताने के लिए WhatsApp खुलेगा, वहाँ मैसेज भेज दें।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('नहीं, रहने दें'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('हाँ, रद्द करें', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await AppScope.read(context).updateBookingStatus(booking.id, BookingStatus.cancelled);
    if (!context.mounted) return;
    // हमें भी पता चले, ताकि टेक्नीशियन बेवजह न आए।
    final message = 'नमस्ते, मेरी बुकिंग ${booking.id} (${booking.serviceTitle}, '
        '${hindiDate(booking.date)}) रद्द कर दीजिए।\n(${AppConfig.appName} ऐप से)';
    final opened = await ContactService.whatsApp(message);
    if (!context.mounted) return;
    showMessage(context, opened ? 'बुकिंग रद्द कर दी गई।' : whatsAppFailedMessage);
  }

  // ---------------- स्क्रीन ----------------

  @override
  Widget build(BuildContext context) {
    final booking = _find(AppScope.of(context).bookings, bookingId);
    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('बुकिंग की जानकारी')),
        body: Center(
          child: SingleChildScrollView(
            child: EmptyState(
              icon: Icons.search_off,
              title: 'बुकिंग नहीं मिली',
              message: 'शायद यह बुकिंग इस फ़ोन से मिटा दी गई है।',
              actionLabel: 'मेरी बुकिंग देखें',
              onAction: () => ShellNav.goToTab(context, 1),
            ),
          ),
        ),
      );
    }

    final status = booking.status;
    final isFinal = isFinalStatus(status);
    return Scaffold(
      appBar: AppBar(title: const Text('बुकिंग की जानकारी')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.l, AppSpace.l, AppSpace.xl),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconBubble(serviceIconFor(booking.serviceId), size: 48),
                    const SizedBox(width: AppSpace.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(booking.serviceTitle, style: AppText.h3),
                          const SizedBox(height: 2),
                          SelectableText('बुकिंग नंबर: ${booking.id}', style: AppText.small),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpace.s),
                    StatusChip(status.label, tone: bookingStatusTone(status)),
                  ],
                ),
                const SizedBox(height: AppSpace.l),
                InfoBanner(
                  text: bookingStatusMessage(status),
                  icon: _statusIcon(status),
                  tone: bookingStatusTone(status),
                ),
              ],
            ),
          ),
          const SectionHeader('काम की जानकारी'),
          AppCard(
            child: Column(
              children: [
                DetailRow(label: 'तारीख', value: hindiDate(booking.date), icon: Icons.calendar_today),
                DetailRow(label: 'समय', value: booking.timeSlot, icon: Icons.schedule),
                DetailRow(
                  label: 'सिस्टम',
                  value: Catalog.kwLabel(booking.systemKw),
                  icon: Icons.solar_power,
                ),
                if (booking.problem.isNotEmpty)
                  DetailRow(
                    label: 'दिक्कत',
                    value: booking.problem,
                    icon: Icons.report_problem_outlined,
                  ),
                if (booking.installerVendor.isNotEmpty)
                  DetailRow(
                    label: 'किसने लगाया',
                    value: booking.installerVendor,
                    icon: Icons.storefront_outlined,
                  ),
                if (booking.note.isNotEmpty)
                  DetailRow(label: 'नोट', value: booking.note, icon: Icons.notes),
                DetailRow(
                  label: 'अनुमानित रेट',
                  value: '${rupees(booking.estimatedPrice)} · पैसा काम के बाद',
                  icon: Icons.currency_rupee,
                ),
              ],
            ),
          ),
          const SectionHeader('पता और संपर्क'),
          AppCard(
            child: Column(
              children: [
                DetailRow(label: 'नाम', value: booking.customerName, icon: Icons.person_outline),
                DetailRow(label: 'मोबाइल', value: booking.mobile, icon: Icons.phone_outlined),
                DetailRow(label: 'पता', value: booking.address, icon: Icons.home_outlined),
                if (booking.landmark.isNotEmpty)
                  DetailRow(label: 'लैंडमार्क', value: booking.landmark, icon: Icons.place_outlined),
                DetailRow(label: 'इलाका', value: booking.area, icon: Icons.location_on_outlined),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.s),
          Text('बुकिंग भेजी गई: ${hindiDateYear(booking.createdAt)}', style: AppText.small),
          if (!isFinal) ...[
            const SectionHeader('मैसेज नहीं गया था?'),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('बुकिंग का पूरा मैसेज WhatsApp पर दोबारा भेजें।', style: AppText.muted),
                  const SizedBox(height: AppSpace.m),
                  AppButton(
                    label: 'दोबारा भेजें',
                    icon: Icons.replay,
                    outlined: true,
                    onPressed: () => _resend(context, booking),
                  ),
                ],
              ),
            ),
            const SectionHeader('स्थिति बदलें'),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'काम हो जाए तो "काम पूरा हो गया" दबाएँ। अब ज़रूरत न हो तो बुकिंग रद्द करें।',
                    style: AppText.muted,
                  ),
                  const SizedBox(height: AppSpace.m),
                  AppButton(
                    label: 'काम पूरा हो गया',
                    icon: Icons.task_alt,
                    outlined: true,
                    color: AppColors.success,
                    onPressed: () => _markDone(context, booking),
                  ),
                  const SizedBox(height: AppSpace.m),
                  AppButton(
                    label: 'बुकिंग रद्द करें',
                    icon: Icons.cancel_outlined,
                    outlined: true,
                    color: AppColors.danger,
                    onPressed: () => _cancel(context, booking),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: PairButton(
                label: 'कॉल करें',
                icon: Icons.call,
                outlined: true,
                onPressed: () => _call(context),
              ),
            ),
            const SizedBox(width: AppSpace.m),
            Expanded(
              flex: 3,
              child: PairButton(
                label: 'WhatsApp पर पूछें',
                icon: Icons.chat,
                onPressed: () => _askOnWhatsApp(context, booking),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
