import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidhivat/services/device_location_service.dart';
import 'package:vidhivat/services/osm_khoj.dart';
import 'package:vidhivat/theme.dart';
import 'package:vidhivat/widgets/jagah_khoj.dart';

void main() {
  setUp(() {
    osmKhoj =
        OsmKhoj(laao: (_) async => const OsmJawab(200, '{"features":[]}'));
  });

  Widget host(Future<DeviceLocationResult> Function() location) => MaterialApp(
        theme: VidhivatTheme.dark(),
        home: Builder(builder: (context) {
          return Scaffold(
            body: TextButton(
              onPressed: () => jagahChuno(context,
                  shirshak: 'जन्म की जगह',
                  phoneKiJagah: 'तभी, जब आप अभी जन्म की जगह पर ही हों',
                  jagahLo: location),
              child: const Text('जगह चुनें'),
            ),
          );
        }),
      );

  testWidgets('GPS exception leaves search usable and permits retry',
      (tester) async {
    var calls = 0;
    await tester.pumpWidget(host(() async {
      calls++;
      if (calls == 1) throw PlatformException(code: 'unavailable');
      return const DeviceLocationResult.failed(
          DeviceLocationFailure.permissionDenied);
    }));
    await tester.tap(find.text('जगह चुनें'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('phone_ki_jagah')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.textContaining('जगह नहीं मिल पाई'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.tap(find.byKey(const Key('phone_ki_jagah')));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.textContaining('अनुमति नहीं मिली'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('jagah_khoj')), 'Delhi');
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'दिल्ली'), findsWidgets);
  });

  testWidgets('keyboard leaves the search list above its covered area',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(host(() async => const DeviceLocationResult.failed(
        DeviceLocationFailure.serviceDisabled)));
    await tester.tap(find.text('जगह चुनें'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pumpAndSettle();
    final list = find.descendant(
        of: find.byType(JagahKhojSheet), matching: find.byType(ListView));
    expect(tester.getBottomLeft(list).dy, lessThanOrEqualTo(360.01));
    final search = find.byKey(const Key('jagah_khoj'));
    await tester.ensureVisible(search);
    await tester.enterText(search, 'Delhi');
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    final result = find.widgetWithText(ListTile, 'दिल्ली').first;
    await tester.scrollUntilVisible(result, 100,
        scrollable:
            find.descendant(of: list, matching: find.byType(Scrollable)).first);
    await tester.pumpAndSettle();
    await tester.tap(result);
    await tester.pumpAndSettle();
    expect(find.byType(JagahKhojSheet), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
