import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'jobs.dart';
import 'changes.dart';
import 'workspace.dart';

class AdminServer {
  final Workspace workspace;
  final Directory web;
  late final Jobs jobs = Jobs(workspace);
  late final Changes changes = Changes(workspace);
  late final String token = List.generate(32,
          (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'))
      .join();
  late HttpServer _server;
  AdminServer(this.workspace, this.web);
  int get port => _server.port;
  String get url => 'http://127.0.0.1:$port';
  Future<void> start({int port = 0}) async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    _server.listen(handle);
  }

  Future<void> close() => _server.close(force: true);

  Future<void> handle(HttpRequest request) async {
    final response = request.response;
    response.headers.set('X-Content-Type-Options', 'nosniff');
    response.headers.set('X-Frame-Options', 'DENY');
    response.headers.set('Referrer-Policy', 'no-referrer');
    response.headers.set('Cache-Control', 'no-store');
    response.headers.set('Content-Security-Policy',
        "default-src 'self'; img-src 'self' data:; style-src 'self'; script-src 'self'; connect-src 'self'; frame-ancestors 'none'; base-uri 'none'; form-action 'self'");
    try {
      final hosts = ['127.0.0.1:$port', 'localhost:$port'];
      if (!hosts.contains(request.headers.value('host')))
        throw AdminException('स्थानीय पैनल का पता मान्य नहीं है।', 403);
      final origin = request.headers.value('origin');
      if (origin != null && !hosts.any((h) => origin == 'http://$h'))
        throw AdminException('बाहरी पन्ने से अनुरोध की अनुमति नहीं है।', 403);
      if (!['GET', 'POST'].contains(request.method))
        throw AdminException('अनुमति नहीं है।', 405);
      if (request.method == 'POST' &&
          request.headers.value('x-admin-token') != token) {
        throw AdminException('पैनल फिर खोलें; सत्र की पहचान नहीं मिली।', 403);
      }
      final path = request.uri.path;
      if (path == '/api/health') {
        _json(response, {
          'application': 'vidhivat-admin',
          'version': '0.2.0',
          'workspace': workspace.root
        });
      } else if (path == '/api/session') {
        _json(response, {'token': token});
      } else if (path == '/api/snapshot') {
        _json(response, workspace.snapshot());
      } else if (path == '/api/images') {
        _json(response, workspace.images());
      } else if (path == '/api/content') {
        _json(response, workspace.content(_path(request)));
      } else if (path == '/api/document') {
        _json(response, {
          'path': _path(request),
          'text': workspace.readText(_path(request))
        });
      } else if (path == '/api/drafts' && request.method == 'POST') {
        _json(response, workspace.saveDraft(await _body(request)));
      } else if (path == '/api/drafts') {
        _json(response, workspace.drafts());
      } else if (path == '/api/changes') {
        _json(response, {'receipts': changes.receipts()});
      } else if (path == '/api/plan') {
        _json(
            response, changes.getPlan(request.uri.queryParameters['id'] ?? ''));
      } else if (path == '/api/backup') {
        _json(
            response, changes.backup(request.uri.queryParameters['id'] ?? ''));
      } else if (['/api/prepare', '/api/apply', '/api/restore']
              .contains(path) &&
          request.method == 'POST') {
        if (jobs.current?['running'] == true)
          throw AdminException('पहले चल रही जाँच पूरी होने दें।', 409);
        final body = await _body(request);
        final id = body['id'];
        if (id is! String) throw AdminException('सही ड्राफ़्ट/बैकअप चुनें।');
        if (path == '/api/restore' && body['confirmed'] != true)
          throw AdminException('वापसी का मिलान देखकर पुष्टि करें।');
        _json(
            response,
            path == '/api/prepare'
                ? await changes.prepare(id)
                : path == '/api/apply'
                    ? await changes.apply(id, body)
                    : await changes.restore(id));
      } else if (path == '/api/jobs' && request.method == 'POST') {
        if (changes.busy)
          throw AdminException('पहले बदलाव की तैयारी पूरी होने दें।', 409);
        final body = await _body(request);
        _json(response, jobs.start(body['kind']?.toString() ?? ''));
      } else if (path == '/api/jobs') {
        _json(response, jobs.state());
      } else if (path == '/api/stop' && request.method == 'POST') {
        if (jobs.current?['running'] == true || changes.busy)
          throw AdminException('पहले चालू जाँच पूरी होने दें।', 409);
        _json(response, {'stopped': true});
        Future.delayed(const Duration(milliseconds: 350), () => exit(0));
      } else if (path == '/api/image') {
        final file = workspace.readable(_path(request));
        final ext = p.extension(file.path).toLowerCase();
        final types = {
          '.png': 'image/png',
          '.webp': 'image/webp',
          '.jpg': 'image/jpeg',
          '.jpeg': 'image/jpeg'
        };
        if (!types.containsKey(ext))
          throw AdminException('चित्र नहीं मिला।', 404);
        response.headers.set('Content-Type', types[ext]!);
        await response.addStream(file.openRead());
      } else if (!path.startsWith('/api/') && request.method == 'GET') {
        final name = path == '/' ? 'index.html' : path.substring(1);
        if (!['index.html', 'app.js', 'style.css'].contains(name))
          throw AdminException('पन्ना नहीं मिला।', 404);
        final file = File(p.join(web.path, name));
        response.headers.set(
            'Content-Type',
            name.endsWith('.js')
                ? 'text/javascript; charset=utf-8'
                : name.endsWith('.css')
                    ? 'text/css; charset=utf-8'
                    : 'text/html; charset=utf-8');
        await response.addStream(file.openRead());
      } else {
        throw AdminException('पन्ना नहीं मिला।', 404);
      }
    } on AdminException catch (error) {
      response.statusCode = error.status;
      _json(response, {'error': error.message});
    } catch (_) {
      response.statusCode = 500;
      _json(response, {
        'error':
            'यह काम पूरा नहीं हुआ। प्रोजेक्ट की फ़ाइलें जाँचकर फिर कोशिश करें।'
      });
    } finally {
      await response.close();
    }
  }

  String _path(HttpRequest request) =>
      request.uri.queryParameters['path'] ?? '';
  void _json(HttpResponse response, Object data) {
    response.headers.set('Content-Type', 'application/json; charset=utf-8');
    response.write(jsonEncode(data));
  }

  Future<Map<String, dynamic>> _body(HttpRequest request) async {
    if (request.headers.contentType?.mimeType != 'application/json')
      throw AdminException('JSON अनुरोध जरूरी है।', 415);
    var bytes = 0;
    final all = <int>[];
    await for (final part in request) {
      bytes += part.length;
      if (bytes > 2 * 1024 * 1024)
        throw AdminException('अनुरोध बहुत बड़ा है।', 413);
      all.addAll(part);
    }
    try {
      final data = jsonDecode(utf8.decode(all));
      if (data is Map<String, dynamic>) return data;
    } catch (_) {/* Report a bounded, friendly validation error below. */}
    throw AdminException('अनुरोध में सही जानकारी भरें।');
  }
}
