/// लंबाई एवं नाप इकाइयों का डेटा — सभी मान फीट (Feet) में आधारित हैं।
class LengthUnit {
  final String hi;
  final String en;
  final double feet;

  const LengthUnit(this.hi, this.en, this.feet);

  String get label => '$hi ($en)';
}

/// लंबाई की प्रचलित एवं मानक इकाइयाँ
const List<LengthUnit> lengthUnits = [
  LengthUnit('सेंटीमीटर', 'Centimeter', 1 / 30.48),
  LengthUnit('इंच', 'Inch', 1 / 12),
  LengthUnit('बित्ता', 'Beetta / Span', 0.75),
  LengthUnit('हाथ', 'Haath / Cubit', 1.5),
  LengthUnit('कड़ी (जरीब की)', 'Kadi / Link', 0.66),
  LengthUnit('फीट', 'Feet', 1),
  LengthUnit('गज', 'Gaj / Yard', 3),
  LengthUnit('मीटर', 'Meter', 3.28084),
  LengthUnit('लाठी / लट्ठा (5.5 हाथ)', 'Latha / Laggi', 8.25),
  LengthUnit('जरीब (Chain)', 'Jarib / Chain', 66),
  LengthUnit('किलोमीटर', 'Kilometer', 3280.84),
  LengthUnit('मील', 'Mile', 5280),
];
