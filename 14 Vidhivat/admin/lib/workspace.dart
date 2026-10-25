import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

String fingerprint(String text) => sha256.convert(utf8.encode(text)).toString();

class AdminException implements Exception {
  final String message;
  final int status;
  AdminException(this.message, [this.status = 400]);
  @override
  String toString() => message;
}

class Workspace {
  final Directory directory;
  late final String root = directory.resolveSymbolicLinksSync();
  Workspace(String path) : directory = Directory(p.absolute(path)) {
    if (!directory.existsSync() ||
        !File(p.join(directory.path, 'app', 'pubspec.yaml')).existsSync() ||
        !File(p.join(directory.path, 'engine', 'pubspec.yaml')).existsSync()) {
      throw AdminException('विधिवत का सही प्रोजेक्ट फ़ोल्डर चुनें।');
    }
    final spec =
        File(p.join(directory.path, 'app', 'pubspec.yaml')).readAsStringSync();
    if (!RegExp(r'^name:\s*vidhivat\s*$', multiLine: true).hasMatch(spec)) {
      throw AdminException('इस फ़ोल्डर में विधिवत ऐप नहीं मिला।');
    }
  }

  String relative(String path) =>
      p.relative(path, from: root).replaceAll('\\', '/');

  File readable(String relativePath) {
    if (relativePath.contains('\\') || p.isAbsolute(relativePath)) {
      throw AdminException('फ़ाइल का रास्ता मान्य नहीं है।');
    }
    final path = p.normalize(p.join(root, relativePath));
    if (!p.isWithin(root, path))
      throw AdminException('प्रोजेक्ट के बाहर की फ़ाइल नहीं खोल सकते।', 403);
    if (relative(path) != relativePath)
      throw AdminException('सीधा, मान्य फ़ाइल रास्ता चुनें।', 403);
    final file = File(path);
    if (!file.existsSync()) throw AdminException('फ़ाइल नहीं मिली।', 404);
    final real = file.resolveSymbolicLinksSync();
    if (!p.isWithin(root, real))
      throw AdminException('बाहरी linked फ़ाइल नहीं खोल सकते।', 403);
    final allowed = [
      'app/assets/',
      'tools/granth_paath/',
      'tools/aarti_paath/',
      'docs/',
      'design_sources/',
      'admin/.workspace/',
      'admin/.runtime/'
    ];
    if (!allowed.any(relativePath.startsWith))
      throw AdminException('इस फ़ाइल की अनुमति नहीं है।', 403);
    return file;
  }

  String readText(String path) {
    final file = readable(path);
    if (file.lengthSync() > 8 * 1024 * 1024)
      throw AdminException('यह टेक्स्ट फ़ाइल बहुत बड़ी है।');
    if (!['.json', '.txt', '.md', '.log']
        .contains(p.extension(path).toLowerCase())) {
      throw AdminException('यह टेक्स्ट फ़ाइल नहीं है।');
    }
    return file.readAsStringSync();
  }

  List<File> files(String folder, {bool recursive = true}) {
    final dir = Directory(p.join(root, folder));
    if (!dir.existsSync()) return [];
    if (!p.isWithin(root, dir.resolveSymbolicLinksSync())) {
      throw AdminException('बाहरी linked फ़ोल्डर नहीं खोल सकते।', 403);
    }
    return dir
        .listSync(recursive: recursive, followLinks: false)
        .whereType<File>()
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
  }

  Map<String, dynamic>? jsonMap(File file) {
    try {
      final data = jsonDecode(file.readAsStringSync());
      return data is Map ? Map<String, dynamic>.from(data) : null;
    } catch (_) {
      return null;
    }
  }

  Map<String, List<String>> sourceMap() {
    final out = <String, List<String>>{};
    final base = Directory(p.join(root, 'tools', 'granth_paath'));
    if (base.existsSync()) {
      for (final dir
          in base.listSync(followLinks: false).whereType<Directory>()) {
        final kram = File(p.join(dir.path, 'kram.json'));
        if (!kram.existsSync()) continue;
        final data = jsonMap(kram);
        if (data == null) continue;
        final id = data['id']?.toString() ?? p.basename(dir.path);
        final asset = 'app/assets/${data['assetDir'] ?? 'granth/$id'}';
        for (final file in files(asset, recursive: false)) {
          if (!file.path.endsWith('.json')) continue;
          final name = p.basenameWithoutExtension(file.path);
          final key =
              name.startsWith('${id}_') ? name.substring(id.length + 1) : '';
          final candidates = data['dhancha'] == 'khand'
              ? ['${relative(dir.path)}/paath/$key.txt', relative(kram.path)]
              : [
                  '${relative(dir.path)}/arth/$key.txt',
                  '${relative(dir.path)}/mool.txt',
                  relative(kram.path),
                  '${relative(dir.path)}/pushpika.txt'
                ];
          out[relative(file.path)] = candidates
              .where((s) => File(p.join(root, s)).existsSync())
              .toList();
        }
      }
    }
    for (final file in files('tools/aarti_paath', recursive: false)) {
      if (p.extension(file.path) == '.txt' &&
          file.readAsLinesSync().any((line) =>
              line.trim().isNotEmpty && !line.trimLeft().startsWith('#'))) {
        out['app/assets/paath/${p.basenameWithoutExtension(file.path)}.json'] =
            [relative(file.path)];
      }
    }
    return out;
  }

