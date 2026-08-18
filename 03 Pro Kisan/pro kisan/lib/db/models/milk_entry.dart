/// MilkEntry model — one daily milk entry (subah / shaam) with trade direction ('sell' or 'buy').
class MilkEntry {
  final int? id;
  final int? customerId; // null in किसान mode
  final String date; // DD-MM-YYYY
  final String shift; // 'M' (morning/subah) or 'E' (evening/shaam)
  final double qtyL; // litres
  final double? fatPct; // fat percentage (optional)
  final double? snf; // SNF (optional)
  final double amount; // computed at entry time
  final String direction; // 'sell' (बिक्री) or 'buy' (खरीद)

  const MilkEntry({
    this.id,
    this.customerId,
    required this.date,
    required this.shift,
    required this.qtyL,
    this.fatPct,
    this.snf,
    required this.amount,
    this.direction = 'sell',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'customerId': customerId,
      'date': date,
      'shift': shift,
      'qtyL': qtyL,
      'fatPct': fatPct,
      'snf': snf,
      'amount': amount,
      'direction': direction,
    };
  }

  factory MilkEntry.fromMap(Map<String, dynamic> map) {
    return MilkEntry(
      id: map['id'] as int?,
      customerId: map['customerId'] as int?,
      date: map['date'] as String,
      shift: map['shift'] as String,
      qtyL: (map['qtyL'] as num).toDouble(),
      fatPct: (map['fatPct'] as num?)?.toDouble(),
      snf: (map['snf'] as num?)?.toDouble(),
      amount: (map['amount'] as num).toDouble(),
      direction: map['direction'] as String? ?? 'sell',
    );
  }

  MilkEntry copyWith({
    int? id,
    int? customerId,
    String? date,
    String? shift,
    double? qtyL,
    double? fatPct,
    double? snf,
    double? amount,
    String? direction,
  }) {
    return MilkEntry(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      date: date ?? this.date,
      shift: shift ?? this.shift,
      qtyL: qtyL ?? this.qtyL,
      fatPct: fatPct ?? this.fatPct,
      snf: snf ?? this.snf,
      amount: amount ?? this.amount,
      direction: direction ?? this.direction,
    );
  }
}
