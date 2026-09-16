# जमीन नापी (Jameen Napi) — Launch & Feature Guide

Jameen Napi is an offline, specialized Land Area and Plot Length Converter & Field Measurement Calculator tailored for Indian states, revenue records, farmers, and land amins/patwaris.

## Dedicated Tools Included (v1.1.0)
1. **नक्शे / GPS से नापें (Map & GPS Measurement)**
   - Satellite/street map पर उंगली से खेत के कोने tap करके area या रास्ते की दूरी।
   - खेत के कोनों पर रुककर GPS readings का औसत, या टेढ़े खेत की continuous GPS boundary।
   - पैदल, बाइक या गाड़ी से रास्ते की distance tracking; pause के बाद अलग segment ताकि बीच की सीधी छलांग न जुड़े।
   - GPS accuracy, self-crossing boundary और छोटे खेत की error warning; saved measurements और सीधे बंटवारे में भेजने का विकल्प।
2. **भूमि क्षेत्रफल कन्वर्टर (Land Area Converter)**
   - 13 राज्य groups + मानक इकाइयाँ (बीघा, कट्ठा, धूर, बिस्वा, मरला, कनाल, किल्ला, गुंठा, सेंट, ग्राउंड, नाली, एकड़, हेक्टेयर, गज, डिसमिल, वर्ग फीट/मीटर).
   - डायरेक्ट क्षेत्रफल मोड + लंबाई × चौड़ाई ($L \times W$) मोड।
   - Quick increment chips (+1, +5, +10, Clear).
   - Copy & WhatsApp share functionality.
3. **4-भुजा खेत नापी / विषमबाहु खेत (4-Sided Irregular Plot)**
   - 4 असमान भुजाएं (A, B, C, D) + विकर्ण (Diagonal) के साथ हेरॉन सूत्र (Heron's Formula) द्वारा 100% सटीक क्षेत्रफल।
   - औसत विधि (Average Method) का भी विकल्प।
   - Interactive Visual Canvas (`QuadrilateralPlotPainter`) खेत का नक्शा।
4. **प्लाट / लंबाई नाप कन्वर्टर (Plot / Length Converter)**
   - फीट, गज (Yard), मीटर, लाठी/लट्ठा (5.5 हाथ), हाथ (Haath = 1.5 ft), बित्ता (Beetta), कड़ी (Link), जरीब (Chain = 66 ft = 100 कड़ी), किलोमीटर, मील, इंच, सेंटीमीटर।
5. **लग्गी / धुर-कट्ठा पैमाना कैलकुलेटर (Laggi & Scale Customizer)**
   - 4.0 से 9.0 हाथ तक की लग्गी से 1 धुर, 1 कट्ठा, 1 बीघा, 1 एकड़ और 1 डिसमिल का सटीक मान।
6. **जमीन बंटवारा कैलकुलेटर (Land Share / Partition)**
   - कुल रकबा हिस्सेदारों/भाइयों में बराबर या कस्टम अनुपात/प्रतिशत अनुसार बांटें।
7. **त्रिकोणीय खेत नापी (Triangular Plot Area)**
   - 3 भुजाएं (हेरॉन सूत्र) या आधार × ऊंचाई ($0.5 \times \text{Base} \times \text{Height}$) के साथ विजुअल त्रिभुज स्केच।

---
## Tech Architecture
- **Offline calculations**: सारी गणना और GPS boundaries फोन में ही रहती हैं, कहीं upload नहीं होतीं। Calculator और GPS walk measurement बिना internet चलते हैं; satellite/street map tiles और ads को internet चाहिए।
- **AdMob**: Banner + Interstitial (debug में अपने आप Google Test Unit IDs)।
  इसके लिए `INTERNET`, `ACCESS_NETWORK_STATE`, `AD_ID` और Ad Services परमिशन
  SDK अपने आप जोड़ता है — इसलिए "कोई परमिशन नहीं चाहिए" कहीं मत लिखिए
  (न listing में, न privacy policy में)। जाँच: `dart run tool/check_store_listing.dart`
- **Location permission**: GPS walk/road measurement और “मेरी जगह” के लिए foreground location permission मांगी जाती है; background location नहीं।
- **9 भाषाएँ**: पहली बार खुलने पर फोन की भाषा पकड़ता है (`resolveStartupLanguage`)।
  स्क्रीनों की strings `lib/data/tool_strings.dart` में हैं — नई string नौ की नौ
  भाषाओं में भरें, वरना test fail होगा।
- **Material 3 UI**: Clean agricultural green theme with responsive layouts.
