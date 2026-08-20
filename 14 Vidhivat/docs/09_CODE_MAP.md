# 09 — कोड का नक़्शा

> कौन सी फ़ाइल क्या करती है, और कुछ जोड़ना हो तो कहाँ हाथ डालना है।
> गणित के सूत्र यहाँ नहीं — वो `07_GANIT.md` में हैं।

---

## ढाँचा — नीचे से ऊपर

```
  festival.dart   shubh_muhurat.dart 🚧   sankalp.dart   ← panchang के ऊपर
              │
        panchang.dart          muhurta.dart    ← दोनों नीचे वालों पर टिके
     ┌────┬────┴───┬────────┐        │
sunrise moonrise ayanamsa  moon      │
     │      │        │       │       │
     └──────┴─ sun.dart ─────┘       │
              │      │               │
       nutation.dart │        names.dart, place.dart
              │      │        (सिर्फ़ डेटा, कोई निर्भरता नहीं)
         julian.dart ┘
              │
         angles.dart                           ← सबसे नीचे
```

**नियम:** ऊपर वाली फ़ाइल नीचे वाली को import करती है, उल्टा कभी नहीं। इसी से कोई चक्कर (circular import) नहीं बनता।

---

## हर फ़ाइल

### `lib/panchang_engine.dart`
सार्वजनिक API — बाहर से सिर्फ़ यही import होता है। `src/` की फ़ाइलें सीधे import मत करना।

### `lib/src/angles.dart`
कोण के औज़ार। पूरे इंजन में **डिग्री** चलती है, रेडियन सिर्फ़ sin/cos के अंदर।

| फलन | क्या करता है |
|---|---|
| `sinD, cosD, tanD, asinD, acosD, atan2D` | डिग्री वाले त्रिकोणमिति |
| `norm360(x)` | 0 से 360 के बीच लाओ |
| `norm180(x)` | −180 से +180 — **दो कोणों का अंतर निकालते वक़्त यही चाहिए** |
| `toDms(x)` | 23.85° → `23° 51' 0.0"` |

### `lib/src/julian.dart`
समय। **दो घड़ियाँ — JD (UT) और JDE (TT) — कभी मत मिलाना।**

| फलन | क्या करता है |
|---|---|
| `julianDay(y, m, d)` | तारीख़ → JD |
| `julianDayFromUtc(DateTime)` | UTC → JD |
| `utcFromJulianDay(jd)` | JD → UTC |
| `julianCenturies(jd)` | J2000 से कितनी सदियाँ |
| `deltaTSeconds(y, m)` | ΔT |
| `toEphemerisTime(jdUt)` | **JD → JDE** — ग्रहों की गणना से पहले हमेशा यही |

### `lib/src/nutation.dart`
`nutationInLongitude(jde)` — Δψ, डिग्री में।
⚠️ सूर्य और चंद्र **दोनों** पर लगे या दोनों पर न लगे। एक पर लगाकर दूसरे पर भूलना ही असली बग है।

### `lib/src/sun.dart`
| फलन | क्या करता है |
|---|---|
| `sunApparentLongitude(jde)` | सूर्य का सायन आभासी देशांतर (नतांश शामिल) |
| `sunEquatorial(jde)` | RA और क्रांति — सूर्योदय के लिए |
| `meanObliquity(jde)` | क्रांतिवृत्त की तिरछाहट |

### `lib/src/moon.dart`
| फलन | क्या करता है |
|---|---|
| `moonLongitude(jde)` | चंद्र का सायन **आभासी** देशांतर (नतांश शामिल) |
| `moonLatitude(jde)` | चंद्र का अक्षांश β (तालिका 47.B) — नतांश **नहीं** लगता |
| `moonDistance(jde)` | दूरी, किमी (Σr) |
| `moonParallax(jde)` | क्षैतिज लंबन π, ~0.95° |
| `moonGeometricLongitude(jde)` | नतांश के बिना — सिर्फ़ जाँच के लिए |
| `_longitudeTerms` | **तालिका 47.A के 60 पद** — इसे छूने से पहले Meeus उदाहरण 47.a वाली जाँच पढ़ो |

### `lib/src/ayanamsa.dart`
| नाम | क्या |
|---|---|
| `lahiriAyanamsa(jde)` | लाहिड़ी अयनांश |
| `toSidereal(long, jde)` | सायन → निरयन |
| `ayanamsaCalibration` | **सुधार की इकलौती घुंडी** — फ़र्क़ मिले तो सिर्फ़ यही घुमाना |

