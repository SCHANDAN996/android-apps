import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// नीचे वाला हर हिस्सा सिस्टम नेविगेशन बार से बचकर रहे।
///
/// ## यह जाँच क्यों लिखी गई
///
/// 4 सितम्बर 2026 — फ़ोन पर दिखा कि ऐप का टैब-बार (होम/पूजा/कैलेंडर/
/// अधिक) Android के नीचे वाले नेविगेशन बार से टकरा रहा है।
///
/// वजह: Android 15 से ऐप **ज़बरदस्ती edge-to-edge** चलता है — यानी
/// उसे पूरी स्क्रीन मिलती है, सिस्टम बार के नीचे की जगह समेत।
///
/// ⚠️ यह जाँच widget नहीं चलाती, **स्रोत पढ़ती है** — क्योंकि असली
/// system inset सिर्फ़ फ़ोन पर होता है, test के नक़ली MediaQuery में
/// शून्य रहता है। इसलिए widget-test इस बग को कभी नहीं पकड़ पाता।
///
/// ## इसी जाँच के दो छेद, जो उसी दिन शाम को मिले
///
/// पहली बार लिखते समय यह सिर्फ़ इतना देखती थी कि फ़ाइल में कहीं
/// `SafeArea` शब्द है या नहीं। उससे **पाँच पन्ने बचकर निकल गए** —
/// चालीसा, चालीसा-सूची, संकल्प (दो जगह) और सेटिंग। दो वजहें थीं:
///
/// 1. **`useSafeArea: true`** — यह `showModalBottomSheet` का झंडा है,
///    पूरी स्क्रीन से उसका कोई लेना-देना नहीं। पर उसमें भी "SafeArea"
///    लिखा है, इसलिए फ़ाइल "पास" हो जाती थी।
/// 2. **`SafeArea(bottom: false)`** — यह नीचे की तरफ़ कुछ बचाता ही
///    नहीं। फिर भी शब्द मौजूद था, इसलिए वो भी पास हो जाता था।
///
/// इसीलिए अब जाँच `SafeArea(` (कोष्ठक समेत) ढूँढ़ती है, `body:` के
/// आसपास ही देखती है, और `bottom: false` को साफ़ ठुकरा देती है।
void main() {
  /// जो पन्ने `HomeShell` के अंदर रहते हैं। इनके नीचे ऐप की अपनी
  /// `NavigationBar` हमेशा रहती है (और वो ख़ुद `SafeArea` में लिपटी है),
  /// इसलिए इनका body नीचे तक जा सकता है — वहाँ नेविगेशन बार नहीं,
  /// ऐप की अपनी पट्टी है।
  const shellKeAndar = {
    'home_dashboard_screen.dart',
    'vidhi_list_screen.dart',
    'calendar_screen.dart',
    'more_screen.dart',
  };

  /// `body:` के बाद के इतने अक्षरों में `SafeArea(` मिलनी चाहिए।
  /// इतनी जगह में `SafeArea` + एक-दो wrapper आराम से आ जाते हैं।
  const dayra = 260;

  test('हर पन्ने का सबसे नीचे का हिस्सा नेविगेशन बार से बचा है', () {
    final chuke = <String>[];

    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final src = f.readAsStringSync();
      final naam = f.uri.pathSegments.last;
      if (shellKeAndar.contains(naam)) continue;
      // नीचे अपनी पट्टी है तो उसी पर SafeArea काफ़ी है — वो अलग जाँच में।
      if (src.contains('bottomNavigationBar:')) continue;

      for (final m in RegExp('body:').allMatches(src)) {
        final aage = src.substring(
          m.start,
          (m.start + dayra).clamp(0, src.length),
        );
        // ⚠️ कोष्ठक ज़रूरी है — `useSafeArea: true` को गिनने से रोकता है।
        final safeAreaHai = aage.contains('SafeArea(');
        final neecheKhula = RegExp(r'bottom:\s*false').hasMatch(aage);

        if (!safeAreaHai || neecheKhula) {
          final line = '\n'.allMatches(src.substring(0, m.start)).length + 1;
          chuke.add('$naam:$line'
              '${neecheKhula ? "  (bottom: false — यह कुछ नहीं बचाता)" : ""}');
        }
      }
    }

    expect(
      chuke,
      isEmpty,
      reason: 'इन पन्नों का सबसे नीचे का हिस्सा Android के नेविगेशन बार '
          'के पीछे चला जाएगा। body को `SafeArea(top: false, …)` में '
          'लपेटो — `bottom: false` मत लिखना:\n  ${chuke.join("\n  ")}',
    );
  });

  test('हर bottomNavigationBar SafeArea के अंदर है', () {
    final chuke = <String>[];

    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final src = f.readAsStringSync();
      var from = 0;
      while (true) {
        final i = src.indexOf('bottomNavigationBar:', from);
        if (i < 0) break;
        from = i + 1;

        // पट्टी के शुरू से अगले ~600 अक्षरों में SafeArea होना चाहिए।
        // (DecoratedBox/Container बीच में हो सकता है — वो चलेगा।)
        final aage = src.substring(i, (i + 600).clamp(0, src.length));
        if (!aage.contains('SafeArea(')) {
          final line = '\n'.allMatches(src.substring(0, i)).length + 1;
          chuke.add('${f.path}:$line');
        }
      }
    }

    expect(
      chuke,
      isEmpty,
      reason: 'इन जगहों पर नीचे वाली पट्टी सिस्टम नेविगेशन बार के पीछे '
          'चली जाएगी — SafeArea(top: false) लगाओ:\n  ${chuke.join("\n  ")}',
    );
  });
}
