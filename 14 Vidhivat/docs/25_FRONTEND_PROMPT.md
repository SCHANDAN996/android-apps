# 25 — frontend के लिए ChatGPT prompt (नवरात्रि का पर्व-पन्ना)

> **किसके लिए:** ChatGPT से नवरात्रि वाला **UI** बनवाने के लिए।
> **बँटवारा:** ChatGPT सिर्फ़ **दिखने वाला हिस्सा** बनाएगा। डेटा, पंचांग
> और JSON पढ़ना — वो **बाद में यहीं लिखवाना है**।
> **तारीख़:** 12 सितम्बर 2026 · योजना `docs/23_NAVRATRI_YOJANA.md`

---

## ⚠️ सबसे ज़रूरी बात — सीमा-रेखा

ChatGPT को **डेटा की परत नहीं छूनी है।** नीचे prompt में उसे एक तैयार
interface और एक नक़ली (stub) डेटा दिया गया है — वो बस उसी के ऊपर पन्ना
बनाएगा।

```
ChatGPT का हिस्सा          →  parv_screen.dart  (सिर्फ़ UI)
बाद में यहाँ लिखवाना है    →  parv.dart (model), parv_bhandar.dart,
                              parv_aaj.dart (पंचांग से दिन निकालना),
                              assets/parv/navratri.json
```

**ऐसा क्यों:** पंचांग का गणित (तिथि क्षय से नवरात्रि आठ दिन की होना)
इस ऐप की सबसे नाज़ुक चीज़ है और उसे Drik से मिलाकर जाँचना पड़ता है।
वो बाहर से नहीं आ सकता। UI आ सकता है।

---

## नीचे का पूरा हिस्सा ChatGPT में चिपकाइए

---

````
You are contributing one screen to an existing, finished Flutter app.
Follow its conventions exactly. Do not restructure anything.

## THE APP

"विधिवत" (Vidhivat) — a Hindu ritual-guide app for Indian households.
Package `com.vidhivat`. Flutter/Dart.

Hard constraints that must never be broken:
- **No network. No server. No ads. No login.** Everything is bundled.
- **All user-facing strings are in Hindi (Devanagari).**
- **All code comments are in Hindi too** — this repo is written that way.
- Dart null-safety, `const` constructors wherever possible.
- No new third-party packages. None.

## YOUR TASK

Create ONE new screen: `app/lib/screens/parv_screen.dart`

A "पर्व" (festival-series) screen for a multi-day festival — the first
one being नवरात्रि (Navratri, nine days). The user reaches it by tapping
a single "नवरात्रि" card in the puja list.

The screen offers **two routes** through the festival:
1. **संक्षिप्त पूजा** — one sitting, ~30 minutes, everything condensed
2. **पूर्ण नवरात्रि** — nine days, one puja per day

DO NOT create: the data model, JSON parsing, any Panchang/date logic,
any asset files, or changes to existing files. Those are handled
separately. Code against the interface given below and the stub.

## DESIGN SYSTEM — USE ONLY THESE

Never hard-code a colour, a font size, or a spacing number.

```dart
import '../theme.dart';
import '../widgets/design_system.dart';

final colors = VidhivatTheme.colorsOf(context);
final type   = VidhivatTheme.typographyOf(context);
```

Colour tokens on `colors`:
`background, backgroundElevated, surface, surfaceElevated, surfaceSubtle,
primary, primaryPressed, primaryMuted, secondary, textPrimary,
textSecondary, textTertiary, textOnPrimary, divider, borderSubtle,
success, warning, error, info`

Typography on `type`:
`displayLarge, displayMedium, pageTitle, sectionTitle, cardTitle,
bodyLarge, bodyMedium, bodySmall, label, caption, mantra,
mantraTransliteration, mantraMeaning, numericHighlight`

Spacing — `VidhivatSpacing.xxs(4) xs(8) sm(12) md(16) lg(20) xl(24)
xxl(32) xxxl(40) huge(48) massive(64)`

Radius — `VidhivatRadius.small medium large extraLarge pill`

