/// Customer / Party model — represents a milk buyer, supplier, or dual-role party.
class Customer {
  final int? id;
  final String name;
  final String? phone;
  final String? address; // गाँव/पता (optional)
  final double defaultQtyL;
  final String rateType; // 'flat' or 'fat'
  final double flatRate;
  final double ratePerFatPoint; // per-customer fat rate
  final String partyType; // 'buyer', 'supplier', 'both'
  final int active;

  const Customer({
    this.id,
    required this.name,
    this.phone,
    this.address,
    this.defaultQtyL = 1.0,
    this.rateType = 'flat',
    this.flatRate = 0.0,
    this.ratePerFatPoint = 6.8,
    this.partyType = 'buyer',
    this.active = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'defaultQtyL': defaultQtyL,
      'rateType': rateType,
      'flatRate': flatRate,
      'ratePerFatPoint': ratePerFatPoint,
      'partyType': partyType,
      'active': active,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      defaultQtyL: (map['defaultQtyL'] as num?)?.toDouble() ?? 1.0,
      rateType: map['rateType'] as String? ?? 'flat',
      flatRate: (map['flatRate'] as num?)?.toDouble() ?? 0.0,
      ratePerFatPoint: (map['ratePerFatPoint'] as num?)?.toDouble() ?? 6.8,
      partyType: map['partyType'] as String? ?? 'buyer',
      active: map['active'] as int? ?? 1,
    );
  }

  Customer copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
    double? defaultQtyL,
    String? rateType,
    double? flatRate,
    double? ratePerFatPoint,
    String? partyType,
    int? active,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      defaultQtyL: defaultQtyL ?? this.defaultQtyL,
      rateType: rateType ?? this.rateType,
      flatRate: flatRate ?? this.flatRate,
      ratePerFatPoint: ratePerFatPoint ?? this.ratePerFatPoint,
      partyType: partyType ?? this.partyType,
      active: active ?? this.active,
    );
  }
}
