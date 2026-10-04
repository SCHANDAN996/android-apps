import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/strings.dart';
import '../core/utils/indian_formatter.dart';
import 'motion.dart';

/// Responsive body shared by every calculator screen.
///
/// Forms stay readable on tablets, the keyboard dismisses naturally on drag,
/// and the banner ad always has enough breathing room.
class CalculatorPageBody extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const CalculatorPageBody({
    super.key,
    required this.child,
    this.maxWidth = 680,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontal = constraints.maxWidth < 360 ? 12.0 : 16.0;
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 32),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A single visual surface that groups one calculator's related controls.
class FormSurface extends StatelessWidget {
  final Widget child;

  const FormSurface({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Brings a newly calculated result into view after layout is complete.
class ResultReveal extends StatefulWidget {
  final Widget child;

  const ResultReveal({super.key, required this.child});

  @override
  State<ResultReveal> createState() => _ResultRevealState();
}

class _ResultRevealState extends State<ResultReveal> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        alignment: 0.08,
      );
    });
  }

  @override
  Widget build(BuildContext context) => FadeSlideIn(child: widget.child);
}

/// Tells the user their numbers are missing — and shows them where: every
/// empty or zero field on the current screen turns red and shakes, and the
/// topmost one gets the cursor.
void showInputError(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(AppStrings.get('enterValue')),
      backgroundColor: AppColors.error,
    ),
  );
  _LargeInputFieldState.flagInvalidFields();
}

/// Large numeric input field for construction measurements.
class LargeInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? suffix;
  final String? hint;
  final bool allowDecimal;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  /// Overrides the "this field still needs a number" check used by
  /// [showInputError] — e.g. an inches box that may stay empty.
  final bool Function()? needsValue;

  /// No sane measurement or rate is longer than this; it also keeps a
  /// leaning thumb from producing a number too big to calculate with.
  static const int maxDigits = 9;

  const LargeInputField({
    super.key,
    required this.controller,
    required this.label,
    this.suffix,
    this.hint,
    this.allowDecimal = true,
    this.suffixIcon,
    this.onChanged,
    this.needsValue,
  });

  @override
  State<LargeInputField> createState() => _LargeInputFieldState();
}

class _LargeInputFieldState extends State<LargeInputField>
    with SingleTickerProviderStateMixin {
  /// Every field currently on screen, so [showInputError] can find the ones
  /// that still need a number without each screen tracking them.
  static final List<_LargeInputFieldState> _mounted = [];

  final _focusNode = FocusNode();
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  bool _error = false;

  bool get _needsValue =>
      widget.needsValue?.call() ??
      (double.tryParse(widget.controller.text) ?? 0) <= 0;

  Offset get _position =>
      (context.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero) ??
      Offset.zero;

  /// Fields of the screen on top, in reading order.
  static List<_LargeInputFieldState> _fieldsOnScreen() {
    final positions = {
      for (final f in _mounted)
        if (f.mounted && (ModalRoute.of(f.context)?.isCurrent ?? true))
          f: f._position,
    };
    return positions.keys.toList()..sort((a, b) {
      final pa = positions[a]!, pb = positions[b]!;
      return pa.dy != pb.dy ? pa.dy.compareTo(pb.dy) : pa.dx.compareTo(pb.dx);
    });
  }

  /// The keyboard's action key: on to the next field, and from the last one
  /// straight to the answer.
  void _onSubmitted() {
    final fields = _fieldsOnScreen();
    final i = fields.indexOf(this);
    if (i >= 0 && i < fields.length - 1) {
      fields[i + 1]._focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
      CalculateButton.pressCurrent();
    }
  }

  static void flagInvalidFields() {
    final invalid = [
      for (final f in _fieldsOnScreen())
        if (f._needsValue) f,
    ];
    for (final f in invalid) {
      f._flag();
    }
    if (invalid.isEmpty) return;
    final first = invalid.first;
    first._focusNode.requestFocus();
    Scrollable.ensureVisible(
      first.context,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: 0.2,
    );
  }

  void _flag() {
    setState(() => _error = true);
    if (!reduceMotion(context)) _shake.forward(from: 0);
  }

  @override
  void initState() {
    super.initState();
    _mounted.add(this);
  }

  @override
  void dispose() {
    _mounted.remove(this);
    _shake.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    );
    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) => Transform.translate(
        offset: Offset(shakeOffset(_shake.value), 0),
        child: child,
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          hintText: widget.hint,
          suffixText: widget.suffix,
          suffixIcon: widget.suffixIcon,
          suffixStyle: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
          enabledBorder: _error ? errorBorder : null,
          focusedBorder: _error ? errorBorder : null,
        ),
        keyboardType: TextInputType.numberWithOptions(
          decimal: widget.allowDecimal,
        ),
        inputFormatters: [
          if (widget.allowDecimal)
            _SingleDecimalFormatter()
          else
            FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(LargeInputField.maxDigits),
        ],
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) => _onSubmitted(),
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        onChanged: (v) {
          if (_error) setState(() => _error = false);
          widget.onChanged?.call(v);
        },
      ),
    );
  }
}

