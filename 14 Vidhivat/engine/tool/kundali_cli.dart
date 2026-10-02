import 'dart:io';

import 'package:panchang_engine/panchang_engine.dart';

/// टर्मिनल से कुंडली का गणित देखने का औज़ार — **छपी जन्मपत्री से मिलाने के
/// लिए** (→ docs/29 चरण K2, `kundaliIsReady`)।
///
///   dart run tool/kundali_cli.dart 1990-05-15 14:30 patna
///   dart run tool/kundali_cli.dart 1990-05-15 14:30 25.59 85.14
///
/// तारीख़ और समय **भारतीय समय (IST)** में। जगह — शहर का नाम, या अक्षांश और
/// देशांतर (पूर्व धनात्मक)।
///
/// यह सिर्फ़ स्थितियाँ छापता है: लग्न, नौ ग्रह, भाव, नवमांश, दशा की तारीख़ें।
/// फलादेश नहीं — वह इंजन में है ही नहीं।

const _places = {
  'delhi': Place.delhi,
  'patna': Place.patna,
  'jaipur': Place.jaipur,
  'nagpur': Place.nagpur,
  'chennai': Place.chennai,
  'varanasi': Place.varanasi,
  'mumbai': Place.mumbai,
};

String _ansh(double d) {
  final a = d.floor();
  final k = ((d - a) * 60).floor();
  final v = (((d - a) * 60 - k) * 60).round();
  return '${a.toString().padLeft(2)}° ${k.toString().padLeft(2, '0')}′ '
      '${v.toString().padLeft(2, '0')}″';
}

String _tarikh(DateTime utc) {
  final t = utc.add(const Duration(hours: 5, minutes: 30));
  return '${t.day.toString().padLeft(2, '0')}-'
      '${t.month.toString().padLeft(2, '0')}-${t.year}';
}

void main(List<String> args) {
  if (args.length < 3) {
    stderr.writeln('चलाने का ढंग:\n'
        '  dart run tool/kundali_cli.dart 1990-05-15 14:30 patna\n'
        '  dart run tool/kundali_cli.dart 1990-05-15 14:30 <अक्षांश> <देशांतर>');
    exit(64);
  }
  final d = args[0].split('-').map(int.parse).toList();
  final s = args[1].split(':').map(int.parse).toList();
  final Place place;
  if (args.length >= 4) {
    place = Place(
      name: '${args[2]}, ${args[3]}',
      latitude: double.parse(args[2]),
      longitude: double.parse(args[3]),
    );
  } else {
    final p = _places[args[2].toLowerCase()];
    if (p == null) {
      stderr.writeln('शहर "${args[2]}" नहीं मिला। चलेंगे: ${_places.keys.join(', ')} '
          '— या अक्षांश और देशांतर दीजिए।');
      exit(64);
    }
    place = p;
  }

  // IST → UTC
  final janm = DateTime.utc(d[0], d[1], d[2], s[0], s[1])
      .subtract(place.timeZoneOffset);
  final k = computeKundali(janm, place);

  stdout
    ..writeln('जन्म: ${args[0]} ${args[1]} IST · ${place.name} '
        '(${place.latitude}°, ${place.longitude}°)')
    ..writeln('अयनांश (लाहिड़ी): ${_ansh(k.ayanamsa)}')
    ..writeln('')
    ..writeln('लग्न   ${k.lagna.rashiNaam.padRight(8)} ${_ansh(k.lagna.ansh)}   '
        '${k.lagna.nakshatraNaam} चरण ${k.lagna.charan}   '
        'नवमांश ${k.lagna.navamshaNaam}'
        '${k.lagnaSandhiMein() ? '   ⚠ राशि की सीमा के पास' : ''}')
    ..writeln('');
  for (final g in k.grahas) {
    stdout.writeln('${g.graha.naam.padRight(6)} ${g.rashiNaam.padRight(8)} '
        '${_ansh(g.ansh)}   भाव ${k.bhav(g.graha).toString().padLeft(2)}   '
        '${g.nakshatraNaam} चरण ${g.charan}   नवमांश ${g.navamshaNaam}'
        '${g.vakri ? '   (वक्री)' : ''}');
  }

  final chandra = k[KundaliGraha.chandra].nirayan;
  stdout
    ..writeln('')
    ..writeln('विंशोत्तरी — जन्म पर ${nakshatraSwami(k[KundaliGraha.chandra].nakshatra).naam} '
        'की दशा, ${janmParDashaShesh(chandra).toStringAsFixed(2)} साल बची '
        '(साल = $dashaVarshDin दिन)');
  for (final m in vimshottariMahadasha(janm, chandra)) {
    stdout.writeln('  ${m.swami.naam.padRight(6)} ${_tarikh(m.shuru)} → ${_tarikh(m.ant)}');
  }
  // दोनों राहु साथ-साथ — छपी जन्मपत्री में जो मिले, वही उसका चलन है।
  final spasht = computeKundali(janm, place, spashtRahu: true)[KundaliGraha.rahu];
  final madhya = k[KundaliGraha.rahu];
  stdout
    ..writeln('')
    ..writeln('राहु — ऊपर की तालिका में औसत पात है। दोनों रूप:')
    ..writeln('  औसत    ${madhya.rashiNaam.padRight(8)} ${_ansh(madhya.ansh)}   '
        '${madhya.nakshatraNaam} चरण ${madhya.charan}')
    ..writeln('  स्पष्ट  ${spasht.rashiNaam.padRight(8)} ${_ansh(spasht.ansh)}   '
        '${spasht.nakshatraNaam} चरण ${spasht.charan}   (सन्निकट — 0.2° तक इधर-उधर)')
    ..writeln('')
    ..writeln('गणित NASA से मिला हुआ है (docs/08 §18)। छपी जन्मपत्री से मिलाएँ तो '
        'राहु और दशा के साल का चलन देखिए, और docs/08 §16 में दर्ज कीजिए।');
}
