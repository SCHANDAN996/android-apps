import 'package:flutter/material.dart';

import 'package:nischint_core/app/theme.dart';
import 'package:nischint_core/content/catalog.dart';
import 'package:nischint_core/content/config.dart';
import 'package:nischint_core/models/booking.dart';
import 'package:nischint_core/widgets/common.dart';

/// हल्के गोल घेरे में आइकन (सेवा कार्ड, हेडर, ऑनबोर्डिंग)।
class IconBubble extends StatelessWidget {
  const IconBubble(
    this.icon, {
    super.key,
    this.size = 48,
    this.color = AppColors.primary,
    this.background = AppColors.primarySoft,
  });

  final IconData icon;
  final double size;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, size: size * 0.5, color: color),
    );
  }
}

/// जानकारी की एक पंक्ति: ऊपर छोटा लेबल, नीचे मान।
class DetailRow extends StatelessWidget {
  const DetailRow({super.key, required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpace.m),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.small),
                const SizedBox(height: 2),
                Text(value.trim().isEmpty ? '—' : value, style: AppText.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// नीचे की पट्टी में दो बटन साथ रखने के लिए: कम पैडिंग, और लेबल लंबा हो तो बटन ऊँचा हो जाता है।
class PairButton extends StatelessWidget {
  const PairButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.outlined = false,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpace.buttonRadius));
    const padding = EdgeInsets.symmetric(horizontal: AppSpace.m, vertical: AppSpace.s);
    const minSize = Size(0, AppSpace.buttonHeight);
    const textStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 6)],
        Flexible(child: Text(label, textAlign: TextAlign.center, style: textStyle)),
      ],
    );
    if (outlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: minSize,
          padding: padding,
          shape: shape,
          foregroundColor: c,
          side: BorderSide(color: c, width: 1.4),
        ),
        child: child,
      );
    }
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: minSize,
        padding: padding,
        shape: shape,
        backgroundColor: c,
        foregroundColor: Colors.white,
      ),
      child: child,
    );
  }
}

/// फ़ॉर्म में चिप वाले सवाल के नीचे लाल ग़लती का संदेश।
class FieldErrorText extends StatelessWidget {
  const FieldErrorText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.s),
      child: Text(text, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
    );
  }
}

/// बुकिंग की स्थिति का चिप रंग।
ChipTone bookingStatusTone(BookingStatus status) => switch (status) {
      BookingStatus.sent => ChipTone.info,
      BookingStatus.confirmed => ChipTone.warning,
      BookingStatus.done => ChipTone.success,
      BookingStatus.cancelled => ChipTone.danger,
    };

/// बुकिंग की स्थिति का आसान मतलब (बुकिंग की जानकारी वाली स्क्रीन पर)।
String bookingStatusMessage(BookingStatus status) => switch (status) {
      BookingStatus.sent => 'बुकिंग हमें भेज दी गई है। ${AppConfig.callbackPromise}',
      BookingStatus.confirmed => 'समय पक्का हो गया है। तय दिन पर हमारा टेक्नीशियन आपके घर आएगा।',
      BookingStatus.done => 'काम पूरा हो गया। ${AppConfig.appName} चुनने के लिए धन्यवाद!',
      BookingStatus.cancelled => 'यह बुकिंग रद्द कर दी गई है।',
    };

/// स्थिति पूरी या रद्द हो चुकी है, अब बदल नहीं सकते।
bool isFinalStatus(BookingStatus status) =>
    status == BookingStatus.done || status == BookingStatus.cancelled;

/// सेवा के id से उसका आइकन (पुरानी बुकिंग में सेवा न मिले तो सोलर आइकन)।
IconData serviceIconFor(String serviceId) => Catalog.byId(serviceId)?.icon ?? Icons.solar_power;
