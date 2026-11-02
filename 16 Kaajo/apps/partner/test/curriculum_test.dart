import 'package:flutter_test/flutter_test.dart';
import 'package:kaajo_core/content/config.dart';
import 'package:kaajo_core/models/profiles.dart';
import 'package:kaajo_core/models/training.dart';
import 'package:kaajo_partner/technician/rates.dart';
import 'package:kaajo_partner/training/curriculum.dart';
import 'package:kaajo_partner/training/training_rules.dart';

void main() {
  group('curriculum', () {
    test('5 days, numbered 1-5, each with lessons and 5 questions', () {
      expect(trainingDays.length, 5);
      for (var i = 0; i < trainingDays.length; i++) {
        final d = trainingDays[i];
        expect(d.number, i + 1);
        expect(d.id, 'day${i + 1}');
        expect(d.lessons, isNotEmpty, reason: d.id);
        expect(d.quiz.length, 5, reason: d.id);
      }
    });

    test('every question has 4 options and a valid correctIndex', () {
      for (final d in trainingDays) {
        for (final q in d.quiz) {
          expect(q.options.length, 4, reason: q.question);
          expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1), reason: q.question);
          expect(q.options.toSet().length, q.options.length, reason: 'duplicate option: ${q.question}');
          expect(q.explanation.trim(), isNotEmpty, reason: q.question);
        }
      }
    });

    test('lesson ids are unique and follow d<day>l<n>', () {
      final ids = <String>{};
      for (final d in trainingDays) {
        for (var i = 0; i < d.lessons.length; i++) {
          final l = d.lessons[i];
          expect(l.id, 'd${d.number}l${i + 1}');
          expect(ids.add(l.id), isTrue, reason: 'duplicate ${l.id}');
          expect(l.points, isNotEmpty, reason: l.id);
          expect(l.goal.trim(), isNotEmpty, reason: l.id);
          expect(l.why.trim(), isNotEmpty, reason: l.id);
          expect(l.remember.trim(), isNotEmpty, reason: l.id);
        }
      }
      expect(ids.length, totalLessons);
      expect(lessonNumber(day2, day2.lessons[2]), '2.3');
    });

    test('field trial has 7 unique items', () {
      expect(practicalItems.length, 7);
      expect(practicalItems.map((i) => i.id).toSet().length, 7);
      expect(visitSteps.length, 7);
    });

    test('pass percent: safety day needs 100', () {
      expect(passPercentFor('day2'), 100);
      expect(passPercentFor('day1'), AppConfig.quizPassPercent);
      expect(passPercentFor('day5'), AppConfig.quizPassPercent);
    });

    test('lookup helpers', () {
      expect(dayById('day3'), same(day3));
      expect(dayById('day9'), isNull);
      expect(lessonById(day1, 'd1l4')?.title, isNotNull);
      expect(lessonById(day1, 'd2l1'), isNull);
    });
  });

  group('training rules', () {
    const empty = TrainingProgress();

    test('only day 1 is open at the start', () {
      expect(isDayUnlocked(empty, 0), isTrue);
      expect(isDayUnlocked(empty, 1), isFalse);
      expect(dayStatus(empty, 0), DayStatus.open);
      expect(dayStatus(empty, 1), DayStatus.locked);
      expect(isFieldTrialUnlocked(empty), isFalse);
      expect(fieldTrialStatus(empty), DayStatus.locked);
      expect(canCertify(empty), isFalse);
      expect(overallProgress(empty), 0);
    });

    test('80% passes day 1 but not the safety day', () {
      const p = TrainingProgress(quizBest: {'day1': 80, 'day2': 80});
      expect(isDayPassed(p, 'day1'), isTrue);
      expect(dayStatus(p, 0), DayStatus.done);
      expect(isDayUnlocked(p, 1), isTrue);
      expect(isDayPassed(p, 'day2'), isFalse);
      expect(isDayUnlocked(p, 2), isFalse);
    });

    test('everything passed -> can certify', () {
      final p = TrainingProgress(
        completedLessons: {for (final d in trainingDays) ...d.lessons.map((l) => l.id)},
        quizBest: {for (final d in trainingDays) d.id: 100},
        practicalDone: {for (final i in practicalItems) i.id},
      );
      expect(lessonsDone(p), totalLessons);
      expect(daysPassed(p), 5);
      expect(allQuizzesPassed(p), isTrue);
      expect(isFieldTrialUnlocked(p), isTrue);
      expect(allPracticalDone(p), isTrue);
      expect(canCertify(p), isTrue);
      expect(overallProgress(p), 1);
    });

    test('quizzes passed but trial incomplete -> no certificate', () {
      final p = TrainingProgress(
        quizBest: {for (final d in trainingDays) d.id: 100},
        practicalDone: {practicalItems.first.id},
      );
      expect(fieldTrialStatus(p), DayStatus.open);
      expect(canCertify(p), isFalse);
    });

    test('report message has the key details', () {
      final p = TrainingProgress(
        quizBest: {for (final d in trainingDays) d.id: 100},
        practicalDone: {for (final i in practicalItems) i.id},
        certifiedAt: DateTime(2026, 11, 8),
      );
      const t = TechnicianProfile(name: 'राजेश', mobile: '9876543210', area: 'Shivpur', qualification: 'सूर्य मित्र');
      final msg = trainingReportMessage(t, p);
      expect(msg, contains('राजेश'));
      expect(msg, contains('9876543210'));
      expect(msg, contains('सूर्य मित्र'));
      expect(msg, contains('Shivpur'));
      expect(msg, contains('8 नवंबर 2026'));
      expect(msg, contains('दिन 5'));
      expect(msg, contains('7/7'));
    });
  });

  group('technician rates', () {
    test('examples from the server plan', () {
      expect(TechnicianRates.earning(), 230);
      expect(TechnicianRates.earning(urgent: true), 280);
      expect(TechnicianRates.earning(cleaningKw: 5), 330);

      final cash = TechnicianRates.cashBooking(customerPays: 600);
      expect(cash.earning, 230);
      expect(cash.depositToCompany, 370);

      final vendor = TechnicianRates.vendorComplaint();
      expect(vendor.customerPays, 0);
      expect(vendor.earning, 230);
      expect(TechnicianRates.vendorComplaint(urgent: true).earning, 280);
    });
  });
}
