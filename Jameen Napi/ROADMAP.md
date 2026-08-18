# जमीन नापी (Jameen Napi) — Launch & Feature Guide

Jameen Napi is an offline, specialized Land Area and Plot Length Converter & Field Measurement Calculator tailored for Indian states, revenue records, farmers, and land amins/patwaris.

## Dedicated Tools Included (v1.0.4)
1. **भूमि क्षेत्रफल कन्वर्टर (Land Area Converter)**
   - 13 राज्य groups + मानक इकाइयाँ (बीघा, कट्ठा, धूर, बिस्वा, मरला, कनाल, किल्ला, गुंठा, सेंट, ग्राउंड, नाली, एकड़, हेक्टेयर, गज, डिसमिल, वर्ग फीट/मीटर).
   - डायरेक्ट क्षेत्रफल मोड + लंबाई × चौड़ाई ($L \times W$) मोड।
   - Quick increment chips (+1, +5, +10, Clear).
   - Copy & WhatsApp share functionality.
2. **4-भुजा खेत नापी / विषमबाहु खेत (4-Sided Irregular Plot)**
   - 4 असमान भुजाएं (A, B, C, D) + विकर्ण (Diagonal) के साथ हेरॉन सूत्र (Heron's Formula) द्वारा 100% सटीक क्षेत्रफल।
   - औसत विधि (Average Method) का भी विकल्प।
   - Interactive Visual Canvas (`QuadrilateralPlotPainter`) खेत का नक्शा।
3. **प्लाट / लंबाई नाप कन्वर्टर (Plot / Length Converter)**
   - फीट, गज (Yard), मीटर, लाठी/लट्ठा (5.5 हाथ), हाथ (Haath = 1.5 ft), बित्ता (Beetta), कड़ी (Link), जरीब (Chain = 66 ft = 100 कड़ी), किलोमीटर, मील, इंच, सेंटीमीटर।
4. **लग्गी / धुर-कट्ठा पैमाना कैलकुलेटर (Laggi & Scale Customizer)**
   - 4.0 से 9.0 हाथ तक की लग्गी से 1 धुर, 1 कट्ठा, 1 बीघा, 1 एकड़ और 1 डिसमिल का सटीक मान।
5. **जमीन बंटवारा कैलकुलेटर (Land Share / Partition)**
   - कुल रकबा हिस्सेदारों/भाइयों में बराबर या कस्टम अनुपात/प्रतिशत अनुसार बांटें।
6. **त्रिकोणीय खेत नापी (Triangular Plot Area)**
   - 3 भुजाएं (हेरॉन सूत्र) या आधार × ऊंचाई ($0.5 \times \text{Base} \times \text{Height}$) के साथ विजुअल त्रिभुज स्केच।

---
## Tech Architecture
- **Offline calculations**: सारी नाप-गणना फोन में ही होती है, कोई नाप कहीं नहीं भेजी जाती।
- **AdMob**: Banner + Interstitial (debug में अपने आप Google Test Unit IDs)।
  इसके लिए `INTERNET`, `ACCESS_NETWORK_STATE`, `AD_ID` और Ad Services परमिशन
  SDK अपने आप जोड़ता है — इसलिए "कोई परमिशन नहीं चाहिए" कहीं मत लिखिए
  (न listing में, न privacy policy में)। जाँच: `dart run tool/check_store_listing.dart`
- **कोई व्यक्तिगत डेटा नहीं**: नाम, नंबर, लोकेशन, कॉन्टैक्ट कुछ नहीं माँगा जाता।
- **9 भाषाएँ**: पहली बार खुलने पर फोन की भाषा पकड़ता है (`resolveStartupLanguage`)।
  स्क्रीनों की strings `lib/data/tool_strings.dart` में हैं — नई string नौ की नौ
  भाषाओं में भरें, वरना test fail होगा।
- **Material 3 UI**: Clean agricultural green theme with responsive layouts.
