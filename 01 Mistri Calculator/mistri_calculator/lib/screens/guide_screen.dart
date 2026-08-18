import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/strings.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('constructionGuide')),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        children: [
          _buildCategoryHeader('faqCategoryMaterial'),
          _buildGuideCard(
            context,
            icon: Icons.grain_rounded,
            iconColor: const Color(0xFFFF8F00),
            titleKey: 'cftHelpTitle',
            descKey: 'cftHelpDesc',
          ),
          _buildGuideCard(
            context,
            icon: Icons.format_paint_rounded,
            iconColor: const Color(0xFF00695C),
            titleKey: 'mortarHelpTitle',
            descKey: 'mortarHelpDesc',
          ),
          _buildGuideCard(
            context,
            icon: Icons.foundation_rounded,
            iconColor: const Color(0xFF37474F),
            titleKey: 'concreteHelpTitle',
            descKey: 'concreteHelpDesc',
          ),
          _buildGuideCard(
            context,
            icon: Icons.straighten_rounded,
            iconColor: const Color(0xFF4527A0),
            titleKey: 'steelHelpTitle',
            descKey: 'steelHelpDesc',
          ),
          _buildGuideCard(
            context,
            icon: Icons.grid_view_rounded,
            iconColor: const Color(0xFF0277BD),
            titleKey: 'tileHelpTitle',
            descKey: 'tileHelpDesc',
          ),
          _buildGuideCard(
            context,
            icon: Icons.color_lens_rounded,
            iconColor: const Color(0xFFC62828),
            titleKey: 'paintHelpTitle',
            descKey: 'paintHelpDesc',
          ),
          const SizedBox(height: 16),
          _buildCategoryHeader('faqCategoryApp'),
          _buildGuideCard(
            context,
            icon: Icons.signal_wifi_off_rounded,
            iconColor: const Color(0xFFE65100),
            titleKey: 'faqOfflineTitle',
            descKey: 'faqOfflineDesc',
          ),
          _buildGuideCard(
            context,
            icon: Icons.currency_rupee_rounded,
            iconColor: const Color(0xFF2E7D32),
            titleKey: 'faqRatesTitle',
            descKey: 'faqRatesDesc',
          ),
          _buildGuideCard(
            context,
            icon: Icons.share_rounded,
            iconColor: const Color(0xFF1565C0),
            titleKey: 'faqShareTitle',
            descKey: 'faqShareDesc',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String titleKey) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        AppStrings.get(titleKey),
        style: GoogleFonts.notoSans(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildGuideCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String titleKey,
    required String descKey,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.cardBorder, width: 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          title: Text(
            AppStrings.get(titleKey),
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textHint,
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 1, color: AppColors.cardBorder),
            const SizedBox(height: 12),
            Text(
              AppStrings.get(descKey),
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
