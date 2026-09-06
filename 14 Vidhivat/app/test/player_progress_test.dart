import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/state/settings.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await settings.load();
  });

  test('हर पूजा की आख़िरी app position अलग रहती है', () async {
    await settings.recordLastReachedStep(
      pujaId: 'satyanarayan',
      stepIndex: 4,
      totalSteps: 14,
    );
    await settings.recordLastReachedStep(
      pujaId: 'ganesh_poojan',
      stepIndex: 2,
      totalSteps: 11,
    );

    expect(settings.playerProgressFor('satyanarayan', 14)?.lastReachedStepIndex,
        4);
    expect(
        settings.playerProgressFor('ganesh_poojan', 11)?.lastReachedStepIndex,
        2);
    expect(settings.playerProgressFor('nitya_pooja', 9), isNull);
  });

  test('पीछे जाने से furthest app position मिटती नहीं', () async {
    await settings.recordLastReachedStep(
      pujaId: 'satyanarayan',
      stepIndex: 6,
      totalSteps: 14,
    );
    await settings.recordLastReachedStep(
      pujaId: 'satyanarayan',
      stepIndex: 2,
      totalSteps: 14,
    );

    expect(settings.playerProgressFor('satyanarayan', 14)?.lastReachedStepIndex,
        6);
  });

  test('stale और corrupt local progress सुरक्षित रहती है', () async {
    // ⚠️ `updatedAt` आज का ही रखना है। पहले यहाँ `1` लिखा था (यानी 1970),
    // और वो अब जान-बूझकर हटा दिया जाता है (→ D-044) — इसलिए यह जाँच
    // असल में index के clamp होने की है, तारीख़ की नहीं।
    final aaj = DateTime.now().millisecondsSinceEpoch;
    SharedPreferences.setMockInitialValues({
      'playerProgress.v1':
          '{"satyanarayan":{"lastReachedStepIndex":99,"totalStepsAtSave":99,'
              '"updatedAt":$aaj},"broken":{"lastReachedStepIndex":"x"}}',
    });
    await settings.load();

    expect(settings.playerProgressFor('satyanarayan', 14)?.lastReachedStepIndex,
        13);
    expect(settings.playerProgressFor('broken', 14), isNull);
  });

  // ── अधूरी पूजा अगली सुबह तक ही (→ D-044) ─────────────────────────
  //
  // सीमा **ब्रह्म मुहूर्त** है, न आधी रात न सूर्योदय — दोनों वजहें
  // engine के `hindu_din_test.dart` में लिखी हैं। यहाँ सिर्फ़ यह देखना
  // है कि ऐप उस सीमा को मानता है।
  group('कल की अधूरी पूजा आज नहीं उठती', () {
    Future<void> rakhoPuraniProgress(DateTime kab) async {
      SharedPreferences.setMockInitialValues({
        'playerProgress.v1':
            '{"satyanarayan":{"lastReachedStepIndex":6,"totalStepsAtSave":14,'
                '"updatedAt":${kab.millisecondsSinceEpoch}}}',
      });
      await settings.load();
    }

    test('तीन दिन पुरानी अधूरी पूजा नहीं दिखती', () async {
      await rakhoPuraniProgress(
          DateTime.now().subtract(const Duration(days: 3)));

      expect(settings.playerProgressFor('satyanarayan', 14), isNull);
      expect(settings.latestPlayerProgressPujaId, isNull);
    });

    test('कल शाम की अधूरी पूजा भी नहीं दिखती', () async {
      await rakhoPuraniProgress(
          DateTime.now().subtract(const Duration(hours: 30)));

      expect(settings.playerProgressFor('satyanarayan', 14), isNull);
    });

    test('अभी-अभी छूटी पूजा दिखती है', () async {
      await rakhoPuraniProgress(
          DateTime.now().subtract(const Duration(minutes: 20)));

      expect(settings.playerProgressFor('satyanarayan', 14)?.lastReachedStepIndex,
          6);
      expect(settings.latestPlayerProgressPujaId, 'satyanarayan');
    });

    test('बीत चुकी progress फ़ोन में जमा भी नहीं होती', () async {
      await rakhoPuraniProgress(
          DateTime.now().subtract(const Duration(days: 3)));

      // load पर ही छँट गई — इसलिए दोबारा लिखने पर भी वापस नहीं आती।
      await settings.recordLastReachedStep(
        pujaId: 'ganesh_poojan',
        stepIndex: 2,
        totalSteps: 10,
      );

      expect(settings.latestPlayerProgressPujaId, 'ganesh_poojan');
    });
  });

  test('completion के बाद केवल active resume location हटती है', () async {
    await settings.recordLastReachedStep(
      pujaId: 'satyanarayan',
      stepIndex: 4,
      totalSteps: 14,
    );
    await settings.recordLastReachedStep(
      pujaId: 'ganesh_poojan',
      stepIndex: 2,
      totalSteps: 11,
    );
    await settings.clearPlayerProgress('satyanarayan');

    expect(settings.playerProgressFor('satyanarayan', 14), isNull);
    expect(
        settings.playerProgressFor('ganesh_poojan', 11)?.lastReachedStepIndex,
        2);
  });

  test('फोन के exact coordinates और location prompt state local रहते हैं',
      () async {
    await settings.setCityFromDeviceLocation(
      latitude: 25.6123,
      longitude: 85.1367,
    );
    await settings.markLocationPermissionPromptSeen();

    expect(settings.city.name, 'पटना');
    expect(settings.city.latitude, 25.6123);
    expect(settings.city.longitude, 85.1367);
    expect(settings.city.isDeviceDetected, isTrue);
    expect(settings.locationPermissionPromptSeen, isTrue);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('city.v2'), contains('25.6123'));
    expect(preferences.getBool('locationPromptSeen.v1'), isTrue);
  });
}
