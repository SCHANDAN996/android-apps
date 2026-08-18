/// Customer model for दूधवाला mode — represents a milk delivery customer.
class Customer {
  final int? id;
  final String name;
  final String? phone;
  final double defaultQtyL;
  final String rateType; // 'flat' or 'fat'
  final double flatRate;
  final int active;

  const Customer({
    this.id,
    required this.name,
    this.phone,
    this.defaultQtyL = 1.0,
    this.rateType = 'flat',
    this.flatRate = 0.0,
    this.active = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'defaultQtyL': defaultQtyL,
      'rateType': rateType,
      'flatRate': flatRate,
      'active': active,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      defaultQtyL: (map['defaultQtyL'] as num?)?.toDouble() ?? 1.0,
      rateType: map['rateType'] as String? ?? 'flat',
      flatRate: (map['flatRate'] as num?)?.toDouble() ?? 0.0,
      active: map['active'] as int? ?? 1,
    );
  }

  Customer copyWith({
    int? id,
    String? name,
    String? phone,
    double? defaultQtyL,
    String? rateType,
    double? flatRate,
    int? active,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      defaultQtyL: defaultQtyL ?? this.defaultQtyL,
      rateType: rateType ?? this.rateType,
      flatRate: flatRate ?? this.flatRate,
      active: active ?? this.active,
    );
  }
}
