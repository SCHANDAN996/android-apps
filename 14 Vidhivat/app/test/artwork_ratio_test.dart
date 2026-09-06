// भगवान के चित्र का अनुपात — फ़ोन पर पकड़ा गया बग (→ D-057)।
//
// ⚠️ `Image.asset` को `cacheWidth` **और** `cacheHeight` दोनों देने पर
// Flutter बिंब को ठीक उसी नाप पर खींच देता है — अनुपात नहीं बचाता। और
// `BoxFit.contain` उसे सुधार नहीं सकता, क्योंकि जो bitmap उसे मिलता है
// वो पहले से खिंचा हुआ होता है।
//
// पूजा की तैयारी वाले पन्ने पर डिब्बा चौड़ा है (~296×223) और चित्र खड़ा
// (720×900) — यानी चेहरा लगभग 1.66 गुना चौड़ा दिखता था।
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidhivat/screens/vidhi_list_screen.dart';
import 'package:vidhivat/screens/vidhi_screen.dart';
import 'package:vidhivat/state/settings.dart';
import 'package:vidhivat/theme.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await settings.load();
  });

  Widget app(Widget home) => ListenableBuilder(
        listenable: settings,
        builder: (context, _) => MaterialApp(
          theme: VidhivatTheme.dark(),
          home: home,
        ),
      );

  void phone(WidgetTester tester, {double width = 400, double height = 900}) {
    tester.view.physicalSize = Size(width * 3, height * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  /// हर `Image` की जाँच — किसी पर भी दोनों नाप एक साथ नहीं होनी चाहिए।
  void koiKhinchavNahi(WidgetTester tester, {required String kahan}) {
    final images = tester.widgetList<Image>(find.byType(Image));
    expect(images, isNotEmpty, reason: '$kahan — कोई चित्र मिला ही नहीं');
    for (final img in images) {
      final provider = img.image;
      if (provider is! ResizeImage) continue;
      expect(
        provider.width != null && provider.height != null,
        isFalse,
        reason: '$kahan — दोनों नाप एक साथ दी गई हैं, चित्र खिंच जाएगा '
            '(width ${provider.width}, height ${provider.height})',
      );
    }
  }

  testWidgets('पूजा की तैयारी — hero का चित्र खिंचता नहीं', (tester) async {
    phone(tester);
    await tester.pumpWidget(app(const VidhiScreen(id: 'ganesh_poojan')));
    await tester.pumpAndSettle();
    koiKhinchavNahi(tester, kahan: 'पूजा की तैयारी का hero');
  });

  testWidgets('पूजाओं की सूची — कार्ड के चित्र खिंचते नहीं', (tester) async {
    phone(tester);
    await tester.pumpWidget(app(const VidhiListScreen()));
    await tester.pumpAndSettle();
    koiKhinchavNahi(tester, kahan: 'पूजाओं की सूची के कार्ड');
  });
}
