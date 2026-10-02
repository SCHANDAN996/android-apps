/// दुर्गा सप्तशती का क्रम — कवच, अर्गला, कीलक, फिर तीन चरित्रों में तेरह
/// अध्याय (→ D-084)।
///
/// ढाँचा अब [GranthKram] है — गीता आने पर वही चीज़ एक नाम ऊपर उठाई गई
/// (→ D-098)। पुराने नाम यहाँ इसलिए बचे हैं कि सप्तशती का कोड और उसकी
/// जाँचें जैसी थीं वैसी चलती रहें।
library;

import 'granth.dart';

export 'granth.dart' show GranthHissa, GranthKram, GranthPaath;

/// पूरी सप्तशती का क्रम — `assets/paath/saptashati/_kram.json`।
typedef SaptashatiKram = GranthKram;

/// एक हिस्सा — "पाठ से पहले", "प्रथम चरित्र — महाकाली"…
typedef SaptashatiHissa = GranthHissa;

/// क्रम में एक पाठ — नाम सूची में दिखाने के लिए, पूरा पाठ खोलने पर आता है।
typedef SaptashatiPaath = GranthPaath;
