import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'workspace.dart';

class Jobs {
  final Workspace workspace;
  Map<String, dynamic>? current;
  Jobs(this.workspace);

  String inputsHash() {
    final rows = <String>[];
    for (final root in [
      'app/lib',
      'app/test',
      'app/assets',
      'engine/lib',
      'engine/test',
      'admin/lib',
      'admin/bin',
      'admin/test',
      'admin/web',
      'admin/tool',
      'tools/granth_paath',
      'tools/aarti_paath'
    ]) {
      for (final file in workspace.files(root)) {
        rows.add(
            '${workspace.relative(file.path)}:${sha256.convert(file.readAsBytesSync())}');
      }
    }
    for (final folder in ['app', 'engine', 'admin']) {
      for (final name in ['pubspec.yaml', 'pubspec.lock']) {
        final file = File(p.join(workspace.root, folder, name));
        if (file.existsSync())
          rows.add('$folder/$name:${sha256.convert(file.readAsBytesSync())}');
      }
    }
    rows.sort();
    for (final path in [
      'tools/banao_granth.py',
      'tools/lipi.py',
      'tools/bharo_aarti.py'
    ]) {
      final file = File(p.join(workspace.root, path));
      if (file.existsSync())
        rows.add('$path:${sha256.convert(file.readAsBytesSync())}');
    }
    return fingerprint(rows.join('\n'));
  }

  Map<String, dynamic> state() {
    final reportDir =
        workspace.files('admin/.workspace/reports', recursive: false);
    final history = reportDir
        .where((f) => f.path.endsWith('.json'))
        .map(workspace.jsonMap)
        .whereType<Map<String, dynamic>>()
        .toList()
      ..sort((a, b) =>
          b['startedAt'].toString().compareTo(a['startedAt'].toString()));
    final hash = history.isEmpty ? null : inputsHash();
    return {
      'current': current,
      'history': [
        for (final row in history.take(15))
          {
            ...row,
            'stale': row['inputHash'] != hash ||
                row['outputHash'] != row['inputHash']
          }
      ]
    };
  }

  Map<String, dynamic> start(String kind) {
    if (current?['running'] == true)
      throw AdminException('एक जाँच चल रही है। उसके पूरा होने दें।', 409);
    final commands = <String, (String, List<String>, String)>{
      'app': (r'C:\src\flutter\bin\flutter.bat', ['test', '--no-pub'], 'app'),
      'engine': (
        r'C:\src\flutter\bin\cache\dart-sdk\bin\dart.exe',
        ['test'],
        'engine'
      ),
      'analyze': (
        r'C:\src\flutter\bin\flutter.bat',
        ['analyze', '--no-pub'],
        'app'
      ),
      'admin': (
        r'C:\src\flutter\bin\cache\dart-sdk\bin\dart.exe',
        ['test'],
        'admin'
      ),
    };
    final command = commands[kind];
    if (command == null) throw AdminException('यह जाँच उपलब्ध नहीं है।');
    if (!File(command.$1).existsSync())
      throw AdminException(
          'इस कंप्यूटर में Flutter/Dart का तय औज़ार नहीं मिला।');
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    current = {
      'id': id,
      'kind': kind,
      'running': true,
      'startedAt': DateTime.now().toUtc().toIso8601String(),
      'inputHash': inputsHash(),
      'lines': '',
      'exitCode': null
    };
    _run(command);
    return Map.from(current!);
  }

  Future<void> _run((String, List<String>, String) command) async {
    final row = current!;
    final dir =
        Directory(p.join(workspace.root, 'admin', '.workspace', 'reports'))
          ..createSync(recursive: true);
    final logPath = p.join(dir.path, '${row['id']}.log');
    final sink = File(logPath).openWrite();
    try {
      final bat = command.$1.endsWith('.bat');
      final process = await Process.start(bat ? 'cmd.exe' : command.$1,
          bat ? ['/d', '/c', command.$1, ...command.$2] : command.$2,
          workingDirectory: p.join(workspace.root, command.$3));
      void add(String text) {
        sink.write(text);
        final previous = '${row['lines']}$text';
        row['lines'] = previous.length > 30000
            ? previous.substring(previous.length - 30000)
            : previous;
      }

      final out =
          process.stdout.transform(utf8.decoder).listen(add).asFuture<void>();
      final err =
          process.stderr.transform(utf8.decoder).listen(add).asFuture<void>();
      row['exitCode'] = await process.exitCode;
      await Future.wait([out, err]);
    } catch (error) {
      row['exitCode'] = -1;
      row['lines'] = '${row['lines']}\nजाँच शुरू नहीं हुई: $error';
      sink.writeln(row['lines']);
    } finally {
      await sink.close();
      row['running'] = false;
      row['finishedAt'] = DateTime.now().toUtc().toIso8601String();
      row['outputHash'] = inputsHash();
      row['logPath'] = workspace.relative(logPath);
      final saved = Map<String, dynamic>.from(row)..remove('lines');
      File(p.join(dir.path, '${row['id']}.json'))
          .writeAsStringSync(jsonEncode(saved), flush: true);
    }
  }
}
