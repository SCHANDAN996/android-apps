/// हिंदी तारीख और रुपये लिखने के छोटे काम।
library;

const List<String> _months = [
  'जनवरी', 'फ़रवरी', 'मार्च', 'अप्रैल', 'मई', 'जून',
  'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर',
];

const List<String> _weekdays = [
  'सोमवार', 'मंगलवार', 'बुधवार', 'गुरुवार', 'शुक्रवार', 'शनिवार', 'रविवार',
];

const List<String> _weekdaysShort = ['सोम', 'मंगल', 'बुध', 'गुरु', 'शुक्र', 'शनि', 'रवि'];

/// "2 नवंबर, सोमवार"
String hindiDate(DateTime d) => '${d.day} ${_months[d.month - 1]}, ${_weekdays[d.weekday - 1]}';

/// "2 नवंबर 2026"
String hindiDateYear(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

/// तारीख चिप के लिए: "आज", "कल" या "सोम 2"
String dateChipLabel(DateTime d, [DateTime? now]) {
  final today = _dayOnly(now ?? DateTime.now());
  final diff = _dayOnly(d).difference(today).inDays;
  if (diff == 0) return 'आज';
  if (diff == 1) return 'कल';
  return '${_weekdaysShort[d.weekday - 1]} ${d.day}';
}

/// आज से अगले [count] दिन (आज शामिल नहीं, कल से शुरू)।
List<DateTime> nextDays(int count, [DateTime? now]) {
  final today = _dayOnly(now ?? DateTime.now());
  return [for (var i = 1; i <= count; i++) today.add(Duration(days: i))];
}

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// भारतीय तरीके से रुपये: 2400 → "₹2,400", 125000 → "₹1,25,000"
String rupees(int amount) {
  final negative = amount < 0;
  var s = amount.abs().toString();
  if (s.length > 3) {
    final last3 = s.substring(s.length - 3);
    var rest = s.substring(0, s.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    s = '${parts.join(',')},$last3';
  }
  return '${negative ? '-' : ''}₹$s';
}

/// 10 अंक का भारतीय मोबाइल नंबर सही है या नहीं।
bool isValidMobile(String input) {
  final digits = input.replaceAll(RegExp(r'\D'), '');
  final n = digits.length == 12 && digits.startsWith('91') ? digits.substring(2) : digits;
  return RegExp(r'^[6-9]\d{9}$').hasMatch(n);
}
