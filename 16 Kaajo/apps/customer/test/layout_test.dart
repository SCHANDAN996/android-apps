import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaajo/screens/customer/customer_home_screen.dart';
import 'package:kaajo/screens/customer/service_detail_screen.dart';
import 'package:kaajo_core/app/app_scope.dart';
import 'package:kaajo_core/app/app_state.dart';
import 'package:kaajo_core/app/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final width in [320.0, 600.0]) {
    testWidgets('home and service navigation at width $width with large text', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final state = AppState();
      await state.load();
      await tester.pumpWidget(AppScope(
        state: state,
        child: MaterialApp(
          theme: buildAppTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: const CustomerHomeScreen(),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final button = find.text('सोलर सफ़ाई बुक करें');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.byType(ServiceDetailScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