Available widgets (use these, do not invent lookalikes):

```dart
VidhivatButton({required String label, VoidCallback? onPressed,
  IconData? icon, VidhivatButtonVariant variant, bool compact,
  bool fullWidth, bool isLoading, String? semanticLabel})

VidhivatSurfaceCard({required Widget child, VidhivatCardVariant variant,
  EdgeInsetsGeometry padding, VoidCallback? onTap, bool selected,
  String? semanticLabel})

VidhivatSectionHeader({required String title, String? supportingText,
  Widget? action})

VidhivatStatusChip({required String label, VidhivatStatusTone tone,
  IconData? icon, bool selected})
  // tone: neutral | primary | success | warning | error | info

VidhivatSacredHero({required String eyebrow, required String title,
  required String subtitle, required IconData icon, Widget? footer,
  bool compact, String? semanticLabel, String? artworkAsset,
  String? artworkSemanticLabel, double artworkScale})

VidhivatStateView({required String title, String? message, IconData? icon,
  bool loading, VidhivatStateTone tone})

VidhivatDivider({double indent, double endIndent, double thickness})

VidhivatIconAction({required IconData icon, required String tooltip,
  VoidCallback? onPressed, bool compact})

VidhivatSrotButton({required String label, String? shirshak,
  required List<VidhivatSrotPankti> panktiyan, String? antimBaat})

VidhivatDiyaIcon({double size, bool bhara, Color? color})
```

## THE INTERFACE YOU CODE AGAINST

Assume this file already exists at `app/lib/vidhi/parv.dart`. Do not
write it — just import and use it. (Ship a stub only inside your test.)

```dart
/// एक पर्व — कई दिन चलने वाला त्योहार, जिसमें हर दिन की अपनी विधि है।
class Parv {
  final String id;                 // 'navratri'
  final String naam;               // 'शारदीय नवरात्रि'
  final String ekLine;             // 'नौ दिन, नौ रूप'
  final String parichay;           // दो-तीन वाक्य
  final String artworkAsset;       // 'assets/images/devotional/…webp'
  final String artworkLabel;
  final ParvRasta sankshipt;
  final List<ParvDin> din;         // दिन 1..10, क्रम में
  const Parv({...});
}

/// संक्षिप्त रास्ता — एक ही बैठक।
class ParvRasta {
  final String shirshak;           // 'संक्षिप्त नवरात्रि पूजा'
  final String vivaran;            // 'एक ही बैठक में पूरी पूजा'
  final String? vidhiId;           // null = विधि अभी बनी नहीं
  final int samayMinute;           // 30
  const ParvRasta({...});
}

/// पर्व का एक दिन।
class ParvDin {
  final int ank;                   // 1..10
  final String tithiNaam;          // 'प्रतिपदा'
  final String shirshak;           // 'शैलपुत्री'
  final String ekLine;             // 'घटस्थापना और जौ बोना'
  final String bhog;               // 'गाय का घी'
  final String? vidhiId;           // null = विधि अभी बनी नहीं
  final String artworkAsset;
  final String artworkLabel;
  final int samayMinute;
  const ParvDin({...});
}

/// "आज इस पर्व में कहाँ हैं" — यह पंचांग से बनता है।
class ParvAaj {
  /// आज कौन सा दिन चल रहा है (1..10)। पर्व न चल रहा हो तो null.
  final int? aajKaDin;
  /// पर्व शुरू होने में कितने दिन। पहले ही शुरू हो चुका हो तो null.
  final int? kitneDinBaad;
  final DateTime? shuruTarikh;
  final DateTime? antTarikh;
  /// इस साल पर्व कितने दिन का है — 8, 9 या 10 (तिथि क्षय/वृद्धि से)।
  final int kulDin;
  /// कोई ख़ास बात — जैसे 'इस साल तृतीया का क्षय है, इसलिए दिन 2 और 3
  /// एक ही दिन पड़ते हैं'। कुछ न हो तो null.
  final String? tippani;
  /// जो दिन इस साल किसी और दिन में मिल गए (क्षय)। खाली हो सकता है।
  final Set<int> mileHueDin;
  const ParvAaj({...});
}
```

