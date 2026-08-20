import 'dart:convert';
import 'dart:io';

import 'package:panchang_engine/panchang_engine.dart';

/// टर्मिनल से पंचांग देखने का औज़ार।
///
///   dart run tool/panchang_cli.dart                     आज का, दिल्ली
///   dart run tool/panchang_cli.dart 2026-10-10          उस दिन का
///   dart run tool/panchang_cli.dart 2026-10-10 patna    उस शहर का
///   dart run tool/panchang_cli.dart --fill              जाँच वाली सारी तारीख़ें
///   dart run tool/panchang_cli.dart --month 2026-10     पूरे महीने की सूची
///   dart run tool/panchang_cli.dart --festivals 2026    साल के त्योहार
///   dart run tool/panchang_cli.dart --chogh 2026-08-20  चौघड़िया और होरा

const _places = {
  'delhi': Place.delhi,
  'patna': Place.patna,
  'jaipur': Place.jaipur,
  'nagpur': Place.nagpur,
  'chennai': Place.chennai,
  'varanasi': Place.varanasi,
  'mumbai': Place.mumbai,
};

void main(List<String> args) {
  if (args.contains('--fill')) {
    _printReferenceDates();
    return;
  }

  final festivalIndex = args.indexOf('--festivals');
  if (festivalIndex >= 0) {
    final year = args.length > festivalIndex + 1
        ? int.parse(args[festivalIndex + 1])
        : DateTime.now().year;
    final place =
        _placeFrom(args.length > festivalIndex + 2 ? args[festivalIndex + 2] : 'delhi');
    _printFestivals(year, place);
    return;
  }

  final choghIndex = args.indexOf('--chogh');
  if (choghIndex >= 0) {
    final now = DateTime.now();
    var y = now.year, mo = now.month, dy = now.day;
    if (args.length > choghIndex + 1 && args[choghIndex + 1].contains('-')) {
      final parts = args[choghIndex + 1].split('-').map(int.parse).toList();
      y = parts[0];
      mo = parts[1];
      dy = parts[2];
    }
    final place =
        _placeFrom(args.length > choghIndex + 2 ? args[choghIndex + 2] : 'delhi');
    _printChoghadiya(y, mo, dy, place);
    return;
  }

  final monthIndex = args.indexOf('--month');
  if (monthIndex >= 0 && args.length > monthIndex + 1) {
    final parts = args[monthIndex + 1].split('-').map(int.parse).toList();
    final place =
        _placeFrom(args.length > monthIndex + 2 ? args[monthIndex + 2] : 'delhi');
    _printMonth(parts[0], parts[1], place);
    return;
  }

  final now = DateTime.now();
  var year = now.year, month = now.month, day = now.day;

  if (args.isNotEmpty && args[0].contains('-')) {
    final parts = args[0].split('-').map(int.parse).toList();
    year = parts[0];
    month = parts[1];
    day = parts[2];
  }

  final place = _placeFrom(args.length > 1 ? args[1] : 'delhi');
  _printFull(computePanchang(year, month, day, place));
}

Place _placeFrom(String key) {
  final place = _places[key.toLowerCase()];
  if (place == null) {
    stderr.writeln('शहर नहीं मिला: $key');
    stderr.writeln('मौजूद हैं: ${_places.keys.join(", ")}');
    exit(1);
  }
  return place;
}

