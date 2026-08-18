/// Dairy product entry — record of product made from milk.
class DairyProductEntry {
  final int? id;
  final String productId;    // 'khova', 'paneer', etc.
  final String date;         // dd-MM-yyyy
  final double milkUsedL;    // दूध कितना लगा (लीटर)
  final double productQtyKg; // प्रोडक्ट कितना बना (kg)
  final double pricePerKg;   // बेचने का रेट (₹/kg)
  final double totalAmount;  // कुल रकम
  final String note;

  const DairyProductEntry({
    this.id,
    required this.productId,
    required this.date,
    required this.milkUsedL,
    required this.productQtyKg,
    this.pricePerKg = 0.0,
    this.totalAmount = 0.0,
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'productId': productId,
      'date': date,
      'milkUsedL': milkUsedL,
      'productQtyKg': productQtyKg,
      'pricePerKg': pricePerKg,
      'totalAmount': totalAmount,
      'note': note,
    };
  }

  factory DairyProductEntry.fromMap(Map<String, dynamic> map) {
    return DairyProductEntry(
      id: map['id'] as int?,
      productId: map['productId'] as String,
      date: map['date'] as String,
      milkUsedL: (map['milkUsedL'] as num).toDouble(),
      productQtyKg: (map['productQtyKg'] as num).toDouble(),
      pricePerKg: (map['pricePerKg'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      note: map['note'] as String? ?? '',
    );
  }
}
