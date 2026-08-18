/// एक पशु — किसान की गाय/भैंस/बकरी का रिकॉर्ड।
///
/// तारीख़ें ISO (yyyy-MM-dd) string में रखी हैं (sqflite में DateTime नहीं होता)।
/// AI (कृत्रिम गर्भाधान) की तारीख़ से ब्याने की तारीख़ अपने आप निकलती है।
/// [photoPath] absolute filesystem path — नहीं तो null।
class Pashu {
  final int? id;
  final String name;
  final String type; // gaay | bhains | bakri
  final String tagNo;
  final String? aiDate;
  final String? calvingDate;
  final String? lastVaccineDate;
  final String note;
  final String? photoPath;
  final bool active;
  final String? createdAt;

  const Pashu({
    this.id,
    this.name = '',
    this.type = 'gaay',
    this.tagNo = '',
    this.aiDate,
    this.calvingDate,
    this.lastVaccineDate,
    this.note = '',
    this.photoPath,
    this.active = true,
    this.createdAt,
  });

  /// गाय ~283 दिन, भैंस ~310 दिन, बकरी ~150 दिन का गर्भकाल।
  static int gestationDays(String type) {
    switch (type) {
      case 'bhains':
        return 310;
      case 'bakri':
        return 150;
      default:
        return 283;
    }
  }

  /// AI की तारीख़ से अनुमानित ब्याने की तारीख़ (calvingDate भरा हो तो वही)।
  DateTime? get expectedCalving {
    if (calvingDate != null && calvingDate!.isNotEmpty) {
      return DateTime.tryParse(calvingDate!);
    }
    if (aiDate == null || aiDate!.isEmpty) return null;
    final ai = DateTime.tryParse(aiDate!);
    if (ai == null) return null;
    return ai.add(Duration(days: gestationDays(type)));
  }

  /// ब्याने में कितने दिन बचे (ऋणात्मक = तारीख़ निकल चुकी)।
  int? get daysToCalving {
    final c = expectedCalving;
    if (c == null) return null;
    final now = DateTime.now();
    return DateTime(c.year, c.month, c.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  /// नाम खाली हो तो fallback: "गाय #7" जैसा — DAO/UI इसे set कर देते हैं।
  /// इस getter में सिर्फ़ trim हुआ नाम लौटाता है।
  String get trimmedName => name.trim();

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'type': type,
        'tagNo': tagNo,
        'aiDate': aiDate,
        'calvingDate': calvingDate,
        'lastVaccineDate': lastVaccineDate,
        'note': note,
        'photoPath': photoPath,
        'active': active ? 1 : 0,
        'createdAt': createdAt ?? DateTime.now().toIso8601String(),
      };

  factory Pashu.fromMap(Map<String, dynamic> m) => Pashu(
        id: m['id'] as int?,
        name: (m['name'] ?? '') as String,
        type: (m['type'] ?? 'gaay') as String,
        tagNo: (m['tagNo'] ?? '') as String,
        aiDate: m['aiDate'] as String?,
        calvingDate: m['calvingDate'] as String?,
        lastVaccineDate: m['lastVaccineDate'] as String?,
        note: (m['note'] ?? '') as String,
        photoPath: m['photoPath'] as String?,
        active: (m['active'] ?? 1) == 1,
        createdAt: m['createdAt'] as String?,
      );

  Pashu copyWith({
    int? id,
    String? name,
    String? type,
    String? tagNo,
    String? aiDate,
    String? calvingDate,
    String? lastVaccineDate,
    String? note,
    String? photoPath,
    bool? active,
  }) =>
      Pashu(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        tagNo: tagNo ?? this.tagNo,
        aiDate: aiDate ?? this.aiDate,
        calvingDate: calvingDate ?? this.calvingDate,
        lastVaccineDate: lastVaccineDate ?? this.lastVaccineDate,
        note: note ?? this.note,
        photoPath: photoPath ?? this.photoPath,
        active: active ?? this.active,
        createdAt: createdAt,
      );
}