void _printFull(Panchang p) {
  final d = p.date;
  final line = '─' * 58;

  print('');
  print('  पंचांग · ${d.day}/${d.month}/${d.year} · ${p.place.name}');
  print('  $line');
  print('  ${p.varaName}   ·   ${p.masaFullName} ${p.pakshaName} पक्ष'
      '${p.isAdhikaMasa ? "   ← पुरुषोत्तम मास" : ""}');
  print('  विक्रम संवत् ${p.vikramSamvat} ${p.vikramSamvatsara}'
      '   ·   शक संवत् ${p.shakaSamvat} ${p.shakaSamvatsara}');
  print('  ${p.ayanaName}   ·   ${p.rituName} ऋतु');
  print('');

  print('  पंचांग');
  print('  $line');
  _angaRows('तिथि', p.tithis, d);
  _angaRows('नक्षत्र', p.nakshatras, d);
  _angaRows('योग', p.yogas, d);
  _angaRows('करण', p.karanas, d);
  print('  ${_pad("वार", 9)}${p.varaName}');

  if (p.kshayaTithiName != null) {
    print('');
    print('  ⚠  क्षय तिथि — ${p.kshayaTithiName} किसी सूर्योदय को नहीं छूती');
  }
  if (p.isVriddhiTithi) {
    print('');
    print('  ⚠  वृद्धि तिथि — ${p.tithi.name} कल भी रहेगी');
  }

  print('');
  print('  सूर्य');
  print('  $line');
  print('  ${_pad("सूर्योदय", 10)}${_hms(p.sunrise)}');
  print('  ${_pad("सूर्यास्त", 10)}${_hms(p.sunset)}');
  print('  ${_pad("दिनमान", 10)}${_dur(p.dinamana)}');
  print('  ${_pad("रात्रिमान", 10)}${_dur(p.ratrimana)}');

  print('');
  print('  चंद्र');
  print('  $line');
  print('  ${_pad("चंद्रोदय", 10)}${_hms(p.moonrise)}${_dayTag(p.moonrise, d)}');
  print('  ${_pad("चंद्रास्त", 10)}${_hms(p.moonset)}${_dayTag(p.moonset, d)}');

  print('');
  print('  काल');
  print('  $line');
  for (final k in [p.abhijit, p.rahuKaal, p.yamaganda, p.gulika, p.bhadra]) {
    if (k == null) continue;
    print('  ${_pad(k.name, 10)}${_hm(k.start)}${_dayTag(k.start, d)}'
        ' – ${_hm(k.end)}${_dayTag(k.end, d)}');
  }

  final chogh = choghadiya(d.year, d.month, d.day, p.place);
  if (chogh.isNotEmpty) {
    final shubh = chogh.where((s) => s.isDay && s.auspicious!).toList();
    print('');
    print('  दिन की शुभ चौघड़िया');
    print('  $line');
    for (final s in shubh) {
      print('  ${_pad(s.name, 10)}${_hm(s.start)} – ${_hm(s.end)}');
    }
    print('  ${_pad("", 10)}(पूरी सूची और होरा: --chogh)');
  }

  print('');
  print('  ${_pad("सूर्य राशि", 13)}${p.sunRashiName}');
  print('  ${_pad("चंद्र राशि", 13)}${p.moonRashiName}');
  print('  ${_pad("अयनांश", 13)}${toDms(p.ayanamsa)}');

  final flags = <String>[
    if (p.isPanchak) 'पंचक',
    if (p.isGandmool) 'गंडमूल',
  ];
  if (flags.isNotEmpty) {
    print('  ${_pad("विशेष", 13)}${flags.join(" · ")}');
  }

  print('');
  print('  दृक् गणित · लाहिड़ी अयनांश · '
      '${p.masaSystem == MasaSystem.purnimanta ? "पूर्णिमांत" : "अमांत"} पद्धति');
  print('');
}

/// एक अंग की सारी पंक्तियाँ — दिन में जितनी बार बदला।
///
/// हिंदू दिन सूर्योदय से अगले सूर्योदय तक चलता है, इसलिए आख़िरी अंग अक्सर
/// अगली सुबह ख़त्म होता है। ऐसे समय के आगे "कल" लिखना ज़रूरी है, वरना
/// यूज़र समझेगा कि आज ही 10:25 बजे ख़त्म हो गया।
void _angaRows(String label, List<Anga> angas, DateTime today) {
  for (var i = 0; i < angas.length; i++) {
    final a = angas[i];
    final head = i == 0 ? _pad(label, 9) : _pad('', 9);
    print('  $head${_pad(a.name, 22)}तक ${_hm(a.endsAt)}${_dayTag(a.endsAt, today)}');
  }
}

/// समय आज का है, कल का, या बीते कल का — यही बताता है।
String _dayTag(DateTime? t, DateTime today) {
  if (t == null) return '';
  final diff = DateTime.utc(t.year, t.month, t.day).difference(today).inDays;
  if (diff == 1) return ' (कल)';
  if (diff == 2) return ' (परसों)';
  if (diff == -1) return ' (बीती रात)';
  if (diff < -1) return ' (${-diff} दिन पहले)';
  if (diff > 2) return ' (+$diff दिन)';
  return '';
}

void _printMonth(int year, int month, Place place) {
  print('');
  print('  ${place.name} — $month/$year');
  print('  ${"─" * 66}');
  print('  ${_pad("दिन", 6)}${_pad("वार", 12)}${_pad("तिथि", 24)}${_pad("नक्षत्र", 18)}');
  print('  ${"─" * 66}');

  final lastDay = DateTime.utc(year, month + 1, 0).day;
  for (var day = 1; day <= lastDay; day++) {
    final p = computePanchang(year, month, day, place);
    final mark = p.kshayaTithiName != null
        ? ' ✕'
        : p.isVriddhiTithi
            ? ' ↑'
            : '';
    print('  ${_pad(day.toString(), 6)}'
        '${_pad(p.varaName, 12)}'
        '${_pad("${p.pakshaName} ${p.tithi.name}$mark", 24)}'
        '${_pad(p.nakshatra.name, 18)}');
  }
  print('');
  print('  ✕ = क्षय तिथि (अगली छूट रही है)   ↑ = वृद्धि तिथि (कल भी वही)');
  print('');
}

