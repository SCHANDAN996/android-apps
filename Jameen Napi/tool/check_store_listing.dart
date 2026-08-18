// Play Console की character limits जाँचने के लिए:
//   dart run tool/check_store_listing.dart
//
// Play Console अक्षर UTF-16 code units में गिनता है — देवनागरी/बांग्ला जैसी
// लिपियों में मात्राएँ भी अलग से गिनी जाती हैं, इसलिए "दिखने वाले अक्षर" गिनकर
// अंदाज़ा लगाना गलत निकलता है। (short description इसी वजह से 80 की जगह 86 की
// हो गई थी और Play उसे लेता ही नहीं।)

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
  // ऐप में AdMob है, इसलिए "कोई परमिशन/डेटा नहीं" जैसी बात नहीं लिखी जा सकती।
  const bannedClaims = <String>[
    'कोई डेटा या परमिशन की जरूरत नहीं',
    'No internet permissions required',
    'इंटरनेट अनुमति (Sensitive Permissions) की आवश्यकता नहीं',
  ];

  final fullDescription = File('${dir.path}/full-description.txt');
  if (fullDescription.existsSync()) {
    final text = fullDescription.readAsStringSync();
    for (final claim in bannedClaims) {
      if (text.contains(claim)) {
        stdout.writeln('POLICY   full-description.txt में गलत दावा: "$claim"');
        failed = true;
      }
    }
    if (!text.contains('AdMob')) {
      stdout.writeln('POLICY   full-description.txt में AdMob का ज़िक्र नहीं है');
      failed = true;
    }
  }

  if (failed) {
    exitCode = 1;
  } else {
    stdout.writeln('\nसब ठीक है — listing Play Console पर चढ़ाई जा सकती है।');
  }
}
