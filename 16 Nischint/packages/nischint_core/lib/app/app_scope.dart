import 'package:flutter/widgets.dart';

import 'app_state.dart';

/// [AppState] को पूरे ऐप में पहुँचाने वाला विजेट।
///
/// पढ़ने और बदलाव पर दोबारा बनने के लिए: `AppScope.of(context)`
/// सिर्फ़ काम करवाने के लिए (जैसे बटन दबाने पर): `AppScope.read(context)`
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope ऊपर नहीं मिला');
    return scope!.notifier!;
  }

  static AppState read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope ऊपर नहीं मिला');
    return scope!.notifier!;
  }
}