Your screen's constructor:

```dart
class ParvScreen extends StatefulWidget {
  final Parv parv;
  final ParvAaj aaj;
  /// किसी दिन/रास्ते की विधि खोलने के लिए — बाहर से आता है।
  final void Function(String vidhiId) onVidhiKholo;
  const ParvScreen({
    super.key,
    required this.parv,
    required this.aaj,
    required this.onVidhiKholo,
  });
  ...
}
```

## THE SCREEN — top to bottom

`Scaffold` with `backgroundColor: colors.background`, a simple AppBar
showing `parv.naam` with a back button, body a single scrollable column.

**1. Hero**
`VidhivatSacredHero` with `eyebrow: 'पर्व'`, `title: parv.naam`,
`subtitle: parv.ekLine`, `artworkAsset: parv.artworkAsset`, a suitable
`icon`, and a `footer` holding the date range as chips.

**2. "आज कहाँ हैं" card — the most important element**

- If `aaj.aajKaDin != null`: a prominent `VidhivatSurfaceCard` reading
  `'आज — दिन ${din.ank}'`, the देवी name big, the one-line below, and a
  full-width `VidhivatButton('आज की पूजा खोलें')`. If that day's
  `vidhiId` is null, show a disabled button and a
  `VidhivatStatusChip('विधि अभी नहीं', tone: neutral)` instead.
- Else if `aaj.kitneDinBaad != null`: a quieter card —
  `'नवरात्रि शुरू होने में ${n} दिन'` plus the start date.
- Else: a neutral card saying the festival has passed for this year.

**3. दो रास्ते — the two-route chooser**

A `VidhivatSectionHeader('कैसे करना है')` then TWO selectable cards:

- **संक्षिप्त पूजा** — `'${samayMinute} मिनट · एक ही बैठक'`
- **पूर्ण नवरात्रि** — `'${aaj.kulDin} दिन · रोज़ थोड़ा-थोड़ा'`

Use `VidhivatSurfaceCard(selected: ...)` for the chosen one. Selecting
**पूर्ण** reveals the day list (section 4); selecting **संक्षिप्त**
collapses it and shows the single "पूजा खोलें" button instead.
Default selection: **पूर्ण** if the festival is currently running,
otherwise **संक्षिप्त**.
Keep the choice in the widget's own `State` only — do NOT persist it.

On a viewport narrower than 360 dp, stack the two cards vertically
instead of side by side.

**4. दिन-प्रतिदिन की पट्टी** (only when पूर्ण is selected)

A vertical list — NOT a `ListView` inside the scroll; build it as a
`Column` of rows so the whole page scrolls as one.

Each row:
- a leading round chip with the day number (`VidhivatStatusChip` pill or
  a small `Container` with `VidhivatRadius.pill`)
- `shirshak` (देवी) as `type.cardTitle`
- `'${tithiNaam} · भोग: ${bhog}'` as `type.bodySmall` in `textSecondary`
- `ekLine` as `type.bodyMedium`
- trailing: `'${samayMinute} मिनट'`

Row states:
- **बीता हुआ** (`ank < aaj.aajKaDin`) — muted, a `check` icon in
  `colors.success`
- **आज** (`ank == aaj.aajKaDin`) — highlighted with
  `VidhivatCardVariant` emphasis and a `VidhivatStatusChip('आज',
  tone: primary)`
- **आगे** — normal
- **विधि अभी नहीं** (`vidhiId == null`) — not tappable, with
  `VidhivatStatusChip('विधि अभी नहीं', tone: neutral)`. The row must
  still be readable — knowing the date is itself useful.
- **मिला हुआ दिन** (`aaj.mileHueDin.contains(ank)`) — show a
  `VidhivatStatusChip('इस साल एक साथ', tone: info)`

Tapping a row with a non-null `vidhiId` calls `onVidhiKholo(vidhiId)`.

**5. तिथि वाली टिप्पणी**

