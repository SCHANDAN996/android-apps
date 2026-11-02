/// वेंडर की दर्ज की हुई शिकायत की स्थिति।
enum ComplaintStatus { sent, visitScheduled, resolved }

extension ComplaintStatusText on ComplaintStatus {
  String get label {
    switch (this) {
      case ComplaintStatus.sent:
        return 'भेजी गई';
      case ComplaintStatus.visitScheduled:
        return 'विज़िट तय';
      case ComplaintStatus.resolved:
        return 'निपट गई';
    }
  }
}

/// वेंडर अपने ग्राहक की शिकायत हमें भेजता है।
class VendorComplaint {
  const VendorComplaint({
    required this.id,
    required this.customerName,
    required this.customerMobile,
    required this.address,
    required this.area,
    required this.systemKw,
    required this.problem,
    required this.complaintDate,
    required this.createdAt,
    this.portalComplaintId = '',
    this.urgent = false,
    this.note = '',
    this.status = ComplaintStatus.sent,
  });

  /// जैसे VC-0211-1934
  final String id;
  final String customerName;
  final String customerMobile;
  final String address;
  final String area;
  final int systemKw;
  final String problem;

  /// ग्राहक ने शिकायत कब की (पोर्टल की 8 दिन की गिनती इसी से)।
  final DateTime complaintDate;
  final String portalComplaintId;

  /// 48 घंटे में विज़िट चाहिए।
  final bool urgent;
  final String note;
  final DateTime createdAt;
  final ComplaintStatus status;

  /// शिकायत की तारीख से आज तक कितने दिन बीते।
  int daysSinceComplaint([DateTime? now]) {
    final today = now ?? DateTime.now();
    final a = DateTime(complaintDate.year, complaintDate.month, complaintDate.day);
    final b = DateTime(today.year, today.month, today.day);
    return b.difference(a).inDays;
  }

  VendorComplaint copyWith({ComplaintStatus? status}) => VendorComplaint(
        id: id,
        customerName: customerName,
        customerMobile: customerMobile,
        address: address,
        area: area,
        systemKw: systemKw,
        problem: problem,
        complaintDate: complaintDate,
        createdAt: createdAt,
        portalComplaintId: portalComplaintId,
        urgent: urgent,
        note: note,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerName': customerName,
        'customerMobile': customerMobile,
        'address': address,
        'area': area,
        'systemKw': systemKw,
        'problem': problem,
        'complaintDate': complaintDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'portalComplaintId': portalComplaintId,
        'urgent': urgent,
        'note': note,
        'status': status.name,
      };

  factory VendorComplaint.fromJson(Map<String, dynamic> j) => VendorComplaint(
        id: j['id'] as String? ?? '',
        customerName: j['customerName'] as String? ?? '',
        customerMobile: j['customerMobile'] as String? ?? '',
        address: j['address'] as String? ?? '',
        area: j['area'] as String? ?? '',
        systemKw: (j['systemKw'] as num?)?.toInt() ?? 3,
        problem: j['problem'] as String? ?? '',
        complaintDate: DateTime.tryParse(j['complaintDate'] as String? ?? '') ?? DateTime.now(),
        createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
        portalComplaintId: j['portalComplaintId'] as String? ?? '',
        urgent: j['urgent'] as bool? ?? false,
        note: j['note'] as String? ?? '',
        status: ComplaintStatus.values.firstWhere(
          (s) => s.name == j['status'],
          orElse: () => ComplaintStatus.sent,
        ),
      );
}
