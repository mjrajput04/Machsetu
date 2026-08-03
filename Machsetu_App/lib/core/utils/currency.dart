/// Indian-grouping rupee formatting (lakh/crore), e.g. 159612.7 →
/// `₹1,59,612.70`.
///
/// Hand-rolled rather than pulled from `intl` so the app keeps a single
/// formatting rule and no extra dependency.
class Rupees {
  Rupees._();

  static const String symbol = '₹';

  /// Reads a pre-formatted price back into a number — `₹57,50,000` → 5750000.
  /// Returns 0 when the string carries no digits.
  static double parse(String formatted) {
    final cleaned = formatted.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  /// Formats with two decimals: 129895 → `₹1,29,895.00`.
  static String format(double amount) {
    final fixed = amount.toStringAsFixed(2);
    final parts = fixed.split('.');
    return '$symbol${_group(parts[0])}.${parts[1]}';
  }

  /// Formats without decimals: 5750000 → `₹57,50,000`.
  static String compact(double amount) {
    return '$symbol${_group(amount.round().toString())}';
  }

  /// Indian digit grouping — last three digits, then pairs.
  static String _group(String digits) {
    final negative = digits.startsWith('-');
    final body = negative ? digits.substring(1) : digits;
    if (body.length <= 3) return digits;

    final last3 = body.substring(body.length - 3);
    var rest = body.substring(0, body.length - 3);

    final groups = <String>[];
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) groups.insert(0, rest);

    return '${negative ? '-' : ''}${groups.join(',')},$last3';
  }
}