  List<Map<String, dynamic>> inventory() {
    final sources = sourceMap();
    final out = <Map<String, dynamic>>[];
    for (final group in ['vidhi', 'vrat', 'paath', 'granth', 'parv', 'katha']) {
      for (final file in files('app/assets/$group')) {
        if (!file.path.endsWith('.json') ||
            p.basename(file.path).startsWith('_')) continue;
        final data = jsonMap(file);
        final path = relative(file.path);
        out.add({
          'path': path,
          'id': data?['id'] ?? p.basenameWithoutExtension(file.path),
          'name': data?['naam'] ?? p.basename(file.path),
          'group': group,
          'description': data?['ekLine'] ?? data?['parichay'] ?? '',
          'aliases': data?['upnaam'] is List
              ? (data!['upnaam'] as List).join(' ')
              : '',
          'valid': data != null,
          'generated': sources.containsKey(path),
          'sources': sources[path] ?? [path],
          'blocks': ((data?['khand'] ?? data?['charan']) is List
                  ? (data?['khand'] ?? data?['charan']) as List
                  : const [])
              .length,
        });
      }
    }
    return out;
  }

  Map<String, dynamic> content(String path) {
    final item = inventory().where((e) => e['path'] == path).firstOrNull;
    if (item == null) throw AdminException('सामग्री नहीं मिली।', 404);
    final text = readText(path);
    return {
      ...item,
      'data': jsonDecode(text),
      'raw': text,
      'sourceFiles': [
        for (final source in item['sources'] as List)
          {
            'path': source,
            'text': readText(source as String),
            'hash': fingerprint(readText(source))
          }
      ]
    };
  }

  bool editable(String path) {
    final contentPaths = inventory();
    return contentPaths.any((item) => (item['sources'] as List).contains(path));
  }

