import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'content_validation.dart';
import 'workspace.dart';

String bytesHash(List<int> bytes) => sha256.convert(bytes).toString();

class Changes {
  static final _activeRoots = <String>{};
  final Workspace workspace;
  final void Function(String path)? beforeWrite;
  bool busy = false;
  Changes(this.workspace, {this.beforeWrite});
  File _inputFile(String path) {
    const scripts = [
      'tools/banao_granth.py',
      'tools/lipi.py',
      'tools/bharo_aarti.py',
      'admin/tool/stage_content.py'
    ];
    if (!scripts.contains(path) && !validationInputs.contains(path))
      return workspace.readable(path);
    final file = File(p.join(workspace.root, path));
    if (!file.existsSync() ||
        !p.isWithin(workspace.root, file.resolveSymbolicLinksSync()))
      throw AdminException('जाँच का मूल औज़ार नहीं मिला।');
    return file;
  }

  String _id() =>
      '${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(0x7fffffff)}';
  void _checkId(String id) {
    if (!RegExp(r'^\d+-\d+$').hasMatch(id))
      throw AdminException('सही रिकॉर्ड चुनें।');
  }

  File _recordFile(String kind, String id) {
    _checkId(id);
    return workspace.readable('admin/.workspace/$kind/$id.json');
  }

  Directory _dir(String relative) {
    final dir = Directory(p.join(workspace.root, relative))
      ..createSync(recursive: true);
    if (!p.isWithin(workspace.root, dir.resolveSymbolicLinksSync()))
      throw AdminException('बाहरी फ़ोल्डर में बदलाव नहीं होगा।', 403);
    return dir;
  }