If `aaj.tippani != null`, a `VidhivatSurfaceCard` with an `info` icon
and that text. This is where "नवरात्रि इस साल आठ दिन की है" gets
explained. Do not invent the text — just display it.

**6. स्रोत**

A `VidhivatSrotButton(label: 'यह पर्व कहाँ से आया', …)` at the bottom.
Pass an empty `panktiyan` list; the real content comes later.

## NON-NEGOTIABLE RULES

1. **No overflow at 320 dp width with `textScaler` 1.5.** This repo
   tests that on every screen. Wrap text, use `Flexible`/`Expanded`,
   never a fixed height that holds text.
2. **Works in BOTH themes** — `VidhivatTheme.dark()` and
   `VidhivatTheme.light()`. Since you only use tokens, this is free —
   so do not reach for `Colors.white` etc. even once.
3. **Images: pass only ONE of `cacheWidth` / `cacheHeight`, never both.**
   Giving both makes Flutter stretch the bitmap and `BoxFit.contain`
   cannot undo it — faces came out 1.66× wide on a real phone. There is
   a test guarding this.
4. **Every tappable thing needs a Hindi `semanticLabel` or tooltip.**
5. **No `print`, no `TODO`, no English text anywhere the user can see.**
6. `flutter analyze` must be clean — the repo runs with `flutter_lints`.

## ALSO WRITE THE TEST

`app/test/parv_screen_test.dart`, using `flutter_test` only. Build a
small stub `Parv`/`ParvAaj` inside the test file. Cover:

- the "आज" card shows the right day when the festival is running
- the countdown card shows when it has not started
- switching to संक्षिप्त hides the day list, back to पूर्ण shows it
- a row whose `vidhiId` is null is not tappable and shows the chip
- tapping a real row calls `onVidhiKholo` with that id
- no overflow at 320 dp × 1.5 text scale, and again at 412 dp × 1.0
  (use `tester.view.physicalSize` + `devicePixelRatio = 3`, and assert
  `tester.takeException()` is null)

Test names and comments in Hindi, like the rest of the repo.

## DELIVER

Two complete files, ready to drop in:
- `app/lib/screens/parv_screen.dart`
- `app/test/parv_screen_test.dart`

Plus a one-paragraph note (in Hindi) listing anything you assumed.
Do not output anything else.
````

---

## जब ChatGPT का जवाब आ जाए — यहाँ यह जाँचिए

चिपकाने से पहले ये देख लीजिए, क्योंकि यही चीज़ें अक्सर छूटती हैं:

- [ ] कहीं `Colors.` या सीधा `Color(0x…)` तो नहीं लिखा?
- [ ] कोई अंग्रेज़ी शब्द स्क्रीन पर तो नहीं जा रहा?
- [ ] `Image` पर `cacheWidth` और `cacheHeight` **दोनों** तो नहीं?
- [ ] कोई नया package तो नहीं माँगा?
- [ ] `ListView` को scroll के अंदर तो नहीं डाला?
- [ ] टिप्पणियाँ हिंदी में हैं?

फिर:

```bash
cd app && flutter analyze && flutter test test/parv_screen_test.dart
```

---

## उसके बाद मेरा हिस्सा

UI आ जाने पर यहाँ यह लिखवाइए:

1. `app/lib/vidhi/parv.dart` — model और parse, बाक़ी की तरह सख़्त जाँच के साथ
2. `app/assets/parv/navratri.json` — पर्व का असली डेटा
3. `app/lib/vidhi/parv_bhandar.dart` — पढ़ना और याद रखना
   (⚠️ `_padho()` इस्तेमाल करना, `rootBundle.loadString` नहीं → D-070)
4. **`ParvAaj` का पंचांग गणित** — यही असली काम है:
   घटस्थापना का मुहूर्त, संधि पूजा का समय, और तिथि क्षय से आठ/नौ दिन
   (→ `docs/23` §६)
5. पूजाओं की सूची में एक "नवरात्रि" कार्ड और उसका रास्ता
6. काग़ज़ — `01_DECISIONS`, `03_PROGRESS`, `04_NEXT`
