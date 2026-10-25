import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'workspace.dart';

const validationInputs = [
  'admin/tool/content_validator.dart',
  'app/lib/vidhi/granth.dart',
  'app/lib/vidhi/katha.dart',
  'app/lib/vidhi/paath.dart',
  'app/lib/vidhi/parv.dart',
  'app/lib/vidhi/vidhi.dart',
  'app/lib/vidhi/vrat_panna.dart',
];
Object? orderedJson(Object? value) {
  if (value is Map) {
    final keys = value.keys.cast<String>().toList()..sort();
    return {for (final key in keys) key: orderedJson(value[key])};
  }
  if (value is List) return value.map(orderedJson).toList();
  return value;
}

bool sameJson(String a, String b) =>
    jsonEncode(orderedJson(jsonDecode(a))) ==
    jsonEncode(orderedJson(jsonDecode(b)));

Future<void> validateContents(
    Workspace workspace, List<Map<String, dynamic>> rows) async {
  if (rows.isEmpty) return;
  final runner = p.join(workspace.root, 'admin/tool/content_validator.dart');
  final dart = r'C:\src\flutter\bin\cache\dart-sdk\bin\dart.exe';
  if (!File(runner).existsSync() || !File(dart).existsSync())
    throw AdminException('ऐप के schema validator का औज़ार नहीं मिला।');
  final process =
      await Process.start(dart, [runner], workingDirectory: workspace.root);
  final output = process.stdout.transform(utf8.decoder).join();
  final errors = process.stderr.transform(utf8.decoder).join();
  process.stdin.write(jsonEncode(rows));
  await process.stdin.close();
  final timer = Timer(const Duration(seconds: 45), () => process.kill());
  final code = await process.exitCode;
  timer.cancel();
  final out = await output, err = await errors;
  if (code != 0) {
    String message = out;
    try {
      message = '${(jsonDecode(out) as Map)['error']}';
    } catch (_) {
      message = err;
    }
    throw AdminException(
        'सामग्री की जाँच रुकी: ${message.length > 2500 ? message.substring(0, 2500) : message}');
  }
}