  void _writeRecord(String folder, String id, Map<String, dynamic> value) {
    final dir = _dir('admin/.workspace/$folder');
    final file = File(p.join(dir.path, '$id.json'));
    final tmp = File('${file.path}.tmp');
    tmp.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(value),
        flush: true);
    tmp.renameSync(file.path);
  }

  Future<T> _locked<T>(FutureOr<T> Function() action) async {
    if (busy || _activeRoots.contains(workspace.root))
      throw AdminException(
          'दूसरा बदलाव तैयार हो रहा है। थोड़ी देर बाद कोशिश करें।', 409);
    final lockFile =
        File(p.join(_dir('admin/.workspace').path, 'changes.lock'));
    final handle = lockFile.openSync(mode: FileMode.append);
    try {
      handle.lockSync(FileLock.exclusive);
    } catch (_) {
      handle.closeSync();
      throw AdminException(
          'दूसरा पैनल बदलाव कर रहा है। उसके पूरा होने दें।', 409);
    }
    busy = true;
    _activeRoots.add(workspace.root);
    try {
      return await action();
    } finally {
      busy = false;
      _activeRoots.remove(workspace.root);
      handle.unlockSync();
      handle.closeSync();
    }
  }

  Map<String, dynamic> _draft(String id) {
    final file = _recordFile('drafts', id);
    final value = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    if (value['id'] != id ||
        value['source'] is! String ||
        value['text'] is! String ||
        !workspace.editable(value['source'])) {
      throw AdminException('ड्राफ़्ट रिकॉर्ड मान्य नहीं है।');
    }
    if (fingerprint(workspace.readText(value['source'])) != value['baseHash']) {
      throw AdminException(
          'मूल फ़ाइल बदल गई है। इस ड्राफ़्ट को नये पाठ से फिर मिलाएँ।', 409);
    }
    return value;
  }

  Map<String, dynamic> _publicPlan(Map<String, dynamic> plan, String hash) => {
        'id': plan['id'],
        'draftId': plan['draftId'],
        'source': plan['source'],
        'title': plan['title'],
        'createdAt': plan['createdAt'],
        'reviewHash': hash,
        'requiresEvidence': plan['requiresEvidence'],
        'changes': [
          for (final raw in plan['changes'] as List)
            {
              'path': raw['path'],
              'kind': raw['kind'],
              'before': utf8.decode(base64Decode(raw['before'])),
              'after': utf8.decode(base64Decode(raw['after'])),
            }
        ],
      };
  Map<String, dynamic> getPlan(String id) {
    final text = _recordFile('prepared', id).readAsStringSync();
    return _publicPlan(
        jsonDecode(text) as Map<String, dynamic>, fingerprint(text));
  }

  Future<Map<String, dynamic>> prepare(String draftId) => _locked(() async {
        final pending = receipts().where((r) =>
            !['applied', 'restored', 'rolled_back'].contains(r['status']));
        if (pending.isNotEmpty)
          throw AdminException(
              'पहले अधूरे बैकअप रिकॉर्ड की वापसी/समीक्षा करें।', 409);
        final draft = _draft(draftId);
        final source = draft['source'] as String,
            text = draft['text'] as String;
        if (workspace.readText(source) == text)
          throw AdminException(
              'मूल पाठ और ड्राफ़्ट समान हैं; लागू करने की जरूरत नहीं है।');
        final id = _id(), stage = _dir('admin/.workspace/staging/$id');
        final inputs = <String, String>{};
        for (final path in validationInputs) {
          inputs[path] = bytesHash(_inputFile(path).readAsBytesSync());
        }
        final validations = <Map<String, dynamic>>[];
        final directories = <Map<String, dynamic>>[];
        final outputs = <String, List<int>>{};
        void track(String path) {
          inputs[path] = bytesHash(workspace.readable(path).readAsBytesSync());
        }

        void copy(String path) {
          final file = File(p.join(workspace.root, path));
          if (!p.isWithin(workspace.root, file.resolveSymbolicLinksSync()))
            throw AdminException('बाहरी स्रोत नहीं पढ़ेंगे।', 403);
          inputs[path] = bytesHash(file.readAsBytesSync());
          final dest = File(p.join(stage.path, path))
            ..parent.createSync(recursive: true);
          file.copySync(dest.path);
        }

        String mode = '', identifier = '', assetDir = '';
        if (source.startsWith('tools/granth_paath/')) {
          mode = 'granth';
          identifier = source.split('/')[2];
          final kramPath = 'tools/granth_paath/$identifier/kram.json';
          final before = jsonDecode(workspace.readText(kramPath)) as Map;
          if (source == kramPath) {
            Map after;
            try {
              after = jsonDecode(text) as Map;
            } catch (_) {
              throw AdminException('क्रम की JSON सही नहीं है।');
            }
            for (final field in ['id', 'assetDir', 'dhancha']) {
              if (before[field] != after[field])
                throw AdminException('$field को इस संपादन में नहीं बदल सकते।');
            }
          }
          assetDir = 'app/assets/${before['assetDir'] ?? 'granth/$identifier'}';
          for (final file
              in workspace.files('tools/granth_paath/$identifier')) {
            final path = workspace.relative(file.path),
                tail = p
                    .relative(file.path,
                        from: p.join(
                            workspace.root, 'tools/granth_paath', identifier))
                    .replaceAll('\\', '/');
            if (['kram.json', 'mool.txt', 'pushpika.txt'].contains(tail) ||
                ((tail.startsWith('arth/') || tail.startsWith('paath/')) &&
                    tail.endsWith('.txt'))) copy(path);
          }
          copy('tools/banao_granth.py');
          copy('tools/lipi.py');
        } else if (source.startsWith('tools/aarti_paath/')) {
          mode = 'aarti';
          identifier = p.basenameWithoutExtension(source);
          assetDir = 'app/assets/paath';
          copy(source);
          copy('tools/bharo_aarti.py');
          copy('app/assets/paath/$identifier.json');
        }
        if (mode.isEmpty) {
          track(source);
          validations.add({
            'path': source,
            'before': workspace.readText(source),
            'after': text
          });
          outputs[source] = utf8.encode(text);
        } else {
          for (final directory in [
            mode == 'granth'
                ? 'tools/granth_paath/$identifier'
                : 'tools/aarti_paath',
            assetDir
          ]) {
            directories
                .add({'path': directory, 'files': _directoryFiles(directory)});
          }
          if (!RegExp(r'^[a-z0-9_]+$').hasMatch(identifier))
            throw AdminException('मूल सामग्री की पहचान मान्य नहीं है।');
          final oldFiles = workspace
              .files(assetDir, recursive: false)
              .where((f) =>
                  f.path.endsWith('.json') &&
                  (mode == 'granth' ||
                      p.basename(f.path) == '$identifier.json'))
              .toList();
          if (oldFiles.isEmpty)
            throw AdminException('पहले से बना ऐप आउटपुट नहीं मिला।');
          for (final file in oldFiles) track(workspace.relative(file.path));
          inputs['admin/tool/stage_content.py'] = bytesHash(
              _inputFile('admin/tool/stage_content.py').readAsBytesSync());
          final beforeOut = Directory(p.join(stage.path, 'before-output'))
            ..createSync();
          await _generate(mode, identifier, stage, beforeOut);
          final oldNames = oldFiles.map((f) => p.basename(f.path)).toList()
            ..sort();
          List<File> generated(Directory dir) => dir
              .listSync()
              .whereType<File>()
              .where((f) => f.path.endsWith('.json'))
              .toList()
            ..sort((a, b) => a.path.compareTo(b.path));
          final baseline = generated(beforeOut);
          if (jsonEncode(oldNames) !=
              jsonEncode(baseline.map((f) => p.basename(f.path)).toList())) {
            throw AdminException(
                'मूल और ऐप की फ़ाइल-सूची अलग है। पहले उनका मिलान ठीक करें।');
          }
          for (final file in baseline) {
            final path = '$assetDir/${p.basename(file.path)}';
            if (!sameJson(workspace.readText(path), file.readAsStringSync()))
              throw AdminException(
                  'मूल से दोबारा बना $path मौजूदा ऐप से अलग है। पुराने बदलाव मिटाने से पहले उनका मिलान करें।',
                  409);
          }
          File(p.join(stage.path, source)).writeAsStringSync(text, flush: true);
          // The aarti generator preserves meanings from the original staged JSON.
          if (mode == 'aarti')
            File(p.join(workspace.root, 'app/assets/paath/$identifier.json'))
                .copySync(
                    p.join(stage.path, 'app/assets/paath/$identifier.json'));
          final newOut = Directory(p.join(stage.path, 'after-output'))
            ..createSync();
          await _generate(mode, identifier, stage, newOut);
          final afterFiles = generated(newOut);
          if (jsonEncode(oldNames) !=
              jsonEncode(afterFiles.map((f) => p.basename(f.path)).toList()))
            throw AdminException(
                'अध्याय जोड़ने/हटाने के लिए अलग migration जरूरी है।');
          for (final file in afterFiles) {
            final path = '$assetDir/${p.basename(file.path)}',
                after = file.readAsStringSync(),
                before = workspace.readText(path);
            validations.add({
              'path': path,
              'before': before,
              'after': after,
              'generated': true
            });
            if (!sameJson(before, after))
              outputs[path] = file.readAsBytesSync();
          }
          outputs[source] = utf8.encode(text);
        }
        await validateContents(workspace, validations);
        _checkInputs(inputs);
        _checkDirectories(directories);
        final changes = <Map<String, dynamic>>[];
        for (final entry in outputs.entries) {
          final before = workspace.readable(entry.key).readAsBytesSync();
          if (bytesHash(before) == bytesHash(entry.value)) continue;
          changes.add({
            'path': entry.key,
            'before': base64Encode(before),
            'after': base64Encode(entry.value),
            'beforeHash': bytesHash(before),
            'afterHash': bytesHash(entry.value),
            'kind': entry.key == source ? 'source' : 'generated'
          });
        }
        final plan = <String, dynamic>{
          'id': id,
          'draftId': draftId,
          'source': source,
          'title': draft['title'],
          'draftHash':
              fingerprint(_recordFile('drafts', draftId).readAsStringSync()),
          'createdAt': DateTime.now().toUtc().toIso8601String(),
          'inputs': inputs,
          'directories': directories,
          'changes': changes,
          'requiresEvidence': !source.endsWith('.json') ||
              !sameJson(workspace.readText(source), text)
        };
        _writeRecord('prepared', id, plan);
        return getPlan(id);
      });

  Future<void> _generate(
      String mode, String identifier, Directory stage, Directory output) async {
    final runner = File(p.join(workspace.root, 'admin/tool/stage_content.py'));
    if (!runner.existsSync())
      throw AdminException('स्टेजिंग का औज़ार नहीं मिला।');
    final process = await Process.start('python',
        ['-X', 'utf8', runner.path, mode, identifier, stage.path, output.path]);
    final out = process.stdout.transform(utf8.decoder).join();
    final err = process.stderr.transform(utf8.decoder).join();
    final timer = Timer(const Duration(seconds: 60), () => process.kill());
    final code = await process.exitCode;
    timer.cancel();
    final log = '${await out}\n${await err}';
    File(p.join(output.path, 'generation.log')).writeAsStringSync(log);
    if (code != 0)
      throw AdminException(
          'अस्थायी आउटपुट की जाँच रुकी:\n${log.length > 2500 ? log.substring(log.length - 2500) : log}');
  }

  void _checkInputs(Map inputs) {
    for (final entry in inputs.entries) {
      if (bytesHash(_inputFile(entry.key as String).readAsBytesSync()) !=
          entry.value) {
        throw AdminException(
            '${entry.key} बाहर से बदली है। नया मिलान तैयार करें।', 409);
      }
    }
  }

  List<String> _directoryFiles(String path) => workspace
      .files(path)
      .where((f) => ['.txt', '.json'].contains(p.extension(f.path)))
      .map((f) => workspace.relative(f.path))
      .toList()
    ..sort();
  void _checkDirectories(List directories) {
    for (final d in directories) {
      if (jsonEncode(_directoryFiles(d['path'])) != jsonEncode(d['files']))
        throw AdminException(
            'मूल या आउटपुट की फ़ाइल-सूची बदली है। नया मिलान बनाएँ।', 409);
    }
  }

  void _review(Map<String, dynamic> body, bool needsEvidence) {
    if (body['reviewed'] != true ||
        body['reason'] is! String ||
        (body['reason'] as String).trim().isEmpty)
      throw AdminException('बदलाव की समीक्षा और वजह दर्ज करें।');
    if (!needsEvidence) return;
    final sources = body['evidence'];
    if (sources is! List || sources.length < 2)
      throw AdminException(
          'पाठ/अर्थ/नियम के लिए दो पढ़े हुए छपे स्रोतों का विवरण चाहिए।');
    final titles = <String>{};
    for (final source in sources) {
      if (source is! Map ||
          source['inspected'] != true ||
          ['book', 'edition', 'pages'].any((key) =>
              source[key] is! String || (source[key] as String).trim().isEmpty))
        throw AdminException(
            'हर स्रोत की किताब, संस्करण, पृष्ठ और पढ़े होने की पुष्टि दर्ज करें।');
      titles.add('${source['book']}'.trim().toLowerCase());
    }
    if (titles.length < 2)
      throw AdminException(
          'दो अलग छपे ग्रंथ दर्ज करें; एक ही किताब के दो पृष्ठ पर्याप्त नहीं।');
  }

  bool _writable(String path) =>
      path == p.normalize(path).replaceAll('\\', '/') &&
      !p.isAbsolute(path) &&
      (RegExp(r'^app/assets/(vidhi|vrat|paath|granth|katha|parv)/.+\.json$')
              .hasMatch(path) ||
          RegExp(r'^tools/(granth_paath|aarti_paath)/.+\.(txt|json)$')
              .hasMatch(path));
  void _replace(String path, List<int> bytes, String id) {
    if (!_writable(path))
      throw AdminException('इस फ़ाइल पर लागू करने की अनुमति नहीं है।', 403);
    final file = workspace.readable(path);
    if (FileSystemEntity.isLinkSync(file.path))
      throw AdminException('Linked फ़ाइल को नहीं बदल सकते।', 403);
    beforeWrite?.call(path);
    final temp = File('${file.path}.admin-$id.tmp');
    temp.writeAsBytesSync(bytes, flush: true);
    temp.renameSync(file.path);
  }

  Future<Map<String, dynamic>> apply(String id, Map<String, dynamic> review) =>
      _locked(() async {
        if (receipts().any((r) =>
            !['applied', 'restored', 'rolled_back'].contains(r['status'])))
          throw AdminException('पहले अधूरा बैकअप रिकॉर्ड सँभालें।', 409);
        final raw = _recordFile('prepared', id).readAsStringSync();
        if (review['reviewHash'] != fingerprint(raw))
          throw AdminException(
              'समीक्षा वाला मिलान बदल गया है। फिर खोलें।', 409);
        final plan = jsonDecode(raw) as Map<String, dynamic>;
        _draft(plan['draftId'] as String);
        if (fingerprint(
                _recordFile('drafts', plan['draftId']).readAsStringSync()) !=
            plan['draftHash'])
          throw AdminException('ड्राफ़्ट बदल गया है। फिर समीक्षा करें।', 409);
        _checkInputs(plan['inputs'] as Map);
        _checkDirectories(plan['directories'] as List);
        final changes = (plan['changes'] as List).cast<Map<String, dynamic>>();
        if (changes.isEmpty)
          throw AdminException('लागू करने वाला बदलाव नहीं है।');
        final sourceChange =
            changes.where((c) => c['path'] == plan['source']).firstOrNull;
        if (sourceChange == null ||
            utf8.decode(base64Decode(sourceChange['after'])) !=
                _draft(plan['draftId'])['text'])
          throw AdminException('मूल ड्राफ़्ट और तैयार मिलान अलग हैं।');
        final evidenceNeeded = !(plan['source'] as String).endsWith('.json') ||
            !sameJson(utf8.decode(base64Decode(sourceChange['before'])),
                utf8.decode(base64Decode(sourceChange['after'])));
        _review(review, evidenceNeeded);
        final allowed = {
          plan['source'],
          ...workspace
              .sourceMap()
              .entries
              .where((e) => e.value.contains(plan['source']))
              .map((e) => e.key)
        };
        final validations = <Map<String, dynamic>>[];
        for (final c in changes) {
          if (!allowed.contains(c['path']) ||
              !_writable(c['path']) ||
              bytesHash(base64Decode(c['before'])) != c['beforeHash'] ||
              bytesHash(base64Decode(c['after'])) != c['afterHash'])
            throw AdminException('बैकअप/आउटपुट रिकॉर्ड सही नहीं है।');
          if ((c['path'] as String).startsWith('app/assets/'))
            validations.add({
              'path': c['path'],
              'before': utf8.decode(base64Decode(c['before'])),
              'after': utf8.decode(base64Decode(c['after'])),
              'generated': c['path'] != plan['source'],
            });
        }
        await validateContents(workspace, validations);
        _checkInputs(plan['inputs'] as Map);
        _checkDirectories(plan['directories'] as List);
        if (fingerprint(
                _recordFile('drafts', plan['draftId']).readAsStringSync()) !=
            plan['draftHash'])
          throw AdminException('समीक्षा के दौरान ड्राफ़्ट बदल गया।', 409);
        final receipt = <String, dynamic>{
          ...plan,
          'status': 'applying',
          'review': review,
          'appliedAt': DateTime.now().toUtc().toIso8601String()
        };
        _writeRecord('backups', id,
            receipt); // Durable recovery data exists before the first content write.
        try {
          for (final c in changes) {
            if (bytesHash(workspace.readable(c['path']).readAsBytesSync()) !=
                c['beforeHash'])
              throw AdminException(
                  'फ़ाइल अभी बदली है; लागू करना रोक दिया।', 409);
            _replace(c['path'], base64Decode(c['after']), id);
          }
          receipt['status'] = 'applied';
          _writeRecord('backups', id, receipt);
        } catch (error) {
          receipt['status'] = 'rollback_needed';
          receipt['error'] = error.toString();
          _writeRecord('backups', id, receipt);
          try {
            _restoreFiles(receipt);
            receipt['status'] = 'rolled_back';
          } catch (_) {
            /* Preserve outside edits and the durable backup for manual recovery. */
          }
          _writeRecord('backups', id, receipt);
          throw AdminException(
              'लागू करना पूरा नहीं हुआ। बैकअप रिकॉर्ड देखें; बाहर के बदलाव नहीं मिटाए गए।',
              409);
        }
        return _publicReceipt(receipt);
      });
  Map<String, dynamic> _publicReceipt(Map<String, dynamic> value) => {
        'id': value['id'],
        'draftId': value['draftId'],
        'title': value['title'],
        'source': value['source'],
        'status': value['status'],
        'appliedAt': value['appliedAt'],
        'restoredAt': value['restoredAt'],
        'paths': [for (final c in value['changes'] as List) c['path']],
      };
  List<Map<String, dynamic>> receipts() => workspace
          .files('admin/.workspace/backups', recursive: false)
          .where((f) => f.path.endsWith('.json'))
          .map((file) {
        try {
          final value = workspace.jsonMap(file);
          if (value == null ||
              value['id'] != p.basenameWithoutExtension(file.path) ||
              value['status'] is! String ||
              value['changes'] is! List) throw const FormatException();
          return _publicReceipt(value);
        } catch (_) {
          return <String, dynamic>{
            'id': p.basenameWithoutExtension(file.path),
            'title': 'बैकअप रिकॉर्ड पढ़ा नहीं जा सका',
            'status': 'record_error',
            'appliedAt': file.lastModifiedSync().toUtc().toIso8601String(),
            'paths': <String>[],
            'source': ''
          };
        }
      }).toList()
        ..sort((a, b) => '${b['appliedAt']}'.compareTo('${a['appliedAt']}'));
  Map<String, dynamic> backup(String id) {
    final raw = _recordFile('backups', id).readAsStringSync();
    Map<String, dynamic> value;
    try {
      value = jsonDecode(raw) as Map<String, dynamic>;
      _publicReceipt(value);
    } catch (_) {
      throw AdminException(
          'बैकअप रिकॉर्ड खराब है। नया बदलाव रोक दिया गया है; रिकॉर्ड की जाँच जरूरी है।',
          409);
    }
    var allowed = !['restored', 'rolled_back'].contains(value['status']);
    String? reason;
    try {
      _preflightRestore(value);
    } catch (error) {
      allowed = false;
      reason = error.toString();
    }
    return {
      ..._publicPlan(value, fingerprint(raw)),
      ..._publicReceipt(value),
      'restoreAllowed': allowed,
      'restoreReason': reason
    };
  }

  void _restoreFiles(Map<String, dynamic> receipt) {
    _preflightRestore(receipt);
    final changes = (receipt['changes'] as List).cast<Map<String, dynamic>>();
    for (final c in changes.reversed) {
      final hash = bytesHash(workspace.readable(c['path']).readAsBytesSync());
      if (hash == c['beforeHash']) continue;
      if (hash != c['afterHash'])
        throw AdminException('वापसी के दौरान फ़ाइल बदल गई।', 409);
      _replace(c['path'], base64Decode(c['before']), receipt['id']);
    }
  }

  void _preflightRestore(Map<String, dynamic> receipt) {
    final changes = (receipt['changes'] as List).cast<Map<String, dynamic>>();
    // Preflight all files before restoring any; external edits must survive.
    for (final c in changes) {
      if (!_writable(c['path']) ||
          bytesHash(base64Decode(c['before'])) != c['beforeHash'] ||
          bytesHash(base64Decode(c['after'])) != c['afterHash'])
        throw AdminException('बैकअप सही नहीं है।');
      final hash = bytesHash(workspace.readable(c['path']).readAsBytesSync());
      if (hash != c['afterHash'] && hash != c['beforeHash'])
        throw AdminException(
            '${c['path']} में बाद का बदलाव है; उसे मिटाकर वापसी नहीं होगी।',
            409);
    }
  }

  Future<Map<String, dynamic>> restore(String id) => _locked(() async {
        final receipt =
            jsonDecode(_recordFile('backups', id).readAsStringSync())
                as Map<String, dynamic>;
        if (['restored', 'rolled_back'].contains(receipt['status']))
          throw AdminException('यह बदलाव पहले ही वापस लिया जा चुका है।');
        _preflightRestore(receipt);
        receipt['status'] = 'restoring';
        _writeRecord('backups', id, receipt);
        try {
          _restoreFiles(receipt);
          receipt['status'] = 'restored';
          receipt['restoredAt'] = DateTime.now().toUtc().toIso8601String();
          _writeRecord('backups', id, receipt);
        } catch (error) {
          receipt['status'] = 'restore_needed';
          receipt['error'] = error.toString();
          _writeRecord('backups', id, receipt);
          rethrow;
        }
        return _publicReceipt(receipt);
      });
}
