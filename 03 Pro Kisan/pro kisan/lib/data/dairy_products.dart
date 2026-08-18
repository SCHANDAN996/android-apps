import 'package:flutter/material.dart';

/// Dairy product conversion data — दूध से बनने वाले प्रोडक्ट।
///
/// नाम/विवरण हिंदी + English दोनों में — बाक़ी भाषाएँ app के नियम के अनुसार
/// हिंदी पर fallback करती हैं (isHindiLike)।
class DairyProduct {
  final String id;
  final String nameHi;
  final String nameEn;
  final double milkToProductRatio; // X लीटर दूध → 1 kg product
  final double defaultPricePerKg;
  final IconData icon;
  final String descriptionHi;
  final String descriptionEn;
  final Color color;

  const DairyProduct({
    required this.id,
    required this.nameHi,
    required this.nameEn,
    required this.milkToProductRatio,
    required this.defaultPricePerKg,
    required this.icon,
    required this.descriptionHi,
    required this.descriptionEn,
    required this.color,
  });

  String name(bool isHi) => isHi ? nameHi : nameEn;
  String description(bool isHi) => isHi ? descriptionHi : descriptionEn;

  /// Calculate how much product can be made from given milk quantity.
  double productFromMilk(double milkLitres) => milkLitres / milkToProductRatio;

  /// Calculate how much milk is needed for given product quantity.
  double milkForProduct(double productKg) => productKg * milkToProductRatio;
}

const List<DairyProduct> kDairyProducts = [
  DairyProduct(
    id: 'khova',
    nameHi: 'खोवा (मावा)',
    nameEn: 'Khoya (Mawa)',
    milkToProductRatio: 5.0, // 5 ली दूध → 1 kg खोवा
    defaultPricePerKg: 350,
    icon: Icons.breakfast_dining_rounded,
    descriptionHi:
        'दूध को उबालकर गाढ़ा करें जब तक ठोस न हो जाए।\nत्योहारों में भारी माँग — मिठाई बनाने में काम आता है।',
    descriptionEn:
        'Boil and thicken milk until solid.\nHigh demand in festivals — used for sweets.',
    color: Color(0xFF8D6E63),
  ),
  DairyProduct(
    id: 'paneer',
    nameHi: 'पनीर',
    nameEn: 'Paneer',
    milkToProductRatio: 6.0, // 6 ली → 1 kg
    defaultPricePerKg: 320,
    icon: Icons.set_meal_rounded,
    descriptionHi:
        'गर्म दूध में नींबू/सिरका डालकर छान लें।\nदूध जितना फैट वाला, पनीर उतना ज्यादा बनेगा।',
    descriptionEn:
        'Curdle hot milk with lemon/vinegar and strain.\nHigher fat milk gives more paneer.',
    color: Color(0xFFFFF176),
  ),
  DairyProduct(
    id: 'ghee',
    nameHi: 'घी',
    nameEn: 'Ghee',
    milkToProductRatio: 25.0, // 25 ली → 1 kg
    defaultPricePerKg: 600,
    icon: Icons.local_fire_department_rounded,
    descriptionHi: 'दूध → दही → मक्खन → घी। देसी गाय का घी सबसे कीमती।',
    descriptionEn: 'Milk → curd → butter → ghee. Desi cow ghee is the most valuable.',
    color: Color(0xFFFFB74D),
  ),
  DairyProduct(
    id: 'dahi',
    nameHi: 'दही',
    nameEn: 'Dahi (Curd)',
    milkToProductRatio: 1.0, // 1 ली → ~1 kg
    defaultPricePerKg: 80,
    icon: Icons.icecream_rounded,
    descriptionHi: 'गर्म दूध में जामन (दही) मिलाकर 6-8 घंटे रखें।',
    descriptionEn: 'Add culture (jaman) to warm milk and keep 6-8 hours.',
    color: Color(0xFFE0E0E0),
  ),
  DairyProduct(
    id: 'makhan',
    nameHi: 'मक्खन',
    nameEn: 'Makhan (Butter)',
    milkToProductRatio: 20.0, // 20 ली → 1 kg
    defaultPricePerKg: 500,
    icon: Icons.cake_rounded,
    descriptionHi: 'दही को मथकर (बिलोकर) मक्खन निकालें।',
    descriptionEn: 'Churn curd to extract butter.',
    color: Color(0xFFFFF59D),
  ),
  DairyProduct(
    id: 'chhena',
    nameHi: 'छेना',
    nameEn: 'Chhena',
    milkToProductRatio: 6.0, // 6 ली → 1 kg
    defaultPricePerKg: 300,
    icon: Icons.egg_rounded,
    descriptionHi: 'पनीर जैसा ही — लेकिन ज्यादा नरम। रसगुल्ला/रसमलाई बनता है।',
    descriptionEn: 'Like paneer but softer — used for rasgulla/rasmalai.',
    color: Color(0xFFFFCC80),
  ),
];

/// Get a dairy product by its ID.
DairyProduct? getDairyProductById(String id) {
  try {
    return kDairyProducts.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
}
