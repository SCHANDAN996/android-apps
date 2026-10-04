import 'package:flutter/material.dart';
import '../core/constants/strings.dart';
import 'shared_widgets.dart';

/// A length the way it is said on site.
///
/// In feet it is two boxes — "10 ft 6 in" — because nobody measures a wall as
/// 10.5 ft. In any other unit it is one ordinary box.
///
/// Either way [controller] holds a single plain number in [unit] (decimal feet
/// for the two-box form), so a screen reads it with `double.tryParse` and never
/// needs to know which form was shown.
class LengthField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String unit;
  final ValueChanged<String>? onChanged;

  const LengthField({
    super.key,
    required this.controller,
    required this.label,
    required this.unit,
    this.onChanged,
  });

  @override
  State<LengthField> createState() => _LengthFieldState();
}

class _LengthFieldState extends State<LengthField> {
  final _feet = TextEditingController();
  final _inches = TextEditingController();

  /// True while this widget itself is writing to [LengthField.controller].
  bool _writing = false;

  bool get _split => widget.unit == 'ft';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onOuterChanged);
    _showOuterValue();
  }

  @override
  void didUpdateWidget(LengthField old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onOuterChanged);
      widget.controller.addListener(_onOuterChanged);
    }
    if (old.unit != widget.unit || old.controller != widget.controller) {
      _showOuterValue();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onOuterChanged);
    _feet.dispose();
    _inches.dispose();
    super.dispose();
  }

  /// The screen changed the value itself (cleared the form, say).
  void _onOuterChanged() {
    if (!_writing) _showOuterValue();
  }

  /// Splits the controller's decimal feet into the two boxes.
  void _showOuterValue() {
    final (feet, inches) = splitFeet(double.tryParse(widget.controller.text));
    _feet.text = feet;
    _inches.text = inches;
  }

  void _onBoxChanged(String _) {
    final feet = double.tryParse(_feet.text) ?? 0;
    final inches = double.tryParse(_inches.text) ?? 0;
    final total = feet + inches / 12;
    _writing = true;
    widget.controller.text = total > 0 ? _trim(total) : '';
    _writing = false;
    widget.onChanged?.call(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    if (!_split) {
      return LargeInputField(
        controller: widget.controller,
        label: widget.label,
        suffix: widget.unit,
        onChanged: widget.onChanged,
      );
    }
    bool empty() => (double.tryParse(widget.controller.text) ?? 0) <= 0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: LargeInputField(
            controller: _feet,
            label: '${widget.label} (ft)',
            suffix: 'ft',
            onChanged: _onBoxChanged,
            // "0 ft 9 in" is a fine length — only an empty pair is missing.
            needsValue: empty,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: LargeInputField(
            controller: _inches,
            label: AppStrings.get('unitInch'),
            suffix: 'in',
            onChanged: _onBoxChanged,
            needsValue: () => false,
          ),
        ),
      ],
    );
  }
}

String _trim(double v) {
  final s = v.toStringAsFixed(4);
  return s.contains('.') ? s.replaceFirst(RegExp(r'\.?0+$'), '') : s;
}

/// Decimal feet as the two box texts: 10.5 → ("10", "6").
(String, String) splitFeet(double? decimalFeet) {
  if (decimalFeet == null || decimalFeet <= 0) return ('', '');
  var feet = decimalFeet.floor();
  // Inches to one decimal, so 10.5833 ft reads 7 in, not 6.9996.
  var inches = ((decimalFeet - feet) * 12 * 10).round() / 10;
  if (inches >= 12) {
    feet += 1;
    inches = 0;
  }
  return (
    feet == 0 && inches > 0 ? '' : '$feet',
    inches == 0 ? '' : _trim(inches),
  );
}

/// A length for the share text and the saved project: "10 ft 6 in", "10 ft",
/// "9 in", "3.2 m". [text] is what a [LengthField]'s controller holds.
String lengthLabel(String text, String unit) {
  if (unit != 'ft') return '$text $unit';
  final (feet, inches) = splitFeet(double.tryParse(text));
  if (feet.isEmpty && inches.isEmpty) return '$text ft';
  return [
    if (feet.isNotEmpty) '$feet ft',
    if (inches.isNotEmpty) '$inches in',
  ].join(' ');
}
