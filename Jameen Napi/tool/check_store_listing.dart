// Play Console की character limits जाँचने के लिए:
//   dart run tool/check_store_listing.dart
//
// Play Console अक्षर UTF-16 code units में गिनता है — देवनागरी/बांग्ला/साउथ इंडियन जैसी
// लिपियों में मात्राएँ भी अलग से गिनी जाती हैं, इसलिए "दिखने वाले अक्षर" गिनकर
// अंदाज़ा लगाना गलत निकलता है।

import 'dart:io';

const Map<String, int> _limits = <String, int>{
  'app-name.txt': 30,
  'short-description.txt': 80,
  'full-description.txt': 4000,
};

/// Play जिस तरह गिनता है — UTF-16 code units.
int storeLength(String text) => text.trimRight().length;

void main() {
  final dir = Directory('play_store_assets');
  if (!dir.existsSync()) {
    stderr.writeln('play_store_assets/ नहीं मिला — project की जड़ से चलाएँ।');
    exitCode = 2;
    return;
  }

  var failed = false;

  stdout.writeln('=== Main Store Listing (Hindi - Default) ===');
  for (final entry in _limits.entries) {
    final file = File('${dir.path}/${entry.key}');
    if (!file.existsSync()) {
      stdout.writeln('MISSING  ${entry.key}');
      failed = true;
      continue;
    }

    final length = storeLength(file.readAsStringSync());
    final limit = entry.value;
    final ok = length <= limit;
    if (!ok) failed = true;

    stdout.writeln(
      '${ok ? 'OK     ' : 'TOO LONG'}  ${entry.key.padRight(24)} '
      '$length / $limit${ok ? '' : '  (${length - limit} अक्षर ज़्यादा)'}',
    );
  }

  // Listing में झूठा दावा दोबारा न घुस जाए, इसका पहरा।
  //
  // दो वजहें: ऐप में AdMob है (इंटरनेट + Advertising ID), और v1.1.0 से
  // "नक्शे / GPS से नापें" में location permission भी माँगी जाती है। इसलिए
  // "कोई परमिशन नहीं / कोई डेटा नहीं" जैसी कोई भी लाइन अब झूठ है — Play पर
  // यही बात suspension की वजह बनती है।
  const bannedClaims = <String>[
    'कोई डेटा या परमिशन की जरूरत नहीं',
    'No internet permissions required',
    'इंटरनेट अनुमति (Sensitive Permissions) की आवश्यकता नहीं',
    'कोई परमिशन नहीं',
    'कोई अनुमति नहीं',
    'no permissions',
    'No permission',
    'without any permission',
    'लोकेशन नहीं',
    'does not use location',
    'no location',
  ];

  /// एक listing फ़ाइल की जाँच — झूठे दावे और AdMob का ज़िक्र।
  /// (दोनों जगह एक ही नियम लगें, इसलिए एक ही जगह लिखा है।)
  bool checkClaims(String label, String text) {
    var bad = false;
    for (final claim in bannedClaims) {
      if (text.toLowerCase().contains(claim.toLowerCase())) {
        stdout.writeln('POLICY   $label में गलत दावा: "$claim"');
        bad = true;
      }
    }
    if (!text.contains('AdMob')) {
      stdout.writeln('POLICY   $label में AdMob का ज़िक्र नहीं है');
      bad = true;
    }
    return bad;
  }

  final fullDescription = File('${dir.path}/full-description.txt');
  if (fullDescription.existsSync()) {
    if (checkClaims(
        'full-description.txt', fullDescription.readAsStringSync())) {
      failed = true;
    }
  }

  // Translations folder verification
  final transDir = Directory('${dir.path}/translations');
  if (transDir.existsSync()) {
    final langs = ['en', 'mr', 'gu', 'pa', 'bn', 'te', 'ta', 'kn', 'hi'];
    stdout.writeln('\n=== Checking Regional Translations (9 Languages) ===');
    for (final lang in langs) {
      final langFolder = Directory('${transDir.path}/$lang');
      if (!langFolder.existsSync()) {
        stdout.writeln('MISSING  translations/$lang/ folder');
        failed = true;
        continue;
      }

      stdout.writeln('\n[$lang]');
      for (final entry in _limits.entries) {
        final file = File('${langFolder.path}/${entry.key}');
        if (!file.existsSync()) {
          stdout.writeln('  MISSING  $lang/${entry.key}');
          failed = true;
          continue;
        }

        final content = file.readAsStringSync();
        final length = storeLength(content);
        final limit = entry.value;
        final ok = length <= limit;
        if (!ok) failed = true;

        stdout.writeln(
          '  ${ok ? 'OK     ' : 'TOO LONG'}  ${entry.key.padRight(24)} '
          '$length / $limit${ok ? '' : '  (${length - limit} अक्षर ज़्यादा)'}',
        );

        // झूठे दावे हर भाषा में पकड़ें — पहले सिर्फ़ हिंदी वाली default
        // फ़ाइल जाँची जाती थी, और अनुवाद बिना पहरे के Play पर चढ़ जाते थे।
        if (entry.key == 'full-description.txt' &&
            checkClaims('$lang/full-description.txt', content)) {
          failed = true;
        }
      }
    }
  }

  if (failed) {
    exitCode = 1;
  } else {
    stdout.writeln('\n🎉 सब ठीक है — 9 की 9 भाषाओं की लिस्टिंग Play Console limits के अनुकूल है!');
  }
}
