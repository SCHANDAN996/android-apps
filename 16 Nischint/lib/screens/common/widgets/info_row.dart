import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// जानकारी की एक पंक्ति: ऊपर छोटा लेबल, नीचे मान। [icon] हो तो बाईं तरफ़।
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.value, this.icon});

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
