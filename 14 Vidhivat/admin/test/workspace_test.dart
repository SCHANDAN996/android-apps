import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:vidhivat_admin/jobs.dart';
import 'package:vidhivat_admin/server.dart';
import 'package:vidhivat_admin/workspace.dart';

void main() {
  late Directory temp;
  late Workspace workspace;
  void write(String path, String text) {
    final file = File(p.join(temp.path, path))
      ..parent.createSync(recursive: true);
    file.writeAsStringSync(text);
  }

  const source = 'app/assets/vidhi/ganesh.json';
  const original =
      '{"id":"ganesh","naam":"गणेश पूजन","charan":[{"shirshak":"तैयारी"}]}';
  Map<String, dynamic> draft({String text = original, String path = source}) =>
      {
        'source': path,
        'text': text,
        'baseHash': fingerprint(workspace.readText(path)),
        'title': 'परीक्षण',
        'note': 'केवल fixture',
      };
  setUp(() {
    temp = Directory.systemTemp.createTempSync('vidhivat-admin-test-');
    write('app/pubspec.yaml', 'name: vidhivat\n');
    write('engine/pubspec.yaml', 'name: panchang_engine\n');
    write(source, original);
    write('docs/report.md', '# जाँच\n');
    write('tools/granth_paath/gita/kram.json', '{"id":"gita"}');
    write('tools/granth_paath/gita/mool.txt', '# 1.1\nमूल');
    write('tools/granth_paath/gita/arth/01.txt', '1. अर्थ');
    write('app/assets/granth/gita/gita_01.json',
        '{"id":"gita_01","naam":"अध्याय १","khand":[]}');
    workspace = Workspace(temp.path);
  });
  tearDown(() {
    final target = temp.resolveSymbolicLinksSync();
    if (!p.isWithin(Directory.systemTemp.resolveSymbolicLinksSync(), target) ||
        !p.basename(target).startsWith('vidhivat-admin-test-')) {
      throw StateError('Refusing to remove an unexpected test directory');
    }
    temp.deleteSync(recursive: true);
  });

  test('empty legacy aarti template is never treated as canonical text', () {
    write('app/assets/paath/ganesh_aarti.json',
        '{"id":"ganesh_aarti","naam":"आरती","khand":[]}');
    write('tools/aarti_paath/ganesh_aarti.txt',
        '# यह पुराना खाली template है\n\n');
    final item = workspace.content('app/assets/paath/ganesh_aarti.json');
    expect(item['generated'], isFalse);
    expect(item['sources'], ['app/assets/paath/ganesh_aarti.json']);
  });
  test('populated aarti text is a source, not its generated JSON', () {
    write('app/assets/paath/ram_aarti.json',
        '{"id":"ram_aarti","naam":"आरती","khand":[]}');
    write('tools/aarti_paath/ram_aarti.txt', '# शीर्षक\nपरीक्षण का पाठ\n');
    final item = workspace.content('app/assets/paath/ram_aarti.json');
    expect(item['generated'], isTrue);
    expect(item['sources'], ['tools/aarti_paath/ram_aarti.txt']);
  });

  test('requires the real project marker', () {
    write('app/pubspec.yaml', 'name: something_else');
    expect(() => Workspace(temp.path), throwsA(isA<AdminException>()));
  });
  test('inventory distinguishes generated files and real steps', () {
    final items = workspace.inventory();
    expect(items.length, 2);
    expect(items.singleWhere((e) => e['id'] == 'ganesh')['blocks'], 1);
    expect(items.singleWhere((e) => e['id'] == 'gita_01')['generated'], isTrue);
  });
  test('catalogue exposes Hindi aliases for chapter and deity searches', () {
    write(source,
        '{"id":"ganesh","naam":"पूजन","upnaam":["गणपति पूजा","विघ्नहर्ता"]}');
    final item = workspace.inventory().singleWhere((e) => e['id'] == 'ganesh');
    expect(item['aliases'], contains('गणपति पूजा'));
    expect(item['aliases'], contains('विघ्नहर्ता'));
  });
  test('generated content opens its canonical text and meaning', () {
    final item = workspace.content('app/assets/granth/gita/gita_01.json');
    expect(item['sources'], contains('tools/granth_paath/gita/mool.txt'));
    expect(item['sources'], contains('tools/granth_paath/gita/arth/01.txt'));
  });
  test('draft save never rewrites the original', () {
    final saved = workspace.saveDraft(
        draft(text: original.replaceFirst('गणेश पूजन', 'ड्राफ़्ट शीर्षक')));
    expect(workspace.readText(source), original);
    expect(workspace.drafts().single['id'], saved['id']);
    expect(workspace.drafts().single['conflict'], isFalse);
  });
  test('external edits block saving against an old hash', () {
    final input = draft();
    write(source, original.replaceFirst('गणेश', 'श्री गणेश'));
    expect(() => workspace.saveDraft(input),
        throwsA(isA<AdminException>().having((e) => e.status, 'status', 409)));
  });
  test('old drafts show a conflict after the canonical source changes', () {
    workspace.saveDraft(draft());
    write(source, original.replaceFirst('गणेश', 'श्री गणेश'));
    expect(workspace.drafts().single['conflict'], isTrue);
  });
  test('generated output cannot masquerade as an editable source', () {
    expect(
        () => workspace.saveDraft(draft(
            path: 'app/assets/granth/gita/gita_01.json',
            text: '{"id":"gita_01"}')),
        throwsA(isA<AdminException>()));
  });
  test('canonical source text can be drafted separately', () {
    const path = 'tools/granth_paath/gita/arth/01.txt';
    workspace.saveDraft(draft(path: path, text: '1. अर्थ का ड्राफ़्ट'));
    expect(workspace.readText(path), '1. अर्थ');
  });
  for (final text in [
    '{',
    '{"id":"different","naam":"नाम","charan":[]}',
    '{"id":"ganesh"}',
    '[]'
  ]) {
    test('invalid or identity-breaking JSON is rejected: $text', () {
      expect(() => workspace.saveDraft(draft(text: text)),
          throwsA(isA<AdminException>()));
    });
  }
  for (final path in [
    '../outside.txt',
    '/outside.txt',
    'docs/../app/pubspec.yaml',
    'app/pubspec.yaml',
    'docs\\report.md'
  ]) {
    test(
        'non-approved path rejected: $path',
        () => expect(
            () => workspace.readText(path), throwsA(isA<AdminException>())));
  }
  test('historical reports stay explicitly historical', () {
    write('design_sources/test/run.log', '00:01 +42: All tests passed!');
    final report = workspace.reports().single;
    expect(report['count'], 42);
    expect(report['outcome'], 'passed');
    expect(report['historical'], isTrue);
  });
  test('test freshness changes with app inputs, not docs or drafts', () {
    final jobs = Jobs(workspace), before = Jobs(workspace).inputsHash();
    write('docs/report.md', 'नई टिप्पणी');
    workspace.saveDraft(draft());
    expect(jobs.inputsHash(), before);
    write(source, original.replaceFirst('गणेश', 'श्री गणेश'));
    expect(jobs.inputsHash(), isNot(before));
  });

  group('local HTTP boundary', () {
    late AdminServer server;
    late HttpClient client;
    Future<(int, dynamic)> request(String path,
        {Object? body, String? token, String? origin, String? host}) async {
      final req = await client.openUrl(
          body == null ? 'GET' : 'POST', Uri.parse('${server.url}$path'));
      if (host != null) req.headers.set('host', host);
      if (origin != null) req.headers.set('origin', origin);
      if (token != null) req.headers.set('x-admin-token', token);
      if (body != null) {
        req.headers.contentType = ContentType.json;
        req.write(jsonEncode(body));
      }
      final response = await req.close();
      return (
        response.statusCode,
        jsonDecode(await response.transform(utf8.decoder).join())
      );
    }

    setUp(() async {
      write('admin/web/index.html', '<!doctype html>');
      server =
          AdminServer(workspace, Directory(p.join(temp.path, 'admin/web')));
      await server.start();
      client = HttpClient()..findProxy = (_) => 'DIRECT';
    });
    tearDown(() async {
      client.close(force: true);
      await server.close();
    });
    test('reads snapshot only on the local host', () async {
      final good = await request('/api/snapshot');
      expect(good.$1, 200);
      expect(good.$2['items'], hasLength(2));
      expect((await request('/api/health', host: 'evil.example')).$1, 403);
    });
    test('cross-origin reads and writes rejected', () async {
      expect((await request('/api/session', origin: 'https://evil.example')).$1,
          403);
      expect(
          (await request('/api/drafts',
                  body: draft(),
                  token: server.token,
                  origin: 'https://evil.example'))
              .$1,
          403);
    });
    test('mutation needs a same-session token', () async {
      expect((await request('/api/drafts', body: draft())).$1, 403);
      expect(
          (await request('/api/drafts',
                  body: draft(), token: server.token, origin: server.url))
              .$1,
          200);
      expect(workspace.readText(source), original);
    });
    test('unknown command cannot be launched', () async {
      expect(
          (await request('/api/jobs',
                  body: {'kind': 'delete-everything'}, token: server.token))
              .$1,
          400);
      expect(server.jobs.current, isNull);
    });
    test('file endpoint never exposes a source as an image', () async {
      expect(
          (await request('/api/image?path=${Uri.encodeComponent(source)}')).$1,
          404);
    });
    test('all content-changing routes require the session token', () async {
      for (final path in ['/api/prepare', '/api/apply', '/api/restore']) {
        expect((await request(path, body: {'id': '1-2'})).$1, 403);
      }
    });
    test('restore needs explicit owner confirmation even with a token',
        () async {
      final result = await request('/api/restore',
          body: {'id': '1-2'}, token: server.token);
      expect(result.$1, 400);
    });
  });
}
