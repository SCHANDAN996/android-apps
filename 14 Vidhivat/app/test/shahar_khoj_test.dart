import 'package:flutter_test/flutter_test.dart';
import 'package:vidhivat/state/shahar.dart';

/// जन्म-स्थान / शहर की खोज — अंग्रेज़ी अक्षरों में लिखा नाम भी मिले
/// (डेवलपर के फ़ोन पर पकड़ा, 18 अक्टूबर 2026: "Delhi" से कुछ नहीं मिलता था)।
void main() {
  String pehla(String khoj) => shaharKhojo(khoj).first.name;

  test('अंग्रेज़ी में लिखे बड़े शहर — पहला सुझाव वही शहर', () {
    const jode = {
      'Delhi': 'दिल्ली',
      'delhi': 'दिल्ली',
      'Mumbai': 'मुंबई',
      'Kolkata': 'कोलकाता',
      'Calcutta': 'कोलकाता',
      'Chennai': 'चेन्नई',
      'Bengaluru': 'बेंगलुरु',
      'Bangalore': 'बेंगलुरु',
      'Hyderabad': 'हैदराबाद',
      'Pune': 'पुणे',
      'Ahmedabad': 'अहमदाबाद',
      'Lucknow': 'लखनऊ',
      'Varanasi': 'वाराणसी',
      'Prayagraj': 'प्रयागराज',
      'Chandigarh': 'चंडीगढ़',
      'Vijayawada': 'विजयवाड़ा',
      'Ranchi': 'राँची',
      'Rishikesh': 'ऋषिकेश',
      'Vrindavan': 'वृंदावन',
      'Thiruvananthapuram': 'तिरुवनंतपुरम',
      'Nashik': 'नासिक',
      'Panipat': 'पानीपत',
    };
    jode.forEach((angrezi, naam) {
      expect(pehla(angrezi), naam, reason: angrezi);
    });
  });

  test('लिखते-लिखते भी सुझाव आते हैं — आधा नाम', () {
    expect(shaharKhojo('Del').map((c) => c.name), contains('दिल्ली'));
    expect(shaharKhojo('Varan').map((c) => c.name), contains('वाराणसी'));
  });

  test('देवनागरी में लिखना पहले जैसा', () {
    expect(pehla('दिल्ली'), 'दिल्ली');
    expect(shaharKhojo('बिहार').every((c) => c.state == 'बिहार' || c.name.contains('बिहार')),
        isTrue);
  });

  test('ख़ाली खोज पर पूरी सूची, सिर्फ़ स्वर पर कुछ नहीं', () {
    expect(shaharKhojo('  '), hasLength(indianCities.length));
    expect(shaharKhojo('aei'), isEmpty);
  });

  test('ढाँचा: नुक़्ता अलग चिह्न हो या जुड़ा अक्षर, एक ही', () {
    expect(devDhanche('चंडीगढ़'), devDhanche('चंडीगढ़'));
    expect(romanDhancha('Delhi'), 'dl');
    expect(devDhanche('दिल्ली'), ['dl']);
  });
}
