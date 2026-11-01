/// बुकिंग की स्थिति।
enum BookingStatus { sent, confirmed, done, cancelled }

extension BookingStatusText on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.sent:
        return 'भेजी गई';
      case BookingStatus.confirmed:
        return 'पक्की';
      case BookingStatus.done:
        return 'पूरी हुई';
      case BookingStatus.cancelled:
        return 'रद्द';
    }
  }
}

/// घर वाले की एक बुकिंग। फ़ोन में JSON बनकर सेव होती है।
class Booking {
  const Booking({
    required this.id,
    required this.serviceId,
    required this.serviceTitle,
    required this.customerName,
    required this.mobile,
    required this.address,
    required this.area,
    required this.systemKw,
    required this.date,
    required this.timeSlot,
    required this.estimatedPrice,
    required this.createdAt,
    this.landmark = '',
    this.problem = '',
    this.installerVendor = '',
    this.note = '',
    this.status = BookingStatus.sent,
  });

  /// जैसे NB-0211-4821
  final String id;
  final String serviceId;
  final String serviceTitle;
  final String customerName;
  final String mobile;
  final String address;
  final String area;
  final String landmark;

  /// सिस्टम का साइज़ kW में (6 = 5 से ज़्यादा)।
  final int systemKw;
  final String problem;
  final String installerVendor;
  final DateTime date;
  final String timeSlot;
  final String note;
  final int estimatedPrice;
  final DateTime createdAt;
  final BookingStatus status;

  Booking copyWith({BookingStatus? status}) => Booking(
        id: id,
        serviceId: serviceId,
        serviceTitle: serviceTitle,
        customerName: customerName,
        mobile: mobile,
        address: address,
        area: area,
        landmark: landmark,
        systemKw: systemKw,
        problem: problem,
        installerVendor: installerVendor,
        date: date,
        timeSlot: timeSlot,
        note: note,
        estimatedPrice: estimatedPrice,
        createdAt: createdAt,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceId': serviceId,
        'serviceTitle': serviceTitle,
        'customerName': customerName,
        'mobile': mobile,
        'address': address,
        'area': area,
        'landmark': landmark,
        'systemKw': systemKw,
        'problem': problem,
        'installerVendor': installerVendor,
        'date': date.toIso8601String(),
        'timeSlot': timeSlot,
        'note': note,
        'estimatedPrice': estimatedPrice,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
      };

  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
        id: j['id'] as String? ?? '',
        serviceId: j['serviceId'] as String? ?? '',
        serviceTitle: j['serviceTitle'] as String? ?? '',
        customerName: j['customerName'] as String? ?? '',
        mobile: j['mobile'] as String? ?? '',
        address: j['address'] as String? ?? '',
        area: j['area'] as String? ?? '',
        landmark: j['landmark'] as String? ?? '',
        systemKw: (j['systemKw'] as num?)?.toInt() ?? 3,
        problem: j['problem'] as String? ?? '',
        installerVendor: j['installerVendor'] as String? ?? '',
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
        timeSlot: j['timeSlot'] as String? ?? '',
        note: j['note'] as String? ?? '',
        estimatedPrice: (j['estimatedPrice'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
        status: BookingStatus.values.firstWhere(
          (s) => s.name == j['status'],
          orElse: () => BookingStatus.sent,
        ),
      );
}
