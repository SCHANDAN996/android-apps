import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/strings.dart';
import '../core/services/storage_service.dart';
import 'brick_screen.dart';
import '../widgets/motion.dart';
import 'concrete_screen.dart';
import 'steel_screen.dart';
import 'plaster_screen.dart';
import 'tile_screen.dart';
import 'paint_screen.dart';
import 'stairs_screen.dart';
import 'excavation_screen.dart';
import 'water_tank_screen.dart';
import 'my_rates_screen.dart';
import 'project_screen.dart';
import 'settings_screen.dart';
import 'guide_screen.dart';

class HomeScreen extends StatelessWidget {
  final StorageService storage;

  const HomeScreen({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    // No banner here: the first screen stays clean. Ads live on the
    // calculator screens.
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            AppStrings.get('appTagline'),
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: AppStrings.get('settings'),
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

            // A visual first-use cue: it tells a new user what the six
            // calculator cards below are for without adding instructional
            // text to every card.
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.13),
                        AppColors.accent.withValues(alpha: 0.10),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.get('homeHeroTitle'),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              AppStrings.get('homeHeroSubtitle'),
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Image.asset(
                        'assets/images/house_estimate.webp',
                        width: 104,
                        height: 104,
                        fit: BoxFit.contain,
                        semanticLabel: AppStrings.get('appTagline'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Calculator Grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.crossAxisExtent >= 700 ? 3 : 2;
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      mainAxisExtent: columns == 2 ? 202 : 190,
                    ),
                    delegate: SliverChildListDelegate(
                      StaggerIn.wrapAll([
                        _CalculatorCard(
                          imageAsset: 'assets/images/brick_tool.webp',
                          iconColor: const Color(0xFFD84315),
                          title: AppStrings.get('brick'),
                          subtitle: AppStrings.get('brickDesc'),
                          onTap: () =>
                              _navigate(context, BrickScreen(storage: storage)),
                        ),
                        _CalculatorCard(
                          imageAsset: 'assets/images/concrete_tool.webp',
                          iconColor: const Color(0xFF37474F),
                          title: AppStrings.get('concrete'),
                          subtitle: AppStrings.get('concreteDesc'),
                          onTap: () => _navigate(
                            context,
                            ConcreteScreen(storage: storage),
                          ),
                        ),
                        _CalculatorCard(
                          imageAsset: 'assets/images/steel_tool.webp',
                          iconColor: const Color(0xFF4527A0),
                          title: AppStrings.get('steel'),
                          subtitle: AppStrings.get('steelDesc'),
                          onTap: () =>
                              _navigate(context, SteelScreen(storage: storage)),
                        ),
                        _CalculatorCard(
                          imageAsset: 'assets/images/plaster_tool.webp',
                          iconColor: const Color(0xFF00695C),
                          title: AppStrings.get('plaster'),
                          subtitle: AppStrings.get('plasterDesc'),
                          onTap: () => _navigate(
                            context,
                            PlasterScreen(storage: storage),
                          ),
                        ),
                        _CalculatorCard(
                          imageAsset: 'assets/images/tile_tool.webp',
                          iconColor: const Color(0xFF0277BD),
                          title: AppStrings.get('tiles'),
                          subtitle: AppStrings.get('tilesDesc'),
                          onTap: () =>
                              _navigate(context, TileScreen(storage: storage)),
                        ),
                        _CalculatorCard(
                          imageAsset: 'assets/images/paint_tool.webp',
                          iconColor: const Color(0xFFC62828),
                          title: AppStrings.get('paint'),
                          subtitle: AppStrings.get('paintDesc'),
                          onTap: () =>
                              _navigate(context, PaintScreen(storage: storage)),
                        ),
                        _CalculatorCard(
                          icon: Icons.stairs_rounded,
                          iconColor: const Color(0xFF5D4037),
                          title: AppStrings.get('stairs'),
                          subtitle: AppStrings.get('stairsDesc'),
                          onTap: () => _navigate(
                            context,
                            StairsScreen(storage: storage),
                          ),
                        ),
                        _CalculatorCard(
                          icon: Icons.terrain_rounded,
                          iconColor: const Color(0xFF6D4C41),
                          title: AppStrings.get('excavation'),
                          subtitle: AppStrings.get('excavationDesc'),
                          onTap: () => _navigate(
                            context,
                            ExcavationScreen(storage: storage),
                          ),
                        ),
                        _CalculatorCard(
                          icon: Icons.water_drop_rounded,
                          iconColor: const Color(0xFF0277BD),
                          title: AppStrings.get('waterTank'),
                          subtitle: AppStrings.get('waterTankDesc'),
                          onTap: () => _navigate(
                            context,
                            WaterTankScreen(storage: storage),
                          ),
                        ),
                      ]),
                    ),
                  );
                },
              ),
            ),

            // My House card — full width
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () =>
                        _navigate(context, ProjectScreen(storage: storage)),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.costHighlight.withValues(alpha: 0.08),
                            AppColors.costBackground,
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
                              color: AppColors.costHighlight.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.home_work_rounded,
                              color: AppColors.costHighlight,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.get('myProject'),
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  AppStrings.get('myProjectDesc'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
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

            // Construction Guide card — full width
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () => _navigate(context, const GuideScreen()),
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
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  AppStrings.get('guideHomeDesc'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
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
                    onTap: () =>
                        _navigate(context, MyRatesScreen(storage: storage)),
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
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  AppStrings.get('myRatesDesc'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
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

            // Clearance so the last card never touches the banner ad.
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

/// Grid card for each calculator.
class _CalculatorCard extends StatelessWidget {
  /// The tool's picture — or, for tools without one, [icon].
  final String? imageAsset;
  final IconData? icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CalculatorCard({
    this.imageAsset,
    this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title, $subtitle',
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 78,
                  height: 78,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: imageAsset == null
                      ? Icon(icon, size: 44, color: iconColor)
                      : Image.asset(
                          imageAsset!,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.medium,
                        ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
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
      ),
    );
  }
}
