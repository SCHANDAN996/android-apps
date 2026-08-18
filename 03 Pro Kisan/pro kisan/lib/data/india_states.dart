/// All Indian states + UTs, with the local बीघा size in square feet where the
/// unit is commonly used (null = बीघा not used; khaad module falls back to acre).
/// State selection (onboarding) drives bigha size, and later yojana/mandi filters.
class IndiaState {
  final String code; // stable key stored in settings
  final String hi;
  final String en;
  final double? bighaSqFt;

  const IndiaState(this.code, this.hi, this.en, [this.bighaSqFt]);
}

const List<IndiaState> kIndiaStates = [
  IndiaState('UP', 'उत्तर प्रदेश', 'Uttar Pradesh', 27000),
  IndiaState('BR', 'बिहार', 'Bihar', 27220),
  IndiaState('MP', 'मध्य प्रदेश', 'Madhya Pradesh', 12000),
  IndiaState('RJ', 'राजस्थान', 'Rajasthan', 27225),
  IndiaState('HR', 'हरियाणा', 'Haryana', 27225),
  IndiaState('PB', 'पंजाब', 'Punjab', 9070),
  IndiaState('UK', 'उत्तराखंड', 'Uttarakhand', 6804),
  IndiaState('HP', 'हिमाचल प्रदेश', 'Himachal Pradesh', 8712),
  IndiaState('JH', 'झारखंड', 'Jharkhand', 27220),
  IndiaState('WB', 'पश्चिम बंगाल', 'West Bengal', 14400),
  IndiaState('GJ', 'गुजरात', 'Gujarat', 17427),
  IndiaState('MH', 'महाराष्ट्र', 'Maharashtra'),
  IndiaState('CG', 'छत्तीसगढ़', 'Chhattisgarh', 12000),
  IndiaState('OD', 'ओडिशा', 'Odisha'),
  IndiaState('AS', 'असम', 'Assam', 14400),
  IndiaState('KA', 'कर्नाटक', 'Karnataka'),
  IndiaState('AP', 'आंध्र प्रदेश', 'Andhra Pradesh'),
  IndiaState('TS', 'तेलंगाना', 'Telangana'),
  IndiaState('TN', 'तमिलनाडु', 'Tamil Nadu'),
  IndiaState('KL', 'केरल', 'Kerala'),
  IndiaState('GA', 'गोवा', 'Goa'),
  IndiaState('JK', 'जम्मू-कश्मीर', 'Jammu & Kashmir'),
  IndiaState('DL', 'दिल्ली', 'Delhi'),
  IndiaState('PY', 'पुडुचेरी', 'Puducherry'),
  IndiaState('CH', 'चंडीगढ़', 'Chandigarh'),
  IndiaState('AR', 'अरुणाचल प्रदेश', 'Arunachal Pradesh'),
  IndiaState('MN', 'मणिपुर', 'Manipur'),
  IndiaState('ML', 'मेघालय', 'Meghalaya'),
  IndiaState('MZ', 'मिज़ोरम', 'Mizoram'),
  IndiaState('NL', 'नागालैंड', 'Nagaland'),
  IndiaState('SK', 'सिक्किम', 'Sikkim'),
  IndiaState('TR', 'त्रिपुरा', 'Tripura'),
  IndiaState('LA', 'लद्दाख', 'Ladakh'),
  IndiaState('AN', 'अंडमान-निकोबार', 'Andaman & Nicobar'),
  IndiaState('DN', 'दादरा-नगर हवेली एवं दमन-दीव', 'Dadra & Nagar Haveli and Daman & Diu'),
];

IndiaState stateByCode(String code) =>
    kIndiaStates.firstWhere((s) => s.code == code, orElse: () => kIndiaStates.first);
