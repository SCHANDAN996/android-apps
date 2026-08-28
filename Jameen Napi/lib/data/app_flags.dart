/// Build के वक़्त तय होने वाले flags.
library;

/// Play Store के screenshots लेते समय विज्ञापन नहीं दिखने चाहिए —
/// Google की listing policy में screenshots के अंदर ads मना हैं, और वैसे भी
/// ad वाली तस्वीर देखकर install करने का मन कम होता है।
///
/// इसे चालू करके build कीजिए:
/// ```
/// flutter build apk --debug --dart-define=SCREENSHOTS=true
/// ```
/// तब न banner दिखेगा, न interstitial आएगा। बिना इस flag के कुछ नहीं बदलता,
/// इसलिए असली release build पर इसका कोई असर नहीं है।
const bool screenshotMode = bool.fromEnvironment('SCREENSHOTS');