  Map<String, dynamic> saveDraft(Map<String, dynamic> input) {
    final source = input['source'];
    final text = input['text'];
    final baseHash = input['baseHash'];
    if (source is! String ||
        text is! String ||
        baseHash is! String ||
        !editable(source)) {
      throw AdminException('सही मूल फ़ाइल और ड्राफ़्ट चुनें।');
    }
    final before = readText(source);
    if (fingerprint(before) != baseHash)
      throw AdminException(
          'मूल फ़ाइल बाहर से बदली है। फिर खोलकर नया मिलान करें।', 409);
    if (text.length > 1000000) throw AdminException('ड्राफ़्ट बहुत बड़ा है।');
    if (source.endsWith('.json')) {
      dynamic data;
      try {
        data = jsonDecode(text);
      } catch (_) {
        throw AdminException('JSON में गलती है; पहले उसे ठीक करें।');
      }
      final original = jsonDecode(before);
      if (data is! Map || original is! Map || data['id'] != original['id']) {
        throw AdminException('मूल पहचान (id) और JSON का ढाँचा सुरक्षित रखें।');
      }
      for (final entry in original.entries) {
        if (!data.containsKey(entry.key))
          throw AdminException('मूल फ़ील्ड ${entry.key} हटाई गई है।');
      }
    }
    final id =
        '${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(0x7fffffff)}';
    final record = <String, dynamic>{
      'id': id,
      'source': source,
      'baseHash': baseHash,
      'before': before,
      'text': text,
      'title': input['title'] is String ? input['title'] : p.basename(source),
      'note': input['note'] is String ? input['note'] : '',
      'savedAt': DateTime.now().toUtc().toIso8601String(),
      'status': 'draft',
    };
    final dir = Directory(p.join(root, 'admin', '.workspace', 'drafts'))
      ..createSync(recursive: true);
    if (!p.isWithin(root, dir.resolveSymbolicLinksSync())) {
      throw AdminException(
          'ड्राफ़्ट फ़ोल्डर प्रोजेक्ट के बाहर नहीं हो सकता।', 403);
    }
    final target = File(p.join(dir.path, '$id.json'));
    final temp = File('${target.path}.tmp');
    temp.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(record),
        flush: true);
    temp.renameSync(target.path);
    return {...record, 'conflict': false};
  }

  List<Map<String, dynamic>> drafts() {
    return files('admin/.workspace/drafts', recursive: false)
        .where((f) => f.path.endsWith('.json'))
        .map((f) {
          final data = jsonMap(f);
          if (data == null) return null;
          try {
            data['conflict'] =
                fingerprint(readText(data['source'] as String)) !=
                    data['baseHash'];
          } catch (_) {
            data['conflict'] = true;
          }
          return data;
        })
        .whereType<Map<String, dynamic>>()
        .toList()
      ..sort(
          (a, b) => b['savedAt'].toString().compareTo(a['savedAt'].toString()));
  }

  List<Map<String, dynamic>> images() {
    final content = files('app/lib',
        recursive: true); // lib is scanned only for references, never exposed.
    final dartText = content
        .where((f) => f.path.endsWith('.dart'))
        .map((f) => f.readAsStringSync())
        .join('\n');
    final manifests = <String, Map>{};
    for (final f in files('design_sources')) {
      if (p.basename(f.path) != 'export_manifest.json') continue;
      try {
        final data = jsonDecode(f.readAsStringSync());
        if (data is List)
          for (final row in data.whereType<Map>()) {
            final asset = row['asset']?.toString().replaceAll('\\', '/');
            if (asset != null) manifests[asset] = row;
          }
      } catch (_) {
        /* An unrelated manifest cannot break the image catalogue. */
      }
    }
    return files('app/assets/images')
        .where((f) => ['.png', '.webp', '.jpg', '.jpeg']
            .contains(p.extension(f.path).toLowerCase()))
        .map((f) {
      final path = relative(f.path), manifest = manifests[path];
      return <String, dynamic>{
        'path': path,
        'name': manifest?['title'] ?? p.basename(f.path),
        'id': manifest?['id'],
        'bytes': f.lengthSync(),
        'references': RegExp(RegExp.escape(p.basename(f.path)))
            .allMatches(dartText)
            .length,
        'hash': sha256.convert(f.readAsBytesSync()).toString(),
        'master': manifest?['source'] != null
      };
    }).toList();
  }

  List<Map<String, dynamic>> documents() => files('docs', recursive: false)
      .where((f) => p.extension(f.path) == '.md')
      .map((f) => <String, dynamic>{
            'path': relative(f.path),
            'name': p.basenameWithoutExtension(f.path),
            'modified': f.lastModifiedSync().toUtc().toIso8601String(),
          })
      .toList();

  List<Map<String, dynamic>> reports() => files('design_sources')
          .where((f) =>
              f.path.endsWith('.log') &&
              !f.path.contains('${p.separator}phone${p.separator}'))
          .map((file) {
        final text =
            file.lengthSync() > 2 * 1024 * 1024 ? '' : file.readAsStringSync();
        final passes = RegExp(r'\+(\d+)(?:\s|:)').allMatches(text).toList();
        return <String, dynamic>{
          'path': relative(file.path),
          'name': p.basename(file.path),
          'modified': file.lastModifiedSync().toUtc().toIso8601String(),
          'outcome': text.contains('All tests passed!') ||
                  text.contains('No issues found!')
              ? 'passed'
              : text.contains('Some tests failed') || text.contains('[E]')
                  ? 'failed'
                  : 'record',
          'count': passes.isEmpty ? null : int.tryParse(passes.last.group(1)!),
          'historical': true
        };
      }).toList()
        ..sort((a, b) =>
            b['modified'].toString().compareTo(a['modified'].toString()));

  Map<String, dynamic> snapshot() {
    final items = inventory();
    final issues = File(p.join(root, 'docs', 'JAANCH_SAMASYA_PANJI.md'));
    final issueText = issues.existsSync() ? issues.readAsStringSync() : '';
    final ids = RegExp(r'\b(?:J|U|UX)-\d{3}\b')
        .allMatches(issueText)
        .map((m) => m[0])
        .toSet();
    return {
      'workspace': root,
      'items': items,
      'documents': documents(),
      'reports': reports(),
      'drafts': drafts(),
      'issueReferences': ids.length,
      'generatedCount': items.where((e) => e['generated'] == true).length,
      'invalidCount': items.where((e) => e['valid'] != true).length,
      'scannedAt': DateTime.now().toUtc().toIso8601String()
    };
  }
}
