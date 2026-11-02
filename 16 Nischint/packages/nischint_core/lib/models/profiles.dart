/// ऐप किस भूमिका में चल रहा है।
enum AppRole { customer, vendor, technician }

/// घर वाले की जानकारी, अगली बुकिंग में अपने-आप भरने के लिए।
class CustomerProfile {
  const CustomerProfile({
    this.name = '',
    this.mobile = '',
    this.address = '',
    this.area = '',
    this.landmark = '',
    this.systemKw = 3,
  });

  final String name;
  final String mobile;
  final String address;
  final String area;
  final String landmark;
  final int systemKw;

  bool get isEmpty => name.isEmpty && mobile.isEmpty;

  Map<String, dynamic> toJson() => {
        'name': name,
        'mobile': mobile,
        'address': address,
        'area': area,
        'landmark': landmark,
        'systemKw': systemKw,
      };

  factory CustomerProfile.fromJson(Map<String, dynamic> j) => CustomerProfile(
        name: j['name'] as String? ?? '',
        mobile: j['mobile'] as String? ?? '',
        address: j['address'] as String? ?? '',
        area: j['area'] as String? ?? '',
        landmark: j['landmark'] as String? ?? '',
        systemKw: (j['systemKw'] as num?)?.toInt() ?? 3,
      );
}

/// वेंडर की फ़र्म की जानकारी।
class VendorProfile {
  const VendorProfile({
    this.firmName = '',
    this.contactPerson = '',
    this.mobile = '',
  });

  final String firmName;
  final String contactPerson;
  final String mobile;

  bool get isComplete => firmName.trim().isNotEmpty && mobile.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {
        'firmName': firmName,
        'contactPerson': contactPerson,
        'mobile': mobile,
      };

  factory VendorProfile.fromJson(Map<String, dynamic> j) => VendorProfile(
        firmName: j['firmName'] as String? ?? '',
        contactPerson: j['contactPerson'] as String? ?? '',
        mobile: j['mobile'] as String? ?? '',
      );
}

/// टेक्नीशियन (हमारी टीम) की जानकारी। v0.1 में फ़ोन में, v0.2 से सर्वर पर।
class TechnicianProfile {
  const TechnicianProfile({
    this.name = '',
    this.mobile = '',
    this.area = '',
    this.qualification = '',
    this.hasScooty = false,
    this.joinedAt,
  });

  final String name;
  final String mobile;
  final String area;

  /// जैसे "ITI इलेक्ट्रीशियन", "सूर्य मित्र", "10वीं/12वीं"।
  final String qualification;
  final bool hasScooty;
  final DateTime? joinedAt;

  bool get isComplete => name.trim().isNotEmpty && mobile.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {
        'name': name,
        'mobile': mobile,
        'area': area,
        'qualification': qualification,
        'hasScooty': hasScooty,
        'joinedAt': joinedAt?.toIso8601String(),
      };

  factory TechnicianProfile.fromJson(Map<String, dynamic> j) => TechnicianProfile(
        name: j['name'] as String? ?? '',
        mobile: j['mobile'] as String? ?? '',
        area: j['area'] as String? ?? '',
        qualification: j['qualification'] as String? ?? '',
        hasScooty: j['hasScooty'] as bool? ?? false,
        joinedAt: DateTime.tryParse(j['joinedAt'] as String? ?? ''),
      );
}
