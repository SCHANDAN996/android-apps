import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../models/complaint.dart';
import '../../../widgets/common.dart';

/// पोर्टल पर लगभग इतने दिन बाद रिमाइंडर आता है, फिर नोटिस और ID Deactivation का ख़तरा।
const int portalReminderDays = 8;

/// इतने दिन से नारंगी चेतावनी।
const int portalWarningDays = 5;

/// शिकायत की तारीख से बीते दिनों के हिसाब से रंग: 5+ दिन नारंगी, 8+ दिन लाल।
/// निपटी हुई शिकायत हरी।
ChipTone portalDaysTone(VendorComplaint c, [DateTime? now]) {
  if (c.status == ComplaintStatus.resolved) return ChipTone.success;
  final days = c.daysSinceComplaint(now);
  if (days >= portalReminderDays) return ChipTone.danger;
  if (days >= portalWarningDays) return ChipTone.warning;
  return ChipTone.info;
}

/// "आज की शिकायत", "1 दिन बीता", "6 दिन बीते"
String daysPassedLabel(int days) {
  if (days <= 0) return 'आज की शिकायत';
  if (days == 1) return '1 दिन बीता';
  return '$days दिन बीते';
}

/// स्थिति के हिसाब से चिप का रंग।
ChipTone complaintStatusTone(ComplaintStatus status) {
  switch (status) {
    case ComplaintStatus.sent:
      return ChipTone.neutral;
    case ComplaintStatus.visitScheduled:
      return ChipTone.info;
    case ComplaintStatus.resolved:
      return ChipTone.success;
  }
}

/// टोन के हिसाब से (हल्का पृष्ठभूमि, गहरा टेक्स्ट) रंग।
(Color, Color) toneColors(ChipTone tone) {
  switch (tone) {
    case ChipTone.success:
      return (AppColors.successSoft, AppColors.success);
    case ChipTone.warning:
      return (AppColors.warningSoft, AppColors.warning);
    case ChipTone.danger:
      return (AppColors.dangerSoft, AppColors.danger);
    case ChipTone.info:
      return (AppColors.primarySoft, AppColors.primaryDark);
    case ChipTone.neutral:
      return (const Color(0xFFF3F4F6), AppColors.text);
  }
}

/// "जल्दी चाहिए" वाली शिकायत का छोटा निशान।
class UrgentBadge extends StatelessWidget {
  const UrgentBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.sunSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.sun),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, size: 16, color: AppColors.warning),
          SizedBox(width: 2),
          Text(
            '48 घंटे',
            style: TextStyle(color: AppColors.warning, fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