### `lib/src/sunrise.dart`
| फलन | क्या करता है |
|---|---|
| `sunAltitude(jdUt, place)` | उस क्षण सूर्य की ऊँचाई |
| `sunriseSunset(y,m,d,place)` | दोनों समय, UTC में |
| `sunriseJd(y,m,d,place)` | सूर्योदय का JD — **पूरे पंचांग की धुरी** |
| `greenwichMeanSiderealTime(jd)` | GMST |

### `lib/src/moonrise.dart`
| फलन | क्या करता है |
|---|---|
| `moonEquatorial(jde)` | चंद्र का RA और क्रांति |
| `moonAltitude(jdUt, place)` | उस क्षण चंद्रमा की ऊँचाई |
| `moonriseMoonset(y,m,d,place)` | चंद्रोदय और चंद्रास्त — **`null` सामान्य है** |
| `moonHorizonAdjustment` | दहलीज़ की घुंडी (→ D-016) |

### `lib/src/festival.dart`
त्योहार की तारीख़ें — व्यापिनी नियम से। `panchang.dart` के **ऊपर** बैठती है, उसे छूती नहीं।

| नाम | क्या |
|---|---|
| `enum Vyapini` | सूर्योदय · मध्याह्न · अपराह्न · प्रदोष · निशीथ |
| `FestivalRule` | एक त्योहार का नियम (मास, पक्ष, तिथि, व्यापिनी, भद्रा) |
| `FestivalDate` | निकाली हुई तारीख़ **+ `explanation`** (हिसाब खोलकर) |
| `kaalWindow(...)` | किसी दिन की काल-खिड़की |
| `findFestival(rule, year, place)` | **मुख्य प्रवेश-द्वार** |
| `festivalsInYear(year, place)` | पूरे साल के त्योहार |
| `festivalRules` | 8 त्योहार, सब Drik से जाँचे हुए |

**झंडियाँ:** `shiftedForBhadra` · `missedKaal` · `ambiguous` (+ `otherCandidate`)

### `lib/src/muhurta.dart`
चौघड़िया और होरा। दोनों वार के स्वामी ग्रह से निकलते हैं।

| नाम | क्या |
|---|---|
| `MuhurtaSlot` | एक टुकड़ा — नाम, समय, दिन/रात, शुभ/अशुभ |
| `choghadiya(y,m,d,place)` | 16 टुकड़े — 8 दिन के, 8 रात के |
| `hora(y,m,d,place)` | 24 होरा — 12 दिन के, 12 रात के |
| `currentChoghadiya(moment, place)` | अभी कौन सी चल रही है |
| `currentHora(moment, place)` | अभी कौन सा होरा |
| `upcomingAuspicious(moment, place)` | आगे की शुभ चौघड़िया |
| `weekdayLord` · `horaLords` · `choghadiyaNames` | तालिकाएँ (Drik से जाँची) |

⚠️ **रात की चौघड़िया दो क़दम पीछे चलती है**, दिन की एक क़दम आगे।

### `lib/src/sankalp.dart`
संकल्प वाक्य — **ऐप का सबसे बड़ा फ़र्क़।**

| नाम | क्या |
|---|---|
| `SankalpDetails` | नाम, गोत्र, जगह, किस काम का |
| `Sankalp` | `full` (संस्कृत) · `simple` (हिंदी) · `parts` (14 हिस्से) |
| `buildSankalp(panchang, details)` | **मुख्य प्रवेश-द्वार** |
| `commonPurposes` · `commonGotras` | तैयार सूचियाँ |

⚠️ `needsPanditReview` **हमेशा सच** — संस्कृत के रूप जाँचे नहीं गए (→ D-020)

### `lib/src/shubh_muhurat.dart`
🚧 **अधूरा — ऐप में मत दिखाना।** `shubhMuhuratIsReady = false`

गृह प्रवेश, मुंडन, नामकरण, वाहन, भूमि पूजन, विद्यारंभ के शुभ दिन।

| नाम | क्या |
|---|---|
| `Activity` · `ActivityRule` | कौन सा काम, उसके नियम |
| `ShubhDin` | एक शुभ दिन + `muhurtaStart/End` की खिड़की |
| `shubhDinList(activity, year, place)` | साल भर के दिन |
| `shubhMuhuratIsReady` | **false** — देखकर ही दिखाना |

**क्यों अधूरा:** गुरु/शुक्र तारा अस्त नहीं निकल सकता (बृहस्पति-शुक्र का
देशांतर इंजन में है ही नहीं), और नियम Drik की सूची से उलटकर निकाले गए हैं,
शास्त्र से नहीं लिए गए। Drik से मिलान **26/37**। (→ D-019)

