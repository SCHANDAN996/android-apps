// संस्करण एक ही जगह लिखा है — और वो `pubspec.yaml` से मिलना चाहिए।
//
// ⚠️ यह जाँच एक सचमुच हुई ग़लती से आई है: सेटिंग की स्क्रीन महीनों तक
// "संस्करण 0.1.0" दिखाती रही, जबकि pubspec आगे बढ़ चुका था। यूज़र को
// ग़लत अंक दिखना अपने आप में छोटी बात है, पर बग की शिकायत आने पर वही
// अंक पूछा जाता है।
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vidhivat/app_version.dart';

void main() {
  test('appVersion वही है जो pubspec.yaml में लिखा है', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final line = pubspec
        .split('\n')
        .firstWhere((l) => l.trimLeft().startsWith('version:'));
    // "version: 1.0.0+1" में से सिर्फ़ "1.0.0"
    final pura = line.split(':')[1].trim();
    final naam = pura.split('+').first;

    expect(appVersion, naam,
        reason: 'सेटिंग "$appVersion" दिखाएगी, pubspec कहता है "$naam"');
  });

  test('संस्करण का रूप अंक-बिंदु-अंक-बिंदु-अंक है', () {
    expect(RegExp(r'^\d+\.\d+\.\d+$').hasMatch(appVersion), isTrue,
        reason: 'मिला: $appVersion');
  });
}
