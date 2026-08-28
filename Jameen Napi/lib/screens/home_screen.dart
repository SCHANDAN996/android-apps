import 'package:flutter/material.dart';

import '../data/app_language.dart';
import '../data/pro_kisan_strings.dart';
import '../widgets/privacy_dialog.dart';
import 'batwara_screen.dart';
import 'converter_screen.dart';
import 'irregular_plot_screen.dart';
import 'laggi_screen.dart';
import 'length_screen.dart';
import 'pro_kisan_screen.dart';
import 'settings_screen.dart';
import 'triangle_plot_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLang>(
      valueListenable: LanguageNotifier.instance,
      builder: (context, lang, _) {
        final strings = AppStrings(lang);
        final topPadding = MediaQuery.of(context).padding.top;

        return Scaffold(
          body: SafeArea(
            top: false,
            bottom: true,
            child: Column(
              children: [
                // Premium Gradient Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(20, topPadding + 14, 20, 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Actions Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Expanded + Flexible zaroori hai: Tamil/Telugu/Kannada me
                          // app ka naam lamba hota hai aur pehle header se 159px
                          // bahar nikal jaata tha (RIGHT OVERFLOWED).
                          Expanded(
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    'assets/icon/icon.png',
                                    width: 38,
                                    height: 38,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    strings.appTitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.settings, color: Colors.white),
                                tooltip: strings.settingsTitle,
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: Colors.white),
                                onSelected: (val) {
                                  if (val == 'privacy') {
                                    showAppPrivacyPolicy(context, strings);
                                  } else if (val == 'settings') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                                    );
                                  }
                                },
                                itemBuilder: (ctx) => [
                                  PopupMenuItem(
                                    value: 'settings',
                                    child: Row(
                                      children: [
                                        const Icon(Icons.language, size: 20),
                                        const SizedBox(width: 8),
                                        Text(strings.settingsTitle),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'privacy',
                                    child: Row(
                                      children: [
                                        const Icon(Icons.privacy_tip_outlined, size: 20),
                                        const SizedBox(width: 8),
                                        Text(strings.privacyPolicy),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Subtitle
                      Text(
                        strings.appSubtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.92),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tool list
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                    children: [
                      _ToolCard(
                        icon: Icons.landscape_rounded,
                        title: strings.toolLand,
                        subtitle: strings.toolLandSub,
                        badge: strings.badgeStates,
                        badgeColor: Colors.green.shade700,
                        screen: const ConverterScreen(),
                        gradientColors: const [Color(0xFF1B5E20), Color(0xFF43A047)],
                      ),
                      _ToolCard(
                        icon: Icons.polyline_rounded,
                        title: strings.toolIrregularPlot,
                        subtitle: strings.toolIrregularPlotSub,
                        badge: strings.badgeExact,
                        badgeColor: Colors.deepOrange.shade700,
                        screen: const IrregularPlotScreen(),
                        gradientColors: const [Color(0xFFD84315), Color(0xFFFF7043)],
                      ),
                      _ToolCard(
                        icon: Icons.straighten_rounded,
                        title: strings.toolLength,
                        subtitle: strings.toolLengthSub,
                        badge: strings.badgeChain,
                        badgeColor: Colors.blue.shade700,
                        screen: const LengthScreen(),
                        gradientColors: const [Color(0xFF1565C0), Color(0xFF42A5F5)],
                      ),
                      _ToolCard(
                        icon: Icons.balance_rounded,
                        title: strings.toolLaggi,
                        subtitle: strings.toolLaggiSub,
                        badge: strings.badgeDesiScale,
                        badgeColor: Colors.amber.shade900,
                        screen: const LaggiScreen(),
                        gradientColors: const [Color(0xFFE65100), Color(0xFFFFB74D)],
                      ),
                      _ToolCard(
                        icon: Icons.pie_chart_rounded,
                        title: strings.toolBatwara,
                        subtitle: strings.toolBatwaraSub,
                        badge: strings.badgePartition,
                        badgeColor: Colors.purple.shade700,
                        screen: const BatwaraScreen(),
                        gradientColors: const [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
                      ),
                      _ToolCard(
                        icon: Icons.change_history_rounded,
                        title: strings.toolTriangle,
                        subtitle: strings.toolTriangleSub,
                        badge: strings.badgeThreeSides,
                        badgeColor: Colors.teal.shade700,
                        screen: const TrianglePlotScreen(),
                        gradientColors: const [Color(0xFF00695C), Color(0xFF26A69A)],
                      ),
                      const SizedBox(height: 4),
                      _ProKisanCard(strings: strings),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final Widget screen;
  final List<Color> gradientColors;

  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.screen,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors.first.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 26, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                color: badgeColor,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// हमारे दूसरे ऐप का promo. जान-बूझकर tools से अलग दिखता है — ऊपर साफ़ लिखा है
/// "हमारा दूसरा ऐप", ताकि कोई इसे इसी ऐप का सातवाँ tool न समझे।
class _ProKisanCard extends StatelessWidget {
  const _ProKisanCard({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFFFFDF5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFCC80), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProKisanScreen()),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.pkOurOtherApp.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: Colors.orange.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/icon/pro_kisan.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.pkName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            strings.pkTagline,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios,
                        size: 14, color: Colors.orange.shade800),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
