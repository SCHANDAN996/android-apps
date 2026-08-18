import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/strings.dart';
import '../core/services/storage_service.dart';
import 'brick_screen.dart';
import 'concrete_screen.dart';
import 'steel_screen.dart';
import 'plaster_screen.dart';
import 'tile_screen.dart';
import 'paint_screen.dart';
import 'my_rates_screen.dart';
import 'settings_screen.dart';
import 'guide_screen.dart';

class HomeScreen extends StatelessWidget {
  final StorageService storage;

  const HomeScreen({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.construction_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.get('appName'),
                            style: GoogleFonts.notoSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            AppStrings.get('appTagline'),
                            style: GoogleFonts.notoSans(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      color: AppColors.textSecondary,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettingsScreen(storage: storage),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Calculator Grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.05,
                ),
                delegate: SliverChildListDelegate([
                  _CalculatorCard(
                    icon: Icons.view_comfy_alt_rounded,
                    iconColor: const Color(0xFFD84315),
                    title: AppStrings.get('brick'),
                    subtitle: AppStrings.get('brickDesc'),
                    onTap: () => _navigate(
                      context,
                      BrickScreen(storage: storage),
                    ),
                  ),
                  _CalculatorCard(
                    icon: Icons.foundation_rounded,
                    iconColor: const Color(0xFF37474F),
                    title: AppStrings.get('concrete'),
                    subtitle: AppStrings.get('concreteDesc'),
                    onTap: () => _navigate(
                      context,
                      ConcreteScreen(storage: storage),
                    ),
                  ),
                  _CalculatorCard(
                    icon: Icons.straighten_rounded,
                    iconColor: const Color(0xFF4527A0),
                    title: AppStrings.get('steel'),
                    subtitle: AppStrings.get('steelDesc'),
                    onTap: () => _navigate(
                      context,
                      SteelScreen(storage: storage),
                    ),
                  ),
                  _CalculatorCard(
                    icon: Icons.format_paint_rounded,
                    iconColor: const Color(0xFF00695C),
                    title: AppStrings.get('plaster'),
                    subtitle: AppStrings.get('plasterDesc'),
                    onTap: () => _navigate(
                      context,
                      PlasterScreen(storage: storage),
                    ),
                  ),
                  _CalculatorCard(
                    icon: Icons.grid_view_rounded,
                    iconColor: const Color(0xFF0277BD),
                    title: AppStrings.get('tiles'),
                    subtitle: AppStrings.get('tilesDesc'),
                    onTap: () => _navigate(
                      context,
                      TileScreen(storage: storage),
                    ),
                  ),
                  _CalculatorCard(
                    icon: Icons.color_lens_rounded,
                    iconColor: const Color(0xFFC62828),
                    title: AppStrings.get('paint'),
                    subtitle: AppStrings.get('paintDesc'),
                    onTap: () => _navigate(
                      context,
                      PaintScreen(storage: storage),
                    ),
                  ),
                ]),
              ),
            ),

            // Construction Guide card — full width
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () => _navigate(
                      context,
                      const GuideScreen(),
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.08),
                            AppColors.surfaceVariant,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.book_rounded,
                              color: AppColors.primary,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.get('constructionGuide'),
                                  style: GoogleFonts.notoSans(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  AppStrings.get('guideHomeDesc'),
                                  style: GoogleFonts.notoSans(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textHint,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // My Rates card — full width
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () => _navigate(
                      context,
                      MyRatesScreen(storage: storage),
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accent.withValues(alpha: 0.08),
                            AppColors.surfaceVariant,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.currency_rupee_rounded,
                              color: AppColors.accent,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.get('myRates'),
                                  style: GoogleFonts.notoSans(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  AppStrings.get('myRatesDesc'),
                                  style: GoogleFonts.notoSans(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textHint,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

/// Grid card for each calculator.
class _CalculatorCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CalculatorCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: GoogleFonts.notoSans(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
