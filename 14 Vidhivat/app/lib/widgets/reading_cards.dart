import 'package:flutter/material.dart';

import '../theme.dart';
import 'design_system.dart';

/// Two columns shared by the home reading sections and complete catalogues.
class ReadingCardGrid extends StatelessWidget {
  final Key? gridKey;
  final List<Widget> children;
  const ReadingCardGrid({super.key, this.gridKey, required this.children});

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final width = (box.maxWidth - VidhivatSpacing.md) / 2;
        return Wrap(
          key: gridKey,
          spacing: VidhivatSpacing.md,
          runSpacing: VidhivatSpacing.md,
          children: [
            for (final child in children) SizedBox(width: width, child: child)
          ],
        );
      });
}

/// A distinct cover, the same soft glow as popular puja, and a centred name.
class ReadingArtworkCard extends StatelessWidget {
  final String name;
  final String artwork;
  final VoidCallback onTap;
  const ReadingArtworkCard(
      {super.key,
      required this.name,
      required this.artwork,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = VidhivatTheme.colorsOf(context);
    final type = VidhivatTheme.typographyOf(context);
    return Semantics(
        button: true,
        label: name,
        onTap: onTap,
        excludeSemantics: true,
        child: VidhivatSurfaceCard(
          onTap: onTap,
          padding: const EdgeInsets.all(VidhivatSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(builder: (context, box) {
                final side = box.maxWidth.clamp(0.0, 160.0).toDouble();
                return Center(
                    child: Container(
                  width: side,
                  height: side,
                  decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                    BoxShadow(
                        color: colors.primary.withValues(alpha: .20),
                        blurRadius: 34,
                        spreadRadius: 2),
                  ]),
                  child: Image.asset(artwork,
                      fit: BoxFit.contain,
                      cacheHeight:
                          (side * MediaQuery.devicePixelRatioOf(context))
                              .round(),
                      filterQuality: FilterQuality.high,
                      excludeFromSemantics: true),
                ));
              }),
              const SizedBox(height: VidhivatSpacing.sm),
              Text(name, textAlign: TextAlign.center, style: type.cardTitle),
            ],
          ),
        ));
  }
}
