import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:vidhivat_admin/server.dart';
import 'package:vidhivat_admin/workspace.dart';

Future<void> main(List<String> args) async {
  String? option(String key) {
    final index = args.indexOf(key);
    return index >= 0 && index + 1 < args.length ? args[index + 1] : null;
  }

  try {
    final root = option('--workspace') ?? p.dirname(Directory.current.path);
    final workspace = Workspace(root);
    final web = Directory(
        option('--web-root') ?? p.join(workspace.root, 'admin', 'web'));
    if (!File(p.join(web.path, 'index.html')).existsSync())
      throw AdminException('पैनल की web फ़ाइलें नहीं मिलीं।');
    final server = AdminServer(workspace, web);
    await server.start(port: int.tryParse(option('--port') ?? '') ?? 0);
    final runtime = Directory(p.join(workspace.root, 'admin', '.runtime'))
      ..createSync(recursive: true);
    File(p.join(runtime.path, 'session.json')).writeAsStringSync(
        jsonEncode({
          'pid': pid,
          'url': server.url,
          'workspace': workspace.root,
          'startedAt': DateTime.now().toUtc().toIso8601String(),
        }),
        flush: true);
    stdout.writeln('विधिवत प्रबंधन तैयार: ${server.url}');
  } catch (error) {
    stderr.writeln('पैनल नहीं खुला: $error');
    exitCode = 1;
  }
}
