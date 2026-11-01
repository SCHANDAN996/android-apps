import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nischint/app/app_state.dart';
import 'package:nischint/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app starts and shows the first screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await tester.pumpWidget(NischintApp(state: state));
    await state.load();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
