import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/strings.dart';
import '../core/utils/indian_formatter.dart';

/// Large numeric input field with Hindi label — for construction inputs.
class LargeInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? suffix;
  final String? hint;
  final bool allowDecimal;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  const LargeInputField({
    super.key,
    required this.controller,
    required this.label,
    this.suffix,
    this.hint,
    this.allowDecimal = true,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.notoSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.notoSans(
          fontSize: 16,
          color: AppColors.textSecondary,
        ),
        hintText: hint,
        suffixText: suffix,
        suffixIcon: suffixIcon,
        suffixStyle: GoogleFonts.notoSans(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      inputFormatters: [
        if (allowDecimal)
          _SingleDecimalFormatter()
        else
          FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: onChanged,
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
    if (newValue.text.isEmpty || _valid.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}

/// Unit toggle dropdown (ft / m).
class UnitToggle extends StatelessWidget {
  final String value; // 'ft' or 'm'
  final ValueChanged<String> onChanged;

  const UnitToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

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
        children: [
          _UnitChip(
            label: AppStrings.get('feet'),
            isSelected: value == 'ft',
            onTap: () => onChanged('ft'),
          ),
          _UnitChip(
            label: AppStrings.get('meter'),
            isSelected: value == 'm',
            onTap: () => onChanged('m'),
          ),
        ],
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
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

  const OptionChips({
    super.key,
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isActive = option == selected;
        return GestureDetector(
          onTap: () => onSelected(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.cardBorder,
              ),
            ),
            child: Text(
              labelBuilder(option),
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Large calculate button with gradient.
class CalculateButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? label;

  const CalculateButton({
    super.key,
    required this.onPressed,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
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
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            label ?? AppStrings.get('calculate'),
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
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

  const HeroResultCard({
    super.key,
    required this.label,
    required this.value,
    this.icon = Icons.calculate_outlined,
    this.color,
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
            style: GoogleFonts.notoSans(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.notoSans(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Row showing a label : value pair in results.
class ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;
  final Widget? helpWidget;

  const ResultRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
    this.helpWidget,
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: GoogleFonts.notoSans(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (helpWidget != null) ...[
                  const SizedBox(width: 4),
                  helpWidget!,
                ],
              ],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.notoSans(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cost section card showing estimated cost.
class CostCard extends StatelessWidget {
  final double totalCost;
  final List<CostItem> items;

  const CostCard({
    super.key,
    required this.totalCost,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.costBackground,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.costHighlight.withValues(alpha: 0.3)),
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
                child: const Icon(
                  Icons.currency_rupee,
                  color: AppColors.costHighlight,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppStrings.get('estimatedCost'),
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.costHighlight,
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
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    IndianFormatter.formatCurrency(item.cost),
                    style: GoogleFonts.notoSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
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
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.costHighlight,
                  ),
                ),
              ),
              Text(
                IndianFormatter.formatCurrency(totalCost),
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.costHighlight,
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
        style: GoogleFonts.notoSans(
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        title,
        style: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
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
              style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
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
              style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.cardBorder),
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