/// Allows digits with at most one decimal point (blocks "1.2.3", "..").
class _SingleDecimalFormatter extends TextInputFormatter {
  static final RegExp _valid = RegExp(r'^\d*\.?\d*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Some keyboards only offer a comma as the decimal key.
    final text = newValue.text.replaceAll(',', '.');
    if (text.isEmpty || _valid.hasMatch(text)) {
      return newValue.copyWith(text: text);
    }
    return oldValue;
  }
}

/// Unit toggle dropdown (ft / m).
class UnitToggle extends StatelessWidget {
  final String value; // one of [options]
  final ValueChanged<String> onChanged;

  /// Unit codes to show. Defaults to length units; the brick screen passes
  /// ['mm', 'in'] for entering a brick size.
  final List<String> options;

  const UnitToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.options = const ['ft', 'm'],
  });

  static const Map<String, String> _labelKeys = {
    'ft': 'feet',
    'm': 'meter',
    'mm': 'unitMm',
    'in': 'unitInch',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((code) {
          return _UnitChip(
            label: AppStrings.get(_labelKeys[code] ?? code),
            isSelected: value == code,
            onTap: () => onChanged(code),
          );
        }).toList(),
      ),
    );
  }
}

class _UnitChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _UnitChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Choice chip selector for options like thickness, ratio, grade.
class OptionChips<T> extends StatelessWidget {
  final List<T> options;
  final T selected;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onSelected;

  /// Optional picture shown above the label — used by the brick screen to draw
  /// the brick and the wall to scale, so the choice can be seen, not read.
  final Widget Function(T option, bool selected)? glyphBuilder;

  /// Optional smaller second line under the label (e.g. the exact size).
  final String Function(T)? subLabelBuilder;