### `lib/src/names.dart`
सारे देवनागरी नाम और **सत्यापित तालिकाएँ**। कोई गणना नहीं, सिर्फ़ डेटा।

तिथि (30) · नक्षत्र (27) · योग (27) · करण (11) · मास (12) · वार (7) · राशि (12) · ऋतु (6) · **संवत्सर (60)** · पक्ष · अयन
`karanaNameIndex()` · `shakaSamvatsaraOf()` · `vikramSamvatsaraOf()`
`rahuKaalPart` · `yamagandaPart` · `gulikaPart` · `gandmoolNakshatras`
`enum MasaSystem { amanta, purnimanta }`

### `lib/src/place.dart`
`Place` — नाम, अक्षांश, देशांतर, समय-क्षेत्र। जाँच के लिए 7 शहर तैयार।
⚠️ देशांतर **पूर्व धनात्मक** (भारत के लिए +)।

### `lib/src/panchang.dart`
सब कुछ यहाँ जुड़ता है।

| नाम | क्या |
|---|---|
| `Anga` | एक अंग — नाम, शुरुआत, समाप्ति |
| `Kaal` | एक कालखंड — राहुकाल, भद्रा वग़ैरह |
| `Panchang` | पूरे दिन का नतीजा |
| `computePanchang(y,m,d,place, {masaSystem})` | **मुख्य प्रवेश-द्वार** |
| `elongationAt` `moonSiderealAt` `sunSiderealAt` `yogaAngleAt` | चार कोण |
| `findCrossing` `findPreviousCrossing` | जड़-खोज, 1 सेकंड तक |
| `previousNewMoon(jd)` | पिछली अमावस्या — मास इसी से तय होता है |
| `_angaSeries(...)` | सूर्योदय से अगले सूर्योदय तक सारे अंग |

---

## `Panchang` में क्या-क्या मिलता है

```dart
final p = computePanchang(2026, 8, 20, Place.delhi);
```

| समूह | फ़ील्ड |
|---|---|
| सूर्योदय के अंग | `tithi` `nakshatra` `yoga` `karana` |
| पूरे दिन की सूचियाँ | `tithis` `nakshatras` `yogas` `karanas` |
| तिथि की विशेषता | `kshayaTithiName` `isVriddhiTithi` |
| मास | `masa` `masaName` **`masaFullName`** `masaSystem` `isAdhikaMasa` |
| संवत् | `vikramSamvat` `shakaSamvat` `vikramSamvatsara` `shakaSamvatsara` |
| और | `vara` `paksha` `ayana` `ritu` `sunRashi` `moonRashi` `ayanamsa` |
| समय | `sunrise` `sunset` `nextSunrise` `dinamana` `ratrimana` |
| काल | `rahuKaal` `yamaganda` `gulika` `abhijit` `bhadra` |
| झंडियाँ | `isPanchak` `isGandmool` |

⚠️ **दिखाते वक़्त हमेशा `masaFullName`** — वो अधिक मास में "अधिक ज्येष्ठ" लौटाता है।
⚠️ **सारे समय स्थानीय** (`place.timeZoneOffset` जुड़ा हुआ)।

---

## जाँच

| फ़ाइल | क्या |
|---|---|
| `test/astronomy_test.dart` | खगोल-गणित — किसी बाहरी डेटा के बिना |
| `test/moonrise_test.dart` | चंद्र का अक्षांश/दूरी/लंबन + चंद्रोदय |
| `test/festival_test.dart` | त्योहार की तारीख़ें — आठों Drik से |
| `test/muhurta_test.dart` | चौघड़िया और होरा — दो वार Drik से |
| `test/shubh_muhurat_test.dart` | शुभ मुहूर्त — 🚧 आज की हालत नाप कर दर्ज |
| `test/sankalp_test.dart` | संकल्प — सारे मान सही जगह भरते हैं |
| `test/reference_test.dart` | `reference_dates.json` से मिलान (2 मिनट की छूट) |
| `test/data/reference_dates.json` | 12 तारीख़ें × 5 शहर, Drik से |
| `test/festival_notes.md` | **व्यापिनी नियम** — चरण B का आधार |

```bash
cd engine && dart test        # 157 जाँचें
cd engine && dart analyze     # साफ़ रहना चाहिए
```

---

## कुछ जोड़ना हो तो कहाँ हाथ डालें

### नया पंचांग तत्व (जैसे चौघड़िया)
1. नाम/तालिका → `names.dart`
2. गणना → `panchang.dart` के `computePanchang` में
3. फ़ील्ड → `Panchang` class में
4. दिखाना → `tool/panchang_cli.dart`
5. **जाँच → `astronomy_test.dart`, और मान Drik से मिलाकर `08_VERIFICATION.md` में दर्ज करो**
6. सूत्र → `07_GANIT.md`