void _printFestivals(int year, Place place) {
  const mahine = ['', 'जन', 'फ़र', 'मार्च', 'अप्रैल', 'मई', 'जून',
    'जुल', 'अग', 'सित', 'अक्तू', 'नव', 'दिस'];

  print('');
  print('  त्योहार $year — ${place.name}');
  print('  ${'═' * 66}');

  for (final f in festivalsInYear(year, place)) {
    final tarikh = '${f.date.day} ${mahine[f.date.month]}';
    final nishan = [
      if (f.shiftedForBhadra) 'भद्रा से खिसका',
      if (f.missedKaal) 'तिथि ने काल छुआ नहीं',
      if (f.ambiguous)
        'दो दावेदार — ${f.otherCandidate!.day} ${mahine[f.otherCandidate!.month]} भी',
    ].join(' · ');

    print('');
    print('  ${_pad(tarikh, 12)}${f.rule.name}'
        '${nishan.isEmpty ? "" : "   [$nishan]"}');
    for (final line in f.explanation.split('\n')) {
      print('  ${_pad("", 12)}$line');
    }
  }

  print('');
  print('  ${'═' * 66}');
  print('  हर तारीख़ के नीचे लिखा है कि वो कैसे निकली — पंडित जी ख़ुद जाँच सकें।');
  print('');
}

void _printChoghadiya(int year, int month, int day, Place place) {
  final line = '─' * 58;

  print('');
  print('  चौघड़िया और होरा · $day/$month/$year · ${place.name}');
  print('  $line');
  print('  ${varaNameFor(year, month, day)}');

  final chogh = choghadiya(year, month, day, place);
  final horas = hora(year, month, day, place);
  if (chogh.isEmpty) {
    print('  इस जगह के लिए नहीं निकल सका।');
    return;
  }

  for (final din in [true, false]) {
    print('');
    print('  ${din ? "दिन" : "रात"} की चौघड़िया');
    print('  $line');
    for (final s in chogh.where((s) => s.isDay == din)) {
      print('  ${_pad(s.name, 10)}${_hm(s.start)} – ${_hm(s.end)}'
          '   ${s.auspicious! ? "शुभ" : "अशुभ"}');
    }
  }

  print('');
  print('  होरा   (दिन का ${horas.first.duration.inMinutes} मिनट, '
      'रात का ${horas[12].duration.inMinutes} मिनट)');
  print('  $line');
  for (var i = 0; i < horas.length; i++) {
    final h = horas[i];
    final aage = i == 11 ? '   ← सूर्यास्त' : (i == 23 ? '   ← सूर्योदय' : '');
    print('  ${_pad((i + 1).toString(), 4)}${_pad(h.name, 9)}'
        '${_hm(h.start)} – ${_hm(h.end)}$aage');
  }

  print('');
  print('  चौबीस होरा बाद अगले वार का स्वामी आ जाता है —');
  print('  वारों का क्रम इसी से बना है।');
  print('');
}

void _printReferenceDates() {
  final file = File('test/data/reference_dates.json');
  if (!file.existsSync()) {
    stderr.writeln('test/data/reference_dates.json नहीं मिली');
    exit(1);
  }

  final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final cities = data['cities'] as Map<String, dynamic>;
  final entries = (data['entries'] as List).cast<Map<String, dynamic>>();

  print('');
  print('  drikpanchang.com या छपे पंचांग से मिलाओ, फिर reference_dates.json में भरो।');
  print('  ${"═" * 66}');

  for (final entry in entries) {
    final dateText = entry['date'] as String?;
    if (dateText == null) continue;

    final cityKey = entry['city'] as String;
    final city = cities[cityKey] as Map<String, dynamic>;
    final place = Place(
      name: city['name'] as String,
      latitude: (city['lat'] as num).toDouble(),
      longitude: (city['lon'] as num).toDouble(),
    );

    final parts = dateText.split('-').map(int.parse).toList();
    final p = computePanchang(parts[0], parts[1], parts[2], place);
    final done = entry['expected'] != null ? '✅' : '⬜';
    final note = (entry['note'] as String?)?.isNotEmpty == true
        ? '   (${entry['note']})'
        : '';

    print('');
    print('  $done  $dateText — ${place.name}$note');
    print('      "expected": {');
    print('        "tithi": ${p.tithi.number},');
    print('        "tithiEndsAt": "${_hm(p.tithi.endsAt)}",');
    print('        "nakshatra": ${p.nakshatra.number},');
    print('        "nakshatraEndsAt": "${_hm(p.nakshatra.endsAt)}",');
    print('        "yoga": ${p.yoga.number},');
    print('        "sunrise": "${_hm(p.sunrise)}",');
    print('        "sunset": "${_hm(p.sunset)}",');
    print('        "masa": "${p.masaFullName}",');
    print('        "paksha": "${p.pakshaName}"');
    print('      }');
  }
  print('');
  print('  ${"═" * 66}');
  print('');
}

String _pad(String s, int width) =>
    s.length >= width ? s : s + ' ' * (width - s.length);

String _hm(DateTime? t) => t == null
    ? '—'
    : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

String _hms(DateTime? t) =>
    t == null ? '—' : '${_hm(t)}:${t.second.toString().padLeft(2, '0')}';

String _dur(Duration? d) => d == null
    ? '—'
    : '${d.inHours} घंटे ${d.inMinutes % 60} मिनट ${d.inSeconds % 60} सेकंड';