  const OptionChips({
    super.key,
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.onSelected,
    this.glyphBuilder,
    this.subLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isActive = option == selected;
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: Semantics(
                button: true,
                selected: isActive,
                label: labelBuilder(option),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onSelected(option),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      constraints: const BoxConstraints(minHeight: 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.cardBorder,
                        ),
                      ),
                      child: _buildContent(option, isActive),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildContent(T option, bool isActive) {
    final label = Text(
      labelBuilder(option),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isActive ? Colors.white : AppColors.textPrimary,
      ),
    );

    if (glyphBuilder == null && subLabelBuilder == null) return label;

    final sub = subLabelBuilder?.call(option);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (glyphBuilder != null) ...[
          glyphBuilder!(option, isActive),
          const SizedBox(height: 6),
        ],
        label,
        if (sub != null && sub.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? Colors.white.withValues(alpha: 0.85)
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// A two-column visual selector used when the picture is as important as the
/// label, such as brick size and wall thickness. Fixed card widths prevent a
/// long translated label from pushing another choice off-screen.
class VisualChoiceGrid<T> extends StatelessWidget {
  final List<T> options;
  final T selected;
  final String Function(T) labelBuilder;
  final String Function(T)? subLabelBuilder;
  final String Function(T) imageAssetBuilder;
  final ValueChanged<T> onSelected;
  final int columns;
  final bool compact;
  final bool fillWidth;
  final double? cardHeight;
  final double? imageHeight;
  final bool showImageBackground;
  final bool labelsAtBottom;
  final Color? selectedColor;

  /// How much of the image box this option's picture should fill, 0-1.
  /// The brick screen passes the brick's real size here so a bigger brick is
  /// actually drawn bigger. Defaults to filling the box.
  final double Function(T)? imageScaleBuilder;

  const VisualChoiceGrid({
    super.key,
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.imageAssetBuilder,
    required this.onSelected,
    this.subLabelBuilder,
    this.columns = 2,
    this.compact = false,
    this.fillWidth = false,
    this.cardHeight,
    this.imageHeight,
    this.showImageBackground = true,
    this.labelsAtBottom = false,
    this.selectedColor,
    this.imageScaleBuilder,
  });

  @override
  Widget build(BuildContext context) {
    const gap = 12.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        final grid = Wrap(
          spacing: gap,
          runSpacing: gap,
          children: options.map((option) {
            final isActive = option == selected;
            final subLabel = subLabelBuilder?.call(option);
            final activeColor = selectedColor ?? AppColors.primary;
            return SizedBox(
              width: cardWidth,
              child: Semantics(
                button: true,
                selected: isActive,
                label: [
                  labelBuilder(option),
                  if (subLabel != null && subLabel.isNotEmpty) subLabel,
                ].join(', '),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () => onSelected(option),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: cardHeight ?? (compact ? 108 : 132),
                      padding: EdgeInsets.all(compact ? 8 : 10),
                      decoration: BoxDecoration(
                        color: isActive
                            ? activeColor
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isActive ? activeColor : AppColors.cardBorder,
                          width: isActive ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: labelsAtBottom
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.center,
                        children: [
                          Container(
                            height: imageHeight ?? (compact ? 40 : 54),
                            width: double.infinity,
                            padding: showImageBackground
                                ? const EdgeInsets.all(4)
                                : EdgeInsets.zero,
                            decoration: showImageBackground
                                ? BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.88),
                                    borderRadius: BorderRadius.circular(10),
                                  )
                                : null,
                            child: FractionallySizedBox(
                              widthFactor: imageScaleBuilder?.call(option) ?? 1,
                              heightFactor:
                                  imageScaleBuilder?.call(option) ?? 1,
                              child: Image.asset(
                                imageAssetBuilder(option),
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.medium,
                              ),
                            ),
                          ),
                          if (labelsAtBottom) const Spacer(),
                          SizedBox(height: compact ? 5 : 7),
                          Text(
                            labelBuilder(option),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: compact ? 11 : 13,
                              fontWeight: FontWeight.w700,
                              color: isActive
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          if (subLabel != null && subLabel.isNotEmpty) ...[
                            const SizedBox(height: 1),
                            Text(
                              subLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: compact ? 10 : 11,
                                fontWeight: FontWeight.w500,
                                color: isActive
                                    ? Colors.white.withValues(alpha: 0.86)
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );

        return fillWidth
            ? SizedBox(width: constraints.maxWidth, child: grid)
            : grid;
      },
    );
  }
}

/// Large calculate button with gradient.
class CalculateButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String? label;

  const CalculateButton({super.key, required this.onPressed, this.label});

  static final List<_CalculateButtonState> _mounted = [];

  /// Presses the Calculate button of the screen on top, if it has one — what
  /// the keyboard's action key does on the last field.
  static void pressCurrent() {
    for (final b in _mounted) {
      if (b.mounted && (ModalRoute.of(b.context)?.isCurrent ?? true)) {
        b.widget.onPressed();
        return;
      }
    }
  }

  @override
  State<CalculateButton> createState() => _CalculateButtonState();
}

class _CalculateButtonState extends State<CalculateButton> {
  VoidCallback get onPressed => widget.onPressed;
  String? get label => widget.label;

  @override
  void initState() {
    super.initState();
    CalculateButton._mounted.add(this);
  }

  @override
  void dispose() {
    CalculateButton._mounted.remove(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PressScale(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            FocusManager.instance.primaryFocus?.unfocus();
            onPressed();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calculate_rounded, size: 23),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label ?? AppStrings.get('calculate'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact visual identity for each calculator. The generated material image
/// makes it immediately clear which estimate the user is filling out.
class CalculatorToolHeader extends StatelessWidget {
  final String title;
  final String imageAsset;
  final Color color;
  final double imageWidth;
  final double imageHeight;

  const CalculatorToolHeader({
    super.key,
    required this.title,
    required this.imageAsset,
    required this.color,
    this.imageWidth = 54,
    this.imageHeight = 92,
  });

  @override
  Widget build(BuildContext context) {
    final displayWidth = imageWidth < 170 ? 170.0 : imageWidth;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Center(
        child: SizedBox(
          width: displayWidth,
          height: imageHeight,
          child: Image.asset(imageAsset, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

/// Hero result card for main quantity.
class HeroResultCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  /// Small line under the number — e.g. the exact figure behind a
  /// rounded-up buying quantity.
  final String? caption;

  /// When set, the number counts up from zero to this, drawn with
  /// [countFormat]; [value] stays the final text for screen readers.
  final double? countTo;
  final String Function(double value)? countFormat;

  const HeroResultCard({
    super.key,
    required this.label,
    required this.value,
    this.icon = Icons.calculate_outlined,
    this.color,
    this.caption,
    this.countTo,
    this.countFormat,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cardColor, cardColor.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Semantics(
            label: value,
            excludeSemantics: true,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: countTo != null && countFormat != null
                  ? CountUpText(
                      value: countTo!,
                      format: countFormat!,
                      style: _valueStyle,
                    )
                  : Text(value, style: _valueStyle),
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 2),
            Text(
              caption!,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}

const TextStyle _valueStyle = TextStyle(
  color: Colors.white,
  fontSize: 42,
  fontWeight: FontWeight.w700,
  letterSpacing: -1,
);

/// Row showing a label : value pair in results.
class ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;
  final Widget? helpWidget;

  /// Small line under the label — e.g. the exact figure behind a rounded-up
  /// buying quantity.
  final String? note;

  const ResultRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
    this.helpWidget,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                      if (note != null)
                        Text(
                          note!,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                if (helpWidget != null) ...[
                  const SizedBox(width: 4),
                  helpWidget!,
                ],
              ],
            ),
          ),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: TextStyle(
                  color: valueColor ?? AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `हिसाब: 7.3` — the exact figure shown beside a rounded-up buying quantity.
String exactNote(double value) =>
    '${AppStrings.get('exactCalc')}: ${value.toStringAsFixed(1)}';

/// Cost section card showing estimated cost.
class CostCard extends StatelessWidget {
  final double totalCost;
  final List<CostItem> items;

  const CostCard({super.key, required this.totalCost, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.costBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.costHighlight.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.costHighlight.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.currency_rupee,
                  color: AppColors.costHighlight,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppStrings.get('estimatedCost'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.costHighlight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        IndianFormatter.formatCurrency(item.cost),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'कुल / Total',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.costHighlight,
                  ),
                ),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    IndianFormatter.formatCurrency(totalCost),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.costHighlight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CostItem {
  final String label;
  final double cost;
  const CostItem(this.label, this.cost);
}

/// Disclaimer footer in Hindi.
class DisclaimerFooter extends StatelessWidget {
  const DisclaimerFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Text(
        AppStrings.get('disclaimer'),
        style: TextStyle(
          color: AppColors.textHint,
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Section header with optional label.
class SectionLabel extends StatelessWidget {
  final String title;

  const SectionLabel({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(2, 8, 2, 8),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Share & Copy action buttons row.
class ShareCopyButtons extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onCopy;

  const ShareCopyButtons({
    super.key,
    required this.onShare,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share_outlined),
            label: Text(
              AppStrings.get('share'),
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onCopy,
            icon: const Icon(Icons.copy_outlined),
            label: Text(
              AppStrings.get('copy'),
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: BorderSide(color: AppColors.cardBorder),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
