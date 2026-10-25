import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:vidhivat_admin/changes.dart';
import 'package:vidhivat_admin/content_validation.dart';
import 'package:vidhivat_admin/workspace.dart';

void main() {
  final project = p.dirname(Directory.current.path);
  late Directory temp;
  late Workspace workspace;
  late Changes changes;
  const source = 'app/assets/vidhi/ganesh_poojan.json';
  late String original;
  void write(String path, String text) {
    final f = File(p.join(temp.path, path))..parent.createSync(recursive: true);
    f.writeAsStringSync(text);
  }

  void copy(String path) {
    final target = File(p.join(temp.path, path))
      ..parent.createSync(recursive: true);
    File(p.join(project, path)).copySync(target.path);
  }

  Map<String, dynamic> draft(String path, String text) => workspace.saveDraft({
        'source': path,
        'text': text,
        'baseHash': fingerprint(workspace.readText(path)),
        'title': 'केवल QA fixture',
        'note': 'यह production/source verification नहीं है।',
      });
  Future<Map<String, dynamic>> plan({String? text}) async {
    final data = jsonDecode(original) as Map<String, dynamic>;
    data['parichay'] = 'पैनल की जाँच का परिचय।';
    final record = draft(source, text ?? jsonEncode(data));
    return changes.prepare(record['id']);
  }

  Map<String, dynamic> review(Map<String, dynamic> plan) => {
        'reviewHash': plan['reviewHash'],
        'reviewed': true,
        'reason': 'सिर्फ test fixture में लागू/वापसी जाँचना।',
        'evidence': [
          {
            'book': 'टेस्ट पुस्तक एक',
            'edition': 'नकली QA संस्करण',
            'pages': 'पृष्ठ एक',
            'inspected': true
          },
          {
            'book': 'टेस्ट पुस्तक दो',
            'edition': 'नकली QA संस्करण',
            'pages': 'पृष्ठ दो',
            'inspected': true
          },
        ],
      };
  Future<Map<String, dynamic>> bookPlan() async {
    for (final base in [
      'tools/granth_paath/sukta',
      'app/assets/granth/sukta'
    ]) {
      for (final file in Directory(p.join(project, base))
          .listSync(recursive: true, followLinks: false)
          .whereType<File>()) {
        if (['.json', '.txt'].contains(p.extension(file.path)))
          copy(p.relative(file.path, from: project));
      }
    }
    for (final file in [
      'tools/banao_granth.py',
      'tools/lipi.py',
      'admin/tool/stage_content.py'
    ]) copy(file);
    const path = 'tools/granth_paath/sukta/kram.json';
    final data = jsonDecode(workspace.readText(path)) as Map<String, dynamic>;
    data['parichay'] = '${data['parichay']} परीक्षण।';
    return changes.prepare(draft(path, jsonEncode(data))['id']);
  }

  final conflict = isA<AdminException>().having((e) => e.status, 'status', 409);
  setUp(() {
    temp = Directory.systemTemp.createTempSync('vidhivat-admin-apply-');
    write('app/pubspec.yaml', 'name: vidhivat\n');
    write('engine/pubspec.yaml', 'name: panchang_engine\n');
    copy(source);
    for (final path in validationInputs) copy(path);
    original = File(p.join(temp.path, source)).readAsStringSync();
    workspace = Workspace(temp.path);
    changes = Changes(workspace);
  });
  tearDown(() {
    final target = temp.resolveSymbolicLinksSync();
    if (!p.isWithin(Directory.systemTemp.resolveSymbolicLinksSync(), target) ||
        !p.basename(target).startsWith('vidhivat-admin-apply-'))
      throw StateError('Unexpected test cleanup target');
    temp.deleteSync(recursive: true);
  });

  test('prepare validates but never writes the canonical source', () async {
    final prepared = await plan();
    expect(prepared['changes'], hasLength(1));
    expect(prepared['requiresEvidence'], isTrue);
    expect(workspace.readText(source), original);
    expect(changes.receipts(), isEmpty);
  });
  test('apply writes only reviewed files and creates a durable backup first',
      () async {
    final prepared = await plan();
    final receipt = await changes.apply(prepared['id'], review(prepared));
    expect(receipt['status'], 'applied');
    expect(workspace.readText(source), contains('पैनल की जाँच का परिचय।'));
    final saved = jsonDecode(
        workspace.readText('admin/.workspace/backups/${prepared['id']}.json'));
    expect(utf8.decode(base64Decode(saved['changes'][0]['before'])), original);
    expect(saved['review']['evidence'], hasLength(2));
  });
  test('restore returns the exact original bytes', () async {
    final before = File(p.join(temp.path, source)).readAsBytesSync();
    final prepared = await plan();
    await changes.apply(prepared['id'], review(prepared));
    await changes.restore(prepared['id']);
    expect(File(p.join(temp.path, source)).readAsBytesSync(), before);
    expect(changes.receipts().single['status'], 'restored');
  });
  test('external edit before apply is preserved', () async {
    final prepared = await plan();
    final external = '$original\n';
    write(source, external);
    await expectLater(
        changes.apply(prepared['id'], review(prepared)), throwsA(conflict));
    expect(workspace.readText(source), external);
    expect(changes.receipts(), isEmpty);
  });
  test('external edit after apply blocks restore rather than overwriting it',
      () async {
    final prepared = await plan();
    await changes.apply(prepared['id'], review(prepared));
    const external = 'अलग संपादक का नया काम';
    write(source, external);
    await expectLater(changes.restore(prepared['id']), throwsA(conflict));
    expect(workspace.readText(source), external);
  });
  test('schema errors block preparation before any write', () async {
    final data = jsonDecode(original) as Map;
    data['charan'] = 'गलत ढाँचा';
    await expectLater(
        plan(text: jsonEncode(data)), throwsA(isA<AdminException>()));
    expect(workspace.readText(source), original);
  });
  test('changed step counts require a separate migration', () async {
    final data = jsonDecode(original) as Map;
    (data['charan'] as List).removeLast();
    await expectLater(
        plan(text: jsonEncode(data)), throwsA(isA<AdminException>()));
  });
  test('unchanged source-note-only draft needs no apply', () async {
    final record = draft(source, original);
    await expectLater(
        changes.prepare(record['id']), throwsA(isA<AdminException>()));
    expect(changes.receipts(), isEmpty);
  });
  test('semantic edits need the owner review and two separate book records',
      () async {
    final prepared = await plan();
    for (final data in [
      {...review(prepared), 'reviewed': false},
      {...review(prepared), 'reason': ''},
      {...review(prepared), 'evidence': []},
      {
        ...review(prepared),
        'evidence': [
          {
            'book': 'एक',
            'edition': 'संस्करण',
            'pages': 'एक',
            'inspected': false
          },
          {'book': 'दो', 'edition': 'संस्करण', 'pages': 'दो', 'inspected': true}
        ]
      },
      {
        ...review(prepared),
        'evidence': [
          {'book': 'एक', 'edition': 'एक', 'pages': 'एक', 'inspected': true},
          {'book': 'एक', 'edition': 'दो', 'pages': 'दो', 'inspected': true}
        ]
      },
    ]) {
      await expectLater(
          changes.apply(prepared['id'], data), throwsA(isA<AdminException>()));
    }
    expect(workspace.readText(source), original);
    expect(changes.receipts(), isEmpty);
  });
  test(
      'format-only JSON changes still need review but not invented book evidence',
      () async {
    final prepared = await plan(text: jsonEncode(jsonDecode(original)));
    expect(prepared['requiresEvidence'], isFalse);
    await changes.apply(prepared['id'], {...review(prepared), 'evidence': []});
    expect(sameJson(workspace.readText(source), original), isTrue);
  });
  test('mismatched reviewed plan hash is rejected', () async {
    final prepared = await plan();
    await expectLater(
        changes.apply(
            prepared['id'], {...review(prepared), 'reviewHash': 'wrong'}),
        throwsA(conflict));
  });
  test('schema changes after review invalidate the plan', () async {
    final prepared = await plan();
    final path = 'app/lib/vidhi/vidhi.dart';
    write(path,
        '${File(p.join(temp.path, path)).readAsStringSync()}\n// external edit\n');
    await expectLater(
        changes.apply(prepared['id'], review(prepared)), throwsA(conflict));
  });
  test('two panel instances cannot prepare concurrently in one workspace',
      () async {
    final data = jsonDecode(original) as Map;
    data['parichay'] = 'परीक्षण।';
    final record = draft(source, jsonEncode(data));
    final first = changes.prepare(record['id']);
    await expectLater(
        Changes(workspace).prepare(record['id']), throwsA(conflict));
    await first;
  });
  test('malformed record IDs cannot traverse the workspace', () async {
    await expectLater(
        changes.prepare('../outside'), throwsA(isA<AdminException>()));
    await expectLater(
        changes.restore('../outside'), throwsA(isA<AdminException>()));
  });
  test('generated book preview includes both source and regenerated index',
      () async {
    final prepared = await bookPlan();
    expect(
        (prepared['changes'] as List).map((c) => c['path']),
        containsAll([
          'tools/granth_paath/sukta/kram.json',
          'app/assets/granth/sukta/_kram.json'
        ]));
    final originalIndex =
        workspace.readText('app/assets/granth/sukta/_kram.json');
    await changes.apply(prepared['id'], review(prepared));
    expect(workspace.readText('app/assets/granth/sukta/_kram.json'),
        isNot(originalIndex));
    await changes.restore(prepared['id']);
    expect(workspace.readText('app/assets/granth/sukta/_kram.json'),
        originalIndex);
  });
  test('pre-existing generated drift is not overwritten', () async {
    final prepared = await bookPlan();
    const path = 'app/assets/granth/sukta/_kram.json';
    final data = jsonDecode(workspace.readText(path)) as Map;
    data['parichay'] = 'बाहर का बदलाव';
    write(path, jsonEncode(data));
    await expectLater(
        changes.apply(prepared['id'], review(prepared)), throwsA(conflict));
    final recordId = prepared['draftId'];
    await expectLater(changes.prepare(recordId), throwsA(conflict));
    expect(workspace.readText(path), contains('बाहर का बदलाव'));
  });
  test('new generated files after preview invalidate the reviewed file set',
      () async {
    final prepared = await bookPlan();
    write('app/assets/granth/sukta/new.json', '{"id":"new"}');
    await expectLater(
        changes.apply(prepared['id'], review(prepared)), throwsA(conflict));
  });
  test('mid-batch I/O failure rolls already-written files back', () async {
    final prepared = await bookPlan();
    final paths =
        (prepared['changes'] as List).map((c) => c['path'] as String).toList();
    final before = {for (final path in paths) path: workspace.readText(path)};
    var failed = false;
    final fault = Changes(workspace, beforeWrite: (path) {
      if (!failed && path == prepared['source']) {
        failed = true;
        throw const FileSystemException('Simulated one-off I/O failure');
      }
    });
    await expectLater(
        fault.apply(prepared['id'], review(prepared)), throwsA(conflict));
    for (final path in paths) expect(workspace.readText(path), before[path]);
    expect(changes.receipts().single['status'], 'rolled_back');
  });
  test('crash-style partial receipt can restore both before/after file states',
      () async {
    final prepared = await bookPlan();
    final record = jsonDecode(workspace
            .readText('admin/.workspace/prepared/${prepared['id']}.json'))
        as Map<String, dynamic>;
    record['status'] = 'applying';
    record['appliedAt'] = DateTime.now().toUtc().toIso8601String();
    write(
        'admin/.workspace/backups/${prepared['id']}.json', jsonEncode(record));
    final first = (record['changes'] as List).first;
    File(p.join(temp.path, first['path']))
        .writeAsBytesSync(base64Decode(first['after']));
    await expectLater(changes.prepare(prepared['draftId']), throwsA(conflict));
    await changes.restore(prepared['id']);
    for (final c in record['changes'])
      expect(bytesHash(workspace.readable(c['path']).readAsBytesSync()),
          c['beforeHash']);
  });

  for (final path in [
    'app/assets/paath/ganesh_aarti.json',
    'app/assets/vrat/ekadashi.json',
    'app/assets/parv/navratri.json',
    'app/assets/katha/ahoi_ashtami.json'
  ]) {
    test('app parser accepts reviewed title edit and restore for $path',
        () async {
      copy(path);
      final before = workspace.readText(path);
      final data = jsonDecode(before) as Map;
      data['naam'] = '${data['naam']} (परीक्षण)';
      final prepared =
          await changes.prepare(draft(path, jsonEncode(data))['id']);
      await changes.apply(prepared['id'], review(prepared));
      expect(workspace.readText(path), contains('(परीक्षण)'));
      await changes.restore(prepared['id']);
      expect(workspace.readText(path), before);
    });
  }
  test('populated aarti text stages without touching source or losing meaning',
      () async {
    for (final path in [
      'app/assets/paath/ram_aarti.json',
      'tools/aarti_paath/ram_aarti.txt',
      'tools/bharo_aarti.py',
      'admin/tool/stage_content.py'
    ]) copy(path);
    const path = 'tools/aarti_paath/ram_aarti.txt';
    final before = workspace.readText(path),
        beforeOutput = workspace.readText('app/assets/paath/ram_aarti.json');
    final prepared = await changes.prepare(draft(path, '$before\n')['id']);
    expect(workspace.readText(path), before);
    await changes.apply(prepared['id'], review(prepared));
    expect(workspace.readText('app/assets/paath/ram_aarti.json'), beforeOutput);
    await changes.restore(prepared['id']);
    expect(workspace.readText(path), before);
  });
  test('generator cannot silently erase an existing aarti meaning', () async {
    for (final path in [
      'app/assets/paath/ram_aarti.json',
      'tools/aarti_paath/ram_aarti.txt',
      'tools/bharo_aarti.py',
      'admin/tool/stage_content.py'
    ]) copy(path);
    const output = 'app/assets/paath/ram_aarti.json';
    final outputData = jsonDecode(workspace.readText(output)) as Map;
    (outputData['khand'] as List).first['arth'] = 'केवल परीक्षण का अर्थ।';
    write(output, jsonEncode(outputData));
    const path = 'tools/aarti_paath/ram_aarti.txt';
    final before = workspace.readText(path);
    final lines = before.split('\n');
    final i = lines.indexWhere(
        (line) => line.trim().isNotEmpty && !line.trimLeft().startsWith('#'));
    lines[i] = '${lines[i]} परीक्षण';
    await expectLater(
        changes.prepare(draft(path, lines.join('\n'))['id']),
        throwsA(isA<AdminException>()
            .having((e) => e.toString(), 'loss guard', contains('arth'))));
    expect(workspace.readText(path), before);
  });
  test('corrupt backup remains visible and blocks a new transaction', () async {
    write('admin/.workspace/backups/1-2.json', '{');
    expect(changes.receipts().single['status'], 'record_error');
    expect(() => changes.backup('1-2'), throwsA(conflict));
    await expectLater(plan(), throwsA(conflict));
    expect(workspace.readText(source), original);
  });
  test('backup preview disables restore when a later edit is present',
      () async {
    final prepared = await plan();
    await changes.apply(prepared['id'], review(prepared));
    expect(changes.backup(prepared['id'])['restoreAllowed'], isTrue);
    write(source, 'बाद का संपादन');
    expect(changes.backup(prepared['id'])['restoreAllowed'], isFalse);
  });
  test('interrupted restore is recorded and can be completed safely', () async {
    final prepared = await bookPlan();
    await changes.apply(prepared['id'], review(prepared));
    var failed = false;
    final fault = Changes(workspace, beforeWrite: (path) {
      if (!failed && path != prepared['source']) {
        failed = true;
        throw const FileSystemException('Simulated restore interruption');
      }
    });
    await expectLater(
        fault.restore(prepared['id']), throwsA(isA<FileSystemException>()));
    expect(changes.receipts().single['status'], 'restore_needed');
    await changes.restore(prepared['id']);
    expect(changes.receipts().single['status'], 'restored');
  });
}
