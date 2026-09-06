# 09 — कोड का नक़्शा

> कौन सी फ़ाइल क्या करती है, और कुछ जोड़ना हो तो कहाँ हाथ डालना है।
> गणित के सूत्र यहाँ नहीं — वो `07_GANIT.md` में हैं।

---

## ढाँचा — नीचे से ऊपर

```
  festival.dart  shubh_muhurat.dart 🚧  sankalp.dart  vrat.dart
              │                                          │
              │        grahan.dart   surya_grahan.dart   │ ← ग्रहण
              │              └──── prahar.dart ──────────┘   (→ D-054/055)
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
| `test/prahar_test.dart` | प्रहर — सूतक की जड़ (→ D-054) |
| `test/grahan_test.dart` | चंद्रग्रहण — NASA से समय, Drik से सूतक |
| `test/surya_grahan_test.dart` | सूर्यग्रहण — NASA से 14 ग्रहण, Drik से 4 शहर |
| `test/vrat_test.dart` | व्रत की तारीख़ें |
| `test/shubh_muhurat_test.dart` | शुभ मुहूर्त — 🚧 आज की हालत नाप कर दर्ज |
| `test/sankalp_test.dart` | संकल्प — सारे मान सही जगह भरते हैं |
| `test/reference_test.dart` | `reference_dates.json` से मिलान (2 मिनट की छूट) |
| `test/data/reference_dates.json` | 12 तारीख़ें × 5 शहर, Drik से |
| `test/festival_notes.md` | **व्यापिनी नियम** — चरण B का आधार |

```bash
cd engine && dart test        # 254 जाँचें
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
app/
├── assets/vidhi/          पूजा का कंटेंट — JSON, ऐप में बंडल
│   ├── _suchi.json        बारह पूजाओं की हल्की सूची
│   ├── satyanarayan.json  … और ग्यारह और, एक-एक पूजा
│   └── audio/             मंत्रों की रिकॉर्डिंग (अभी ख़ाली)
│
├── test/
│   ├── vidhi_test.dart          कंटेंट का ढाँचा — बारहों पूजाएँ
│   ├── vidhi_screens_test.dart  स्क्रीनों पर उँगली चलाकर
│   ├── phase6_screens_test.dart utility screens का responsive, semantic,
│   │                            persistence और navigation regression suite
│   └── phase7_polish_test.dart  loading/error, reduced motion, lifecycle
│                                refresh और 2.0× narrow-layout regression
│
└── lib/
    ├── main.dart          छह पन्नों की पट्टी (NavigationBar)
    ├── theme.dart         semantic colour/type/spacing/radius/motion tokens
    ├── state/settings.dart    जगह, पद्धति, यजमान, सामग्री की टिक + 35 शहर;
    │                          `playerProgress.v1` में per-Puja technical resume
    ├── widgets/common.dart    Pankti · Chetavni · Panna + समय के औज़ार
    ├── widgets/design_system.dart
    │                         Phase 1 के reusable CTA · icon action · surface
    │                         card · status chip · state view · divider primitives
    ├── widgets/dakshina_card.dart
    │                         स्क्रीन पर छपने वाले शब्द (`DakshinaShabd`),
    │                         राशि चुनने वाला हिस्सा, और पूजा पूरी होने
    │                         वाले पन्ने का शांत डिब्बा (→ D-053)
    ├── services/dakshina_service.dart
    │                         दक्षिणा की बही — घड़ी का नियम + Play Billing
    │                         का द्वार। ⛔ यहाँ कोई `unlock`/`isPro` झंडा
    │                         कभी नहीं आएगा — देने वाले को कुछ अतिरिक्त
    │                         नहीं मिलता, यही Play की शर्त है
    ├── vidhi/
    │   ├── vidhi.dart     पूजा का ढाँचा + JSON पढ़ना + जाँच
    │   └── bhandar.dart   assets से पढ़ने वाला (याद भी रखता है)
    └── screens/
        ├── vidhi_list_screen.dart    विधि home — featured/daily/festival/special discovery;
        │                             festival rail text-scale के साथ बढ़ती है
        ├── vidhi_screen.dart         पूजा की तैयारी — metadata, preview,
        │                             trust/source + preparation/direct/resume CTA
        ├── samagri_screen.dart       सामग्री तैयारी — local ticks, progress,
        │                             groups, WhatsApp + player CTA
        ├── vidhi_player_screen.dart  guided steps, furthest app-position save,
        │                             final-write/clear ordering + handoff
        │                             (wakelock only while active)
        ├── puja_completion_screen.dart calm technical guide-finished handoff
        │                             + दक्षिणा का डिब्बा — **ऐप में
        │                             इकलौती जगह जहाँ पैसा माँगा जाता है**
        ├── dakshina_screen.dart      दक्षिणा का पूरा पन्ना — राशियाँ,
        │                             "यह राशि कहाँ लगती है", और तीन
        │                             साफ़-साफ़ बातें (→ D-053)
        ├── aaj_screen.dart           daily Panchang + available festival dashboard
        ├── calendar_screen.dart      reduced-motion-aware 7-column month grid,
        │                             bounded selected-day/festival cache
        ├── sankalp_screen.dart       guided purpose + exact Sankalp output
        ├── muhurta_screen.dart       ordered Choghadiya/Hora + boundary-scheduled,
        │                             lifecycle-safe current refresh
        ├── vrat_screen.dart          आगे पड़ने वाले व्रत, नियम ⓘ के पीछे
        ├── grahan_screen.dart        चंद्रग्रहण + सूतक (तीन प्रहर)
        ├── surya_grahan_screen.dart  सूर्यग्रहण + सूतक (चार प्रहर)
        │                             ⚠️ आँख की चेतावनी सबसे ऊपर, ⓘ में नहीं
        └── settings_screen.dart      शहर, मास-पद्धति और local यजमान settings