### नया त्योहार जोड़ना
1. `festivalRules` में नियम डालो — **तारीख़ कभी हाथ से मत भरना**
2. Drik के उस दिन के पन्ने से मिलाओ कि वो वहाँ नाम लिखता है या नहीं
3. जाँच `test/festival_test.dart` की `verified` सूची में डालो
4. `docs/08_VERIFICATION.md` में दर्ज करो

---

## Flutter ऐप में कैसे जुड़ेगा

अभी `engine/` अलग पैकेज है ताकि `dart test` सेकंडों में चले, Flutter का इंतज़ार किए बिना। ऐप बनने पर:

```yaml
dependencies:
  panchang_engine:
    path: ../engine
```

इंजन में **कोई Flutter निर्भरता नहीं आनी चाहिए** — यही उसे तेज़ और आसानी से जाँचने लायक रखता है।

---

## ऐप — `app/`

Flutter, package `com.massapp.vidhivat`। इंजन `path` dependency की तरह जुड़ा
है — **ऐप में एक भी गणना नहीं, सब इंजन से आता है।**

```
app/lib/
├── main.dart              पाँच पन्नों की पट्टी (NavigationBar)
├── theme.dart             हल्दी · सिंदूर · तुलसी — और हर जगह बड़े अक्षर
├── state/settings.dart    जगह, पद्धति, यजमान + 35 शहर
├── widgets/common.dart    Khand · Pankti · Chetavni · Panna + समय के औज़ार
└── screens/
    ├── aaj_screen.dart       आज का पूरा पंचांग (दिन आगे-पीछे कर सकते हैं)
    ├── calendar_screen.dart  महीना + साल के त्योहार (दो tab)
    ├── sankalp_screen.dart   ⭐ संकल्प — नाम/गोत्र पूछकर पूरा वाक्य
    ├── muhurta_screen.dart   चौघड़िया + होरा + "अभी क्या चल रहा है"
    └── settings_screen.dart  शहर, अमांत/पूर्णिमांत, यजमान
```

### साझा widgets — `widgets/common.dart`
| नाम | क्या |
|---|---|
| `Khand` | एक खंड — शीर्षक + Card |
| `Pankti` | बाएँ नाम, दाएँ मान, नीचे नोट |
| `Chetavni` | चेतावनी का डिब्बा (`serious: true` से लाल) |
| `Panna` | पूरे ऐप में एक जैसा ListView |
| `hm` `hms` `tarikh` `tarikhChhoti` | समय-तारीख़ के रूप |
| `dinKaNishan` | **"(कल)" / "(बीती रात)"** — बहुत ज़रूरी, नीचे देखो |

### ⚠️ दो बातें जो ऐप में ध्यान रखनी हैं

**1. हर समय के आगे दिन का निशान लगाओ।**
हिंदू दिन सूर्योदय से अगले सूर्योदय तक चलता है, इसलिए आख़िरी अंग अक्सर
अगली सुबह ख़त्म होता है। "बालव तक 10:25" बिना निशान के ग़लतफ़हमी है।
इसीलिए `dinKaNishan()` हर जगह लगता है।

**2. अक्षर बड़े रखो।**
यूज़र ज़मीन पर बैठा है, हाथ में जल है, फ़ोन दो फ़ुट दूर। संकल्प का पाठ
22px पर है। `theme.dart` में पूरा नाप सामान्य से बड़ा लिया गया है।

### 🐛 एक बग जो सिर्फ़ फ़ोन पर मिला
`TextEditingController` पर listener न होने से "संकल्प बनाइए" बटन नाम भरने
पर भी बंद रहता था। `flutter analyze` साफ़ था, 157 जाँचें पास थीं।

> **हर स्क्रीन फ़ोन पर चलाकर देखनी है।** analyze और test काफ़ी नहीं।

### ऐप में कुछ जोड़ना हो तो
1. गणना **कभी ऐप में मत लिखना** — इंजन में जोड़ो, फिर यहाँ दिखाओ
2. नया widget → `widgets/common.dart` में, ताकि हर जगह एक जैसा दिखे
3. समय दिखाओ तो `dinKaNishan()` ज़रूर लगाओ
4. नई स्क्रीन → `main.dart` की `_pages` सूची में जोड़ो

```bash
cd app && flutter analyze && flutter run -d <device-id>
```

⚠️ `adb` PATH में नहीं है: `H:\Android\Sdk\platform-tools\adb.exe`
