import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

/// Runs on the PC: starts the on-device test and saves the screenshots it
/// sends back into `build/screenshots/`.
Future<void> main() => integrationDriver(
  responseDataCallback: (data) async {
    final shots = (data?['screenshots'] as Map?) ?? const {};
    final dir = Directory('build/screenshots')..createSync(recursive: true);
    for (final entry in shots.entries) {
      File(
        '${dir.path}/${entry.key}.png',
      ).writeAsBytesSync(base64Decode(entry.value as String));
    }
    stdout.writeln('Saved ${shots.length} screenshots to ${dir.path}');
  },
);