```

### कंटेंट की परत — `lib/vidhi/`

गणना नहीं, सिर्फ़ कंटेंट पढ़ना और जाँचना। **इंजन में क्यों नहीं → D-021**
(Flutter assets सिर्फ़ Flutter पैकेज से बंडल होते हैं)।

| नाम | क्या |
|---|---|
| `Vidhi` | एक पूरी पूजा — `charan`, `samagri`, `sawaal`, `strot`, `jaanch` |
| `Charan` | एक कदम — शीर्षक, विवरण, मंत्र, `vishesh` |
| `CharanVishesh` | `saada` · **`sankalp`** · `katha` · `aarti` |
| `Mantra` | देवनागरी, रोमन, अर्थ, ऑडियो, स्रोत, `bharosa`, `vikalp`, `sthiti` |
| `MantraSthiti` | `khaali` · `draft` · `paas` |
| `Bharosa` | `uncha` · `madhyam` · `kam` — पंडित जी की जाँच से पहले कितना भरोसा (→ D-025) |
| `Samagri` | वस्तु, मात्रा, इकाई, ज़रूरी/वैकल्पिक, समूह |
| `VidhiSuchiEntry` | सूची की एक पंक्ति + `taiyar` झंडी |
| `VidhiFormatException` | ग़लत JSON — **संदेश में फ़ाइल का नाम आता है** |
| `vidhiBhandar` | पूरे ऐप के लिए एक ही भंडार |

⚠️ **ढाँचा ख़ुद रखवाली करता है।** बिना पाठ/स्रोत के मंत्र `paas` नहीं हो
सकता, कच्चे मंत्र वाली पूजा `paas` नहीं हो सकती, `taiyar` झूठ नहीं बोल
सकती। पूरी सूची → D-021।

### विधि प्लेयर — `screens/vidhi_player_screen.dart`

⛔ **इस स्क्रीन पर विज्ञापन कभी नहीं** (→ D-008)। कोई ad widget मत जोड़ना।

- एक कदम, एक पन्ना (`PageView`)
- semantic चरण क्रम और progress header; चरणों की सूची से existing steps पर
  in-session navigation, जिसमें केवल देखा गया / खुला / आगे का UI state है
- पहले चरण पर single आगे action, बाद के चरणों पर पीछे/आगे और अंतिम चरण पर
  technical progress clear करके calm Completion handoff
- per-Puja saved जगह केवल furthest app position है; यह धार्मिक completion नहीं
- विवरण 20px, मंत्र 26px — दो फ़ुट दूर से पढ़ने लायक
- `WakelockPlus` — पूजा के बीच स्क्रीन बंद नहीं होती
- चौथा कदम संकल्प का है — वहीं पंचांग से पूरा वाक्य बनता है (→ D-006)
- मंत्र ख़ाली हो तो **चेतावनी दिखती है, बना हुआ मंत्र नहीं** (→ D-022)

### साझा widgets — `widgets/common.dart`
| नाम | क्या |
|---|---|
| `Pankti` | बाएँ नाम, दाएँ मान, नीचे नोट |
| `Chetavni` | semantic warning surface (`serious: true` से error tone) |
| `Panna` | पूरे ऐप में एक जैसा ListView |
| `hm` `hms` `tarikh` `tarikhChhoti` | समय-तारीख़ के रूप |
| `dinKaNishan` | **"(कल)" / "(बीती रात)"** — बहुत ज़रूरी, नीचे देखो |

### Phase 1 design system
`theme.dart` अब semantic design tokens का source है। नये screen work में
hex colour, local text-size या local radius लिखने के बजाय ये इस्तेमाल करें:

| चीज़ | API |
|---|---|
| रंग | `VidhivatTheme.colorsOf(context)` → `background`, `surface`, `primary`, `textPrimary`, `success` आदि |
| typography | `VidhivatTheme.typographyOf(context)` → `pageTitle`, `sectionTitle`, `mantra`, `numericHighlight` आदि |
| spacing | `VidhivatSpacing` |
| radius | `VidhivatRadius` |
| elevation / icon size | `VidhivatElevation`, `VidhivatIconSize` |
| action / focus sizing | `VidhivatActionSize`, `VidhivatStroke` |
| primitives | `widgets/design_system.dart` |

Phase 7 में `VidhivatStateView` calm loading/error/empty presentation देता है;
callers raw exception UI में नहीं डालते। `VidhivatMotion` standard durations का
source है और animation callers system reduced-motion preference मानते हैं।

Visual transformation pass में इसी file के `VidhivatSacredBackdrop` और
`VidhivatSacredHero` shared visual primitives हैं। पहला screen-level depth देता
है; दूसरा Home/Detail/Player/Completion की native, asset-ready hero hierarchy
देता है। इन्हें केवल presentation के लिए use करें—देity artwork, source status,
mantra/ritual text अथवा flow semantics इनमें hard-code न करें।

`lib/vidhi/devotional_assets.dart` stable `Vidhi.id` से local devotional asset
path और concise semantic label resolve करता है। Screens raw asset paths scatter
नहीं करते। Unknown ids को neutral diya मिलता है; text-heavy posters को compact
cards या religious-copy substitute की तरह map नहीं करना है.

Catalogue artwork केवल `app/assets/images/devotional/*.webp` में रखना है (→
D-040)। ये transparent (alpha-preserving), no-text, decorative files हैं; opaque JPEG,
poster/screenshot अथवा image में लिखे धार्मिक दावे UI में नहीं लगाने हैं।
`VidhiListScreen` का `_PujaGridCard` सभी Home categories का shared 2-column
card है—art bounded top area और Hindi copy bottom area में रहती है, और system
text scale पर card height बढ़ती है।

⚠️ Phase 1 ने existing screens की widget trees नहीं बदलीं। अगली screen phase
में components को धीरे-धीरे अपनाना है; धार्मिक चेतावनियाँ और data states
कभी न हटें।

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
5. **जाँच लिखो** — `app/test/` में, फ़ोन के नाप (360×800 dp) पर (→ D-024)

### नई पूजा जोड़नी हो तो
1. `assets/vidhi/satyanarayan.json` की नक़ल करो
2. `_suchi.json` में entry डालो और `taiyar` सच करो
3. `flutter test` — ढाँचा ख़ुद बता देगा क्या छूट रहा है
4. `docs/06_CONTENT_TRACKER.md` अपडेट करो
5. ⚠️ **मंत्र याददाश्त से मत लिखना** — `sthiti: "khaali"` छोड़ दो (→ D-022)

```bash
cd app && flutter analyze && flutter test && flutter run -d <device-id>
```

⚠️ `adb` PATH में नहीं है: `H:\Android\Sdk\platform-tools\adb.exe`


---

## चालीसा और आरती — `lib/vidhi/paath.dart` + `assets/paath/`

पूजा से अलग ढाँचा (→ D-039)। पूजा एक *काम* है, पाठ *पढ़ने* की चीज़।

```
app/assets/paath/
├── _suchi.json            सात पाठों की हल्की सूची
├── hanuman_chalisa.json   43 पद (2 दोहे + 40 चौपाई + समापन दोहा)
├── ganesh_aarti.json      … और पाँच आरतियाँ
└── audio/                 रिकॉर्डिंग (अभी ख़ाली)

app/lib/vidhi/paath.dart   ढाँचा + जाँच
app/lib/vidhi/bhandar.dart PaathBhandar भी यहीं
app/lib/screens/
├── paath_list_screen.dart सूची + छन्नी (सब · चालीसा · आरती)
└── paath_screen.dart      पढ़ने वाला पन्ना
```

| नाम | क्या |
|---|---|
| `Paath` | एक पूरा पाठ — `khand`, `rachnakar`, `bhasha`, `strot`, `jaanch` |
| `PaathKhand` | एक पद — शीर्षक, देवनागरी, रोमन, अर्थ, ऑडियो, `sthiti` |
| `PaathPrakar` | `chalisa` · `aarti` · `stotra` |
| `PaathSuchiEntry` | सूची की एक पंक्ति + `taiyar` झंडी |
| `paathBhandar` | पूरे ऐप के लिए एक ही भंडार |

`MantraSthiti`, `Bharosa`, `Strot` और `Jaanch` `vidhi.dart` से ही आते
हैं — एक ही भाषा, दो ढाँचे।

⚠️ **"चालीसा" में चालीस चौपाइयाँ होनी ही चाहिए** — ढाँचा जाँचता है।

### नया पाठ जोड़ना हो तो
1. `assets/paath/<id>.json` बनाओ — `rachnakar` और `bhasha` ज़रूर भरो
2. `_suchi.json` में entry डालो, `taiyar` सच करो
3. `flutter test test/paath_test.dart` — ढाँचा बता देगा क्या छूटा
4. `python tools/banao_pandit_sheet.py` — शीट के भाग ५ में अपने आप आएगा
5. ⚠️ **पाठ याददाश्त से मत लिखना** — अपनी पुस्तिका से, `sthiti: "khaali"` छोड़ दो
