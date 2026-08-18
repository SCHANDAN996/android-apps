/// Indian number formatting (1,00,000 system) and ₹ currency.
class IndianFormatter {
  /// Format a number in Indian system: 1,23,456 or 1,23,456.78
  static String format(double value, {int decimals = 0}) {
    if (value < 0) return '-${format(-value, decimals: decimals)}';

    String intPart;
    String decPart = '';

    if (decimals > 0) {
      final parts = value.toStringAsFixed(decimals).split('.');
      intPart = parts[0];
      decPart = '.${parts[1]}';
    } else {
      intPart = value.round().toString();
    }

    // Apply Indian grouping: last 3 digits, then groups of 2
    if (intPart.length <= 3) {
      return '$intPart$decPart';
    }

    final lastThree = intPart.substring(intPart.length - 3);
    String remaining = intPart.substring(0, intPart.length - 3);

    // Group remaining digits in pairs from right
    final buffer = StringBuffer();
    while (remaining.length > 2) {
      buffer.write('${remaining.substring(remaining.length - 2)},');
      remaining = remaining.substring(0, remaining.length - 2);
    }
    if (remaining.isNotEmpty) {
      buffer.write('$remaining,');
    }

    // Reverse the groups
    final groups = buffer.toString().split(',').reversed.where((s) => s.isNotEmpty).toList();
    final formatted = '${groups.join(',')},$lastThree';

    return '$formatted$decPart';
  }

  /// Format as ₹ currency in Indian format
  static String formatCurrency(double value, {int decimals = 0}) {
    return '₹${format(value, decimals: decimals)}';
  }

  /// Format number with auto-decimal (show decimals only if needed)
  static String formatAuto(double value) {
    if (value == value.roundToDouble()) {
      return format(value, decimals: 0);
    }
    return format(value, decimals: 2);
  }
}
