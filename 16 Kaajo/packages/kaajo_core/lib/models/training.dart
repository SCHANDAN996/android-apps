/// टेक्नीशियन की ट्रेनिंग कहाँ तक पहुँची। फ़ोन में सेव होती है।
class TrainingProgress {
  const TrainingProgress({
    this.completedLessons = const {},
    this.quizBest = const {},
    this.practicalDone = const {},
    this.startedAt,
    this.certifiedAt,
  });

  /// पूरे पढ़े गए पाठ (lesson id)।
  final Set<String> completedLessons;

  /// हर दिन की क्विज़ का सबसे अच्छा स्कोर, प्रतिशत में (day id -> 0..100)।
  final Map<String, int> quizBest;

  /// फ़ील्ड ट्रायल के वे काम जिन पर सुपरवाइज़र ने हाँ की (item id)।
  final Set<String> practicalDone;
  final DateTime? startedAt;

  /// पूरी ट्रेनिंग पास होने की तारीख़।
  final DateTime? certifiedAt;

  bool get isCertified => certifiedAt != null;

  TrainingProgress copyWith({
    Set<String>? completedLessons,
    Map<String, int>? quizBest,
    Set<String>? practicalDone,
    DateTime? startedAt,
    DateTime? certifiedAt,
    bool clearCertified = false,
  }) =>
      TrainingProgress(
        completedLessons: completedLessons ?? this.completedLessons,
        quizBest: quizBest ?? this.quizBest,
        practicalDone: practicalDone ?? this.practicalDone,
        startedAt: startedAt ?? this.startedAt,
        certifiedAt: clearCertified ? null : (certifiedAt ?? this.certifiedAt),
      );

  Map<String, dynamic> toJson() => {
        'completedLessons': completedLessons.toList(),
        'quizBest': quizBest,
        'practicalDone': practicalDone.toList(),
        'startedAt': startedAt?.toIso8601String(),
        'certifiedAt': certifiedAt?.toIso8601String(),
      };

  factory TrainingProgress.fromJson(Map<String, dynamic> j) {
    final quiz = <String, int>{};
    final rawQuiz = j['quizBest'];
    if (rawQuiz is Map) {
      rawQuiz.forEach((k, v) {
        if (v is num) quiz[k.toString()] = v.toInt();
      });
    }
    Set<String> strings(Object? raw) =>
        raw is List ? raw.map((e) => e.toString()).toSet() : <String>{};
    return TrainingProgress(
      completedLessons: strings(j['completedLessons']),
      quizBest: quiz,
      practicalDone: strings(j['practicalDone']),
      startedAt: DateTime.tryParse(j['startedAt'] as String? ?? ''),
      certifiedAt: DateTime.tryParse(j['certifiedAt'] as String? ?? ''),
    );
  }
}
