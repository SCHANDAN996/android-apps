import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mistri_calculator/core/constants/app_info.dart';

void main() {
  test('AppInfo.version matches pubspec.yaml', () {
    final line = File(
      'pubspec.yaml',
    ).readAsLinesSync().firstWhere((l) => l.startsWith('version:'));
    // "version: 1.1.0+3" -> "1.1.0"
    final pubspecVersion = line.split(':')[1].trim().split('+').first;

    expect(
      AppInfo.version,
      pubspecVersion,
      reason: 'Settings shows AppInfo.version; bump it with the pubspec.',
    );
  });
}
