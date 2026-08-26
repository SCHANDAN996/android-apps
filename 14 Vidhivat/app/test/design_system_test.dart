import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/widgets/design_system.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
        theme: VidhivatTheme.dark(),
        home: Scaffold(body: Center(child: child)),
      );

  test('semantic token scales are ordered and complete', () {
    expect(VidhivatSpacing.xxs, lessThan(VidhivatSpacing.xs));
    expect(VidhivatSpacing.xs, lessThan(VidhivatSpacing.md));
    expect(VidhivatRadius.smallValue, lessThan(VidhivatRadius.largeValue));
    expect(VidhivatColorTokens.dark.textPrimary,
        isNot(VidhivatColorTokens.dark.background));
    expect(
        VidhivatTypography.from(VidhivatColorTokens.dark).mantra.fontSize,
        greaterThan(VidhivatTypography.from(VidhivatColorTokens.dark)
            .bodyLarge
            .fontSize!));
  });

  testWidgets('full-width loading CTA is labelled and cannot be pressed',
      (tester) async {
    var presses = 0;
    await tester.pumpWidget(host(VidhivatButton(
      label: 'आगे बढ़ें',
      onPressed: () => presses++,
      icon: Icons.arrow_forward,
      fullWidth: true,
      isLoading: true,
    )));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.getSize(find.byType(VidhivatButton)).width,
        equals(tester.getSize(find.byType(Scaffold)).width));
    await tester.tap(find.text('आगे बढ़ें'));
    expect(presses, 0);
  });

  testWidgets('surface and status primitives expose their semantic state',
      (tester) async {
    await tester.pumpWidget(host(const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        VidhivatSurfaceCard(
          variant: VidhivatCardVariant.selectable,
          selected: true,
          semanticLabel: 'चुनी हुई पूजा',
          child: Text('पूजा'),
        ),
        SizedBox(height: VidhivatSpacing.sm),
        VidhivatStatusChip(
          label: 'शुभ',
          tone: VidhivatStatusTone.success,
          icon: Icons.check_circle_outline,
        ),
      ],
    )));

    expect(find.text('पूजा'), findsOneWidget);
    expect(find.text('शुभ'), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(VidhivatSurfaceCard)),
      matchesSemantics(
        label: 'चुनी हुई पूजा',
        hasSelectedState: true,
        isSelected: true,
      ),
    );
  });
}
