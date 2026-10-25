# Data Safety — 25 अक्टूबर की भराई का आधार

उपयोगकर्ता ने अब review/publish तक अनुमति दी है। पुराने रोकने के निर्देश का स्थान नवीनतम अनुमति ने लिया।

- Collected/shared: Yes। In-app search history: Collected + Shared, optional, not ephemeral; उद्देश्य app functionality दोनों तरफ। q सीधे Photon को जाता है। बिना प्रमाण service-provider या sharing exemption नहीं माना।
- Device or other IDs: Collected + Shared, optional, not ephemeral; उद्देश्य app functionality और fraud/security। यहाँ आधार HTTP अनुरोध में Photon को दिखने वाला IP है; Advertising ID/IMEI/Android ID लेने का दावा नहीं। यह Google की identifier परिभाषा के अनुसार IP/network identifier का सतर्क वर्गीकरण है; सभी IP requests को GPS/location कहना सही नहीं।
- GPS/precise location ऐप server को नहीं भेजता। कोड किसी IP से स्थान नहीं निकालता; Photon का प्रकाशित उत्तर request logs को service operation तक सीमित बताता है। इसलिए approximate/precise location संग्रह नहीं चुना। खोजे हुए जगह के नाम को in-app search history में बताया।
- HTTPS in transit Yes; no account creation; no external login; data deletion request mechanism No। ऐप का स्थानीय नाम/profile हटना server logs मिटाने की सेवा नहीं है। 90-day deletion badge नहीं चुना।
- कोई advertising/analytics/crash SDK या advertising identifier नहीं। कार्ड/UPI/बैंक डेटा PayU स्वयं बाहरी browser में लेता है और ऐप को नहीं मिलता; वित्तीय डेटा संग्रह नहीं चुना।
- उपयोगकर्ता द्वारा share किए संकल्प/कुंडली और Android system backup के लिए Google के user-initiated/external-backup अपवाद लागू करने का आधार है; इन्हें पॉलिसी §2क/2a में बताया।

मुख्य स्रोत:
https://support.google.com/googleplay/android-developer/answer/10787469?hl=en-EN — definitions, IP FAQ, payment and backup exceptions।
https://github.com/komoot/photon/discussions/539 — lonvia, 16 फरवरी 2021: endpoint request logs सीमित अवधि तक operation के लिए; exact वर्तमान दिन संख्या नहीं दी। इसलिए ephemeral processing का Yes नहीं चुना।
https://photon.komoot.io/ — official API/terms।
https://www.komoot.com/privacy — general policy; 90 days को Photon-specific retention का निश्चित प्रमाण नहीं माना।
app/lib/services/osm_khoj.dart:105 और 282 — q, fixed India bounding box, User-Agent app version; कोई user GPS/name/DOB नहीं।

26 अक्टूबर: घोषणा Console में Save करके अंतिम code8, listing और screenshots के साथ Google समीक्षा में भेजी; Changes in review में verified है। यह Google approval या स्वतंत्र कानूनी certification नहीं है।
