import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/state/settings.dart';

void main() {
  test('संकल्प profiles locally switch, remove और clear होते हैं', () async {
    SharedPreferences.setMockInitialValues({});
    final localSettings = AppSettings();
    await localSettings.load();

    await localSettings.setYajman(name: 'चन्दन', gotra: 'कश्यप');
    await localSettings.addSankalpPerson(name: 'सीमा', gotra: 'भारद्वाज');

    expect(localSettings.sankalpPeople, hasLength(2));
    expect(localSettings.activeSankalpPerson?.name, 'सीमा');

    await localSettings.selectSankalpPerson('default-profile');
    expect(localSettings.activeSankalpPerson?.name, 'चन्दन');

    final secondId = localSettings.sankalpPeople.last.id;
    await localSettings.removeSankalpPerson(secondId);
    expect(localSettings.sankalpPeople, hasLength(1));

    await localSettings.clearSankalpPeople();
    expect(localSettings.sankalpPeople, isEmpty);
    expect(localSettings.activeSankalpPerson, isNull);
  });

  test('संकल्प profiles app restart के बाद भी phone पर रहते हैं', () async {
    SharedPreferences.setMockInitialValues({});
    final first = AppSettings();
    await first.load();
    await first.setYajman(name: 'चन्दन', gotra: 'कश्यप');
    await first.addSankalpPerson(name: 'सीमा', gotra: 'भारद्वाज');

    final restored = AppSettings();
    await restored.load();

    expect(restored.sankalpPeople, hasLength(2));
    expect(restored.activeSankalpPerson?.name, 'सीमा');
    expect(restored.activeSankalpPerson?.gotra, 'भारद्वाज');
  });
}
