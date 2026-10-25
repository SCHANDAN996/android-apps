import 'dart:convert';

// Reuse the app's pure-Dart parsers; the panel does not maintain a second schema.
import '../../app/lib/vidhi/granth.dart';
import '../../app/lib/vidhi/katha.dart';
import '../../app/lib/vidhi/paath.dart';
import '../../app/lib/vidhi/parv.dart';
import '../../app/lib/vidhi/vidhi.dart';
import '../../app/lib/vidhi/vrat_panna.dart';
import 'dart:io';

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

void validateContent(String path, String before, String after,
    {bool generated = false}) {
  try {
    final old = jsonDecode(before) as Map<String, dynamic>;
    final data = jsonDecode(after) as Map<String, dynamic>;
    if (old['id'] != data['id'] ||
        old['schemaVersion'] != data['schemaVersion']) {
      throw const FormatException(
          'पहचान और schemaVersion बदलना इस संपादन का हिस्सा नहीं है।');
    }
    for (final field in ['khand', 'charan', 'adhyay', 'din']) {
      if (old[field] is List &&
          data[field] is List &&
          (old[field] as List).length != (data[field] as List).length) {
        throw FormatException(
            '$field का क्रम/आकार बदलने के लिए अलग migration जरूरी है।');
      }
    }
    if (path.endsWith('/_kram.json')) {
      final a = GranthKram.parse(path, before).kram.map((e) => e.id).toList();
      final b = GranthKram.parse(path, after).kram.map((e) => e.id).toList();
      if (jsonEncode(a) != jsonEncode(b))
        throw const FormatException('अध्यायों की पहचान और क्रम सुरक्षित रखें।');
    } else if (path.startsWith('app/assets/vidhi/')) {
      Vidhi.fromJson(path, data);
    } else if (path.startsWith('app/assets/paath/') ||
        path.startsWith('app/assets/granth/')) {
      Paath.fromJson(path, data);
      // A text generator must not silently erase meanings already present.
      for (final key in generated ? ['arth', 'roman'] : <String>[]) {
        int count(Map<String, dynamic> item) => (item['khand'] as List? ?? [])
            .whereType<Map>()
            .where((row) => '${row[key] ?? ''}'.trim().isNotEmpty)
            .length;
        if (count(data) < count(old))
          throw FormatException(
              'पहले भरे $key मिट रहे हैं। पाठ के साथ उनका पूरा संपादन पहले करें।');
      }
    } else if (path.startsWith('app/assets/vrat/')) {
      VratPanna.parse(path, after);
    } else if (path.startsWith('app/assets/katha/')) {
      Katha.parse(path, after);
    } else if (path.startsWith('app/assets/parv/')) {
      Parv.fromJson(path, data);
    } else {
      throw const FormatException('इस सामग्री का validator उपलब्ध नहीं है।');
    }
  } catch (error) {
    throw FormatException('सामग्री की जाँच रुकी: $path\n$error');
  }
}

Future<void> main() async {
  try {
    final rows = jsonDecode(await stdin.transform(utf8.decoder).join()) as List;
    for (final row in rows) {
      validateContent(row['path'] as String, row['before'] as String,
          row['after'] as String,
          generated: row['generated'] == true);
    }
    stdout.writeln(jsonEncode({'ok': true, 'files': rows.length}));
  } catch (error) {
    stdout.writeln(jsonEncode({'error': error.toString()}));
    exitCode = 1;
  }
}
