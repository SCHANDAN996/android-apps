/// ट्रेनिंग के नियम: कौन-सा दिन खुला है, क्या पास हुआ, सर्टिफ़िकेट कब मिलेगा।
/// सिर्फ़ Dart (कोई विजेट नहीं), ताकि टेस्ट हो सके।
library;

import 'package:nischint_core/content/config.dart';
import 'package:nischint_core/models/profiles.dart';
import 'package:nischint_core/models/training.dart';
import 'package:nischint_core/utils/format.dart';

import 'curriculum.dart';

/// दिन की स्थिति (होम स्क्रीन के कार्ड पर)।
enum DayStatus { locked, open, done }

/// इस दिन की क्विज़ पास है? (सबसे अच्छा स्कोर ≥ पास प्रतिशत)
bool isDayPassed(TrainingProgress p, String dayId) {
  final best = p.quizBest[dayId];
  return best != null && best >= passPercentFor(dayId);
}

/// दिन 1 हमेशा खुला; दिन N तब खुलता है जब दिन N-1 की क्विज़ पास हो।
/// [index] = trainingDays में जगह (0 = दिन 1)।
bool isDayUnlocked(TrainingProgress p, int index) {
  if (index <= 0) return true;
  if (index > trainingDays.length) return false;
  return isDayPassed(p, trainingDays[index - 1].id);
}

/// दिन 1–5 में से [index] वाले दिन की स्थिति।
DayStatus dayStatus(TrainingProgress p, int index) {
  if (!isDayUnlocked(p, index)) return DayStatus.locked;
  if (isDayPassed(p, trainingDays[index].id)) return DayStatus.done;
  return DayStatus.open;
}

/// फ़ील्ड ट्रायल (दिन 6) दिन 5 की क्विज़ पास होने पर खुलता है।
bool isFieldTrialUnlocked(TrainingProgress p) => isDayPassed(p, trainingDays.last.id);

/// फ़ील्ड ट्रायल की स्थिति।
DayStatus fieldTrialStatus(TrainingProgress p) {
  if (p.isCertified || allPracticalDone(p)) return DayStatus.done;
  if (!isFieldTrialUnlocked(p)) return DayStatus.locked;
  return DayStatus.open;
}

/// दिन 1–5 की सारी क्विज़ पास?
bool allQuizzesPassed(TrainingProgress p) => trainingDays.every((d) => isDayPassed(p, d.id));

/// कितने दिनों की क्विज़ पास।
int daysPassed(TrainingProgress p) => trainingDays.where((d) => isDayPassed(p, d.id)).length;

/// इस दिन के सारे पाठ पढ़ लिए?
bool allLessonsRead(TrainingProgress p, TrainingDay day) =>
    day.lessons.every((l) => p.completedLessons.contains(l.id));

/// इस दिन के कितने पाठ पढ़े।
int lessonsReadIn(TrainingProgress p, TrainingDay day) =>
    day.lessons.where((l) => p.completedLessons.contains(l.id)).length;

/// कुल कितने पाठ पढ़े (सिर्फ़ पाठ्यक्रम वाले id गिने जाते हैं)।
int lessonsDone(TrainingProgress p) =>
    trainingDays.fold(0, (sum, d) => sum + lessonsReadIn(p, d));

/// फ़ील्ड ट्रायल के कितने काम पास।
int practicalDoneCount(TrainingProgress p) =>
    practicalItems.where((i) => p.practicalDone.contains(i.id)).length;

/// फ़ील्ड ट्रायल के सारे 7 काम पास?
bool allPracticalDone(TrainingProgress p) => practicalDoneCount(p) == practicalItems.length;

/// सर्टिफ़िकेट मिल सकता है? (सारी क्विज़ पास + सारे 7 काम पास)
bool canCertify(TrainingProgress p) => allQuizzesPassed(p) && allPracticalDone(p);

/// पूरी ट्रेनिंग कितनी हुई (0.0–1.0): पाठ + क्विज़ + फ़ील्ड के काम, सब बराबर गिने।
double overallProgress(TrainingProgress p) {
  if (p.isCertified) return 1;
  final total = totalLessons + trainingDays.length + practicalItems.length;
  if (total == 0) return 0;
  final done = lessonsDone(p) + daysPassed(p) + practicalDoneCount(p);
  return (done / total).clamp(0.0, 1.0).toDouble();
}

/// मालिक को WhatsApp पर भेजी जाने वाली ट्रेनिंग रिपोर्ट।
String trainingReportMessage(TechnicianProfile t, TrainingProgress p) {
  String orDash(String s) => s.trim().isEmpty ? '—' : s.trim();
  final certified = p.certifiedAt;
  final started = p.startedAt;
  final lines = <String>[
    '*ट्रेनिंग पूरी: प्रशिक्षित टेक्नीशियन*',
    '',
    'नाम: ${orDash(t.name)}',
    'मोबाइल: ${orDash(t.mobile)}',
    'योग्यता: ${orDash(t.qualification)}',
    'इलाका: ${orDash(t.area)}',
    'स्कूटी: ${t.hasScooty ? 'है' : 'नहीं'}',
    if (started != null) 'ट्रेनिंग शुरू: ${hindiDateYear(started)}',
    'सर्टिफ़िकेट की तारीख: ${certified == null ? '—' : hindiDateYear(certified)}',
    '',
    '*क्विज़ के स्कोर*',
    for (final d in trainingDays) 'दिन ${d.number} (${d.title}): ${p.quizBest[d.id] ?? 0}%',
    '',
    'फ़ील्ड ट्रायल: ${practicalDoneCount(p)}/${practicalItems.length} काम सुपरवाइज़र कोड से पास',
    '',
    '(${AppConfig.partnerAppName} ऐप से भेजा गया)',
  ];
  return lines.join('\n');
}
