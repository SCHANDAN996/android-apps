import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'theme/dairy_theme.dart';
import 'khaad/khaad_screen.dart';

/// खेती tab — खेत से जुड़ा सब कुछ एक जगह।
/// 2×2 Premium Dashboard Card Layout
class KhetiScreen extends StatelessWidget {
  const KhetiScreen({super.key});

  String _t(BuildContext c, String k) => AppLocalizations.get(c, k);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DairyTheme.creamBg,
      appBar: AppBar(title: Text(_t(context, 'navKheti'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.88,
          children: [
            _DashCard(
              title: _t(context, 'khaadTitle'),
              subtitle: _t(context, 'khetiKhaadSub'),
              image: 'assets/images/3d_fertilizer.webp',
              gradient: const [Color(0xFF15803D), Color(0xFF22C55E)],
              icon: Icons.grass_rounded,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KhaadScreen()),
              ),
            ),
            _DashCard(
              title: _t(context, 'moreWeather'),
              subtitle: _t(context, 'khetiWeatherSub'),
              image: 'assets/images/3d_weather.webp',
              gradient: const [Color(0xFFD97706), Color(0xFFF59E0B)],
              icon: Icons.wb_sunny_rounded,
              onTap: () => Navigator.pushNamed(context, '/weather'),
            ),
            _DashCard(
              title: _t(context, 'moreMandi'),
              subtitle: _t(context, 'khetiMandiSub'),
              image: 'assets/images/3d_rates.webp',
              gradient: const [Color(0xFF1E40AF), Color(0xFF3B82F6)],
              icon: Icons.trending_up_rounded,
              onTap: () => Navigator.pushNamed(context, '/mandi'),
            ),
            _DashCard(
              title: _t(context, 'navLand'),
              subtitle: _t(context, 'khetiLandSub'),
              image: 'assets/images/3d_land.webp',
              gradient: const [Color(0xFF4338CA), Color(0xFF6366F1)],
              icon: Icons.map_rounded,
              onTap: () => Navigator.pushNamed(context, '/land_measurement'),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// 🎴 Dashboard Card Widget
// ═══════════════════════════════════════════════════════════════════════

class _DashCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String image;
  final List<Color> gradient;
  final IconData icon;
  final VoidCallback onTap;

  const _DashCard({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.gradient,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_DashCard> createState() => _DashCardState();
}

class _DashCardState extends State<_DashCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.04,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) => Transform.scale(
        scale: _scale.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.gradient,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.first.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Subtle circle decoration (top-right)
              Positioned(
                top: -18,
                right: -18,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 3D Image
                    Expanded(
                      child: Center(
                        child: Image.asset(
                          widget.image,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            widget.icon,
                            size: 48,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Subtitle
                    Text(
                      widget.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.82),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
