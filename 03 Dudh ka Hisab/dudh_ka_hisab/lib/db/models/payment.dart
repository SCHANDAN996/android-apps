/// Payment model — records money received from a customer.
class Payment {
  final int? id;
  final int? customerId; // null in किसान mode
  final String date; // DD-MM-YYYY
  final double amount;
  final String note;

  const Payment({
    this.id,
    this.customerId,
    required this.date,
    required this.amount,
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'customerId': customerId,
      'date': date,
      'amount': amount,
      'note': note,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as int?,
      customerId: map['customerId'] as int?,
      date: map['date'] as String,
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] as String? ?? '',
    );
  }

  Payment copyWith({
    int? id,
    int? customerId,
    String? date,
    double? amount,
    String? note,
  }) {
    return Payment(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      note: note ?? this.note,
    );
  }
}
