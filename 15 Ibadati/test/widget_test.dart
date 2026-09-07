import 'package:flutter_test/flutter_test.dart';
import 'package:ibadati/main.dart';
import 'package:ibadati/screen_library.dart';

void main() {
  testWidgets('Ibadati launches', (tester) async {
    await tester.pumpWidget(const IbadatiApp());
    expect(find.text('Ibadati'), findsWidgets);
    expect(find.text('Maghrib'), findsWidgets);
  });

  test('all agreed screens are implemented', () {
    expect(ibadatiScreenSpecs, hasLength(41));
    expect(ibadatiScreenSpecs.map((screen) => screen.id), containsAll(<String>[
      'onboarding',
      'qibla',
      'dua-reader',
      'tasbih',
      'ramadan',
      'zakat',
      'privacy-data',
      'network-state',
      'action-confirmed',
    ]));
  });
}
