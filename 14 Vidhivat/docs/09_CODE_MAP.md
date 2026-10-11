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
| `sunApparentLongitude(jde)` | सूर्य का सायन आभासी देशांतर (नतांश शामिल) — **VSOP87**, NASA से 0.3″ (→ D-104) |
| `sunApparentLongitudeLaghu(jde)` | छोटा सूत्र (21″ तक) — सिर्फ़ सूर्योदय-सूर्यास्त के लिए, दस गुना तेज़ |
| `sunEquatorialLaghu(jde)` | RA और क्रांति, छोटे सूत्र से — सूर्योदय के लिए |
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
| `enum Vyapini` | सूर्योदय · मध्याह्न · अपराह्न · प्रदोष · निशीथ · चंद्रोदय |
| `enum Nirnaya` | दिन चुनने का तरीक़ा: `vyapini` (सीधी व्यापिनी — पंद्रह नियम) या पाँच में से एक छपा निर्णय: `holika` · `raksha` · `ramNavami` · `janmashtami` · `lakshmiPujan` (→ D-117) |
| `FestivalRule` | एक त्योहार का नियम (मास, पक्ष, तिथि, व्यापिनी, भद्रा, `vaarPehle`, `nirnaya`) |
| `FestivalDate` | निकाली हुई तारीख़ **+ `explanation`** (हिसाब खोलकर) |
| `kaalWindow(...)` | किसी दिन की काल-खिड़की |
| `findFestival(rule, year, place)` | **मुख्य प्रवेश-द्वार** |
| `festivalsInYear(year, place)` | पूरे साल के त्योहार |
| `festivalRules` | 20 नियम — सब सात साल (2024–2030) पर संदर्भ-पंचांग से जाँचे हुए (`08` §14, §20) |

**झंडियाँ:** `shiftedForBhadra` · `missedKaal` · `ambiguous` (+ `otherCandidate`)

**दो रास्ते (→ D-117):** पंद्रह नियम `_pickDay` से — जिस दिन के काल में तिथि हो।
पाँच नियम अपने फलन से (`_holika`, `_raksha`, `_ramNavami`, `_janmashtami`,
`_lakshmiPujan`) — हर एक **धर्मसिंधु** के छपे वाक्य से, जो फलन के ऊपर लिखा है।
वहाँ की संख्याएँ (तीन मुहूर्त, साढ़े तीन प्रहर, एक घड़ी, आधी रात) छपे शब्द हैं —
अंदाज़े से मत बदलना। `ambiguous` का मतलब अब: "दो दिन दावेदार थे; `date` नियम
का चुना हुआ, `otherCandidate` दूसरी परंपरा का" (जन्माष्टमी, दीपावली 2024)।

**औज़ार** (`engine/tool/`, ऐप इन्हें नहीं बुलाता):

| फ़ाइल | क्या |
|---|---|
| `parv_byora.dart <id> <साल> <साल>` | एक त्योहार का पूरा ब्योरा — तिथि, अगली तिथि, भद्रा, हर दिन के काल में कितनी देर, जन्माष्टमी पर रोहिणी |
| `vyapini_aazmao.dart <id> <साल> <साल>` | छहों व्यापिनी साल-दर-साल — कौन-सी कब अलग पड़ती है |
| `vrat_saal.dart [--sab] <साल…>` | तारीख़ें, तिथि के समय और झंडियाँ JSON में (`tools/horizons_vrat.py` यही खाता है) |

`tools/horizons_vrat.py` — उन तारीख़ों की तिथि-सीमाएँ NASA JPL Horizons से;
नतीजा `engine/test/data/horizons_vrat.json`।

### `lib/src/graha_ast.dart` (→ D-119)
गुरु और शुक्र का अस्त — सूर्य के पास आ जाने से न दिखना। `graha.dart` के ऊपर बैठती है।

| नाम | क्या |
|---|---|
| `enum AstGanana` | `ansh` (देशांतर का अंतर कालांश से कम) · `kalansh` (उदय/अस्त के समय का अंतर; जगह से बदलता है, धीमा) |
| `astKalansh(g, vakri:)` | गुरु 11, शुक्र 10, वक्री 8 — सूर्यसिद्धांत ९.६–७। **मत बदलना** |
| `grahaAstKaal(g, se, tak, place, ganana:)` | **मुख्य प्रवेश-द्वार** — खिड़की को छूने वाले अस्त-काल |
| `GrahaAst` | `ast`, `uday`, दिशा, कालांश; `vardhakDin`/`balyaDin` (मुहूर्त चिंतामणि २७), `vardhakShuru`, `balyaAnt` |
| `grahaUdayAst(g, y, m, d, place)` | उस दिन सूर्य के आस-पास ग्रह का उदय और अस्त — संदर्भ के 18 पलों से 2 मिनट के भीतर |
| `grahaSuryaAntar`, `grahaUnchai` | देशांतर का अंतर; ग्रह की ऊँचाई |

⚠ तीसरा तरीक़ा (आँख से दिखने का आधुनिक हिसाब) जान-बूझकर नहीं है। ऐप की ओर:
`app/lib/widgets/graha_ast_patti.dart` — **बंद** (`grahaAstPattiKhuli`); खोलने की शर्त
`docs/08` §21.5। औज़ार: `tool/ast_aazmao.dart` (दोनों तरीक़ों की तारीख़ें),
`tool/ast_byora.dart` (रोज़ का ब्योरा)।

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
| `suryodayaTithi(y,m,d,place)` → `SuryodayaTithi` | सिर्फ़ सूर्योदय की तिथि + वार, ~37 गुना तेज़ — कैलेंडर के खाने और आने वाली पूजाएँ (→ D-097) |
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
2. Drik के उस दिन के पन्ने से मिलाओ कि वो वहाँ नाम लिखता है या नहीं —
   **एक साल नहीं, कम से कम सात** (2024–2030)। एक साल पर मिला नियम सिद्ध नहीं
   होता: बारह पुराने नियम 2026 पर सही थे, सात साल पर पाँच ग़लत निकले (→ D-117)
3. सीधी व्यापिनी सातों साल न मिले तो व्यापिनी बदल-बदलकर मत बैठाओ — छपा
   निर्णय-ग्रंथ खोलो (`docs/18` §३०) और `Nirnaya` में नया फलन लिखो
4. जाँच `test/festival_test.dart` की `verified` सूची में डालो
5. `docs/08_VERIFICATION.md` में दर्ज करो

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

Flutter, package `com.vidhivat`। इंजन `path` dependency की तरह जुड़ा
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

### व्रत के पन्ने (→ D-075, D-077)

| फ़ाइल | क्या |
|---|---|
| `app/assets/vrat/_suchi.json` | सारे व्रत, समूह, `taiyar`, `engine`/`faail` |
| `app/assets/vrat/<id>.json` | एक व्रत, बारह खाने (`schemaVersion: 1`) |
| `app/assets/vrat/_ekadashi_varsh.json` | साल की 26 एकादशियाँ |
| `app/lib/vidhi/vrat_panna.dart` | `VratPanna`, `VratSuchiEntry`, `EkadashiVarsh`, `VratSamuh` |
| `app/lib/vidhi/bhandar.dart` | `vratBhandar` — सूची, पन्ना, एकादशियाँ |
| `app/lib/screens/vrat_panna_screen.dart` | `VratPannaScreen`, `KathaScreen`, `EkadashiVarshScreen` |
| `app/lib/widgets/katha_khand.dart` | `KathaKhand` — प्लेयर और कथा-पन्ना दोनों |
| `app/lib/widgets/mantra_khand.dart` | `MantraKhand`, `PaathKeBaareMein` |
| `tools/jaancho_vrat.py` | कंटेंट की जाँच, बिना Flutter |
| `app/test/vrat_content_test.dart` · `vrat_panna_screen_test.dart` | कंटेंट और पन्ने की जाँच |

### नया व्रत जोड़ना हो तो
1. `assets/vrat/<id>.json` — किसी मौजूदा व्रत की नक़ल से, बारहों खाने
2. कथा `assets/katha/` में; न लेनी हो तो `kathaIds: []` और `kathaKyonNahi`
3. `_suchi.json` में `taiyar: true`
4. `python tools/jaancho_vrat.py`, फिर `flutter test test/vrat_content_test.dart`


---

## ग्रह — `engine/lib/src/graha.dart` + `vsop_data.dart` (→ D-100)

`panchang.dart` के **बग़ल** में बैठती है, ऊपर नहीं: `julian`, `nutation`,
`ayanamsa`, `angles` पर टिकी है, और `sun.dart` / `moon.dart` को छूती नहीं।

| नाम | क्या |
|---|---|
| `enum Graha` | `mangal` · `budh` · `guru` · `shukra` · `shani` (+ `naam`) |
| `grahaHeliocentric(g, jde)` | सूर्य-केंद्रित L, B, R — Meeus 32 |
| `grahaApparent(g, jde)` | **मुख्य प्रवेश-द्वार** — पृथ्वी से आभासी देशांतर, अक्षांश, दूरी |
| `grahaLongitude` · `grahaNirayan` | सायन · निरयन (लाहिड़ी) देशांतर |
| `grahaGati` · `grahaVakri` | रोज़ की चाल; ऋणात्मक = वक्री |
| `grahaSuryaSeDoori(g, jde, सूर्य)` | सूर्य से कोणीय दूरी — अस्त का गणित (नियम नहीं) |
| `rahuMadhya` · `rahuMadhyaNirayan` · `ketuSe` | औसत राहु; केतु = +180° |
| `rahuSpasht` · `rahuSpashtNirayan` | स्पष्ट राहु — ⚠️ सन्निकट, 0.18° तक |
| `earthHeliocentric` · `sunLongitudeVsop` | ⚠️ **सिर्फ़ जाँच के लिए** — पंचांग इन्हें नहीं लेता |

`vsop_data.dart` — 2544 पद, औज़ार से बनी (`tools/banao_vsop.py`)।
🔑 **हाथ से कभी नहीं छूनी।**

| जाँच / औज़ार | क्या |
|---|---|
| `test/graha_test.dart` | VSOP के जाँच-मान · Meeus की मिसाल · JPL Horizons (5 ग्रह × 20 तारीख़ें) · वक्री/राहु के नियम |
| `test/data/horizons_graha.json` | Horizons का जाँच-डेटा (`tools/horizons_lao.py`) |
| `test/data/vsop_chk.json` | `vsop87.chk` के मान |
| `tool/graha_milan.dart` | हर पिंड का Horizons से सबसे बड़ा फ़र्क़ छापता है |

⚠️ अभी ऐप में कहीं नहीं जुड़ी। कुंडली की स्क्रीन K2 की जाँच के बाद ही
(→ `docs/29` §9)।

---

## ग्रंथालय — `lib/vidhi/granth.dart` + `assets/granth/` (→ D-098, D-099)

पूरे ग्रंथ, अध्याय-दर-अध्याय। हर अध्याय एक साधारण `Paath` है (`prakar:
granth`) और उसी `PaathScreen` से खुलता है; ग्रंथ सिर्फ़ **क्रम** जोड़ता है।

```
app/assets/granth/
├── _suchi.json            ग्रंथालय की सूची (गीता, सुंदरकांड)
├── gita/
│   ├── _kram.json         18 अध्याय, तीन हिस्सों में
│   └── gita_01.json … 18  700 श्लोक + हर अध्याय का समापन-वाक्य
├── sundarkand/            (→ D-106)
│   ├── _kram.json         12 प्रसंग, चार हिस्सों में
│   └── sundarkand_01 … 12 344 पद — श्लोक, चौपाई, दोहा, सोरठा, छंद, समापन
├── vishnusahasranama/     (→ D-107)
│   ├── _kram.json         तीन भाग
│   └── vishnusahasranama_01 … 03   आरंभ (13) · सहस्रनाम (107) · फलश्रुति (22)
├── sukta/                 (→ D-108)
│   ├── _kram.json         चार पाठ, तीन हिस्सों में
│   └── sukta_purusha · sukta_purusha_yv · sukta_nasadiya · sukta_shri
└── upanishad/             (→ D-109)
    ├── _kram.json         34 पाठ, दस हिस्सों में — नौ उपनिषद + शांति मंत्र
    └── upanishad_isha · _kena · _katha_11…23 · _prashna_1…6 · _mundaka_11…32 ·
        _mandukya · _tait_1…3 (अनुवाक) · _aitareya_1…3 · _shveta_1…6 · _shanti
```

`mahabharat/` (→ D-111, D-112, D-115) — `_kram.json` + `mahabharat_parichay` · `_p01 … _p18`: **सार**
(`"prakar": "saar"`) — गद्य, बिना रोमन और अर्थ के; और दो **पूरे पाठ** (`"prakar": "granth"`):
`mahabharat_yaksha` — यक्ष प्रश्न (48 खंड, 133 श्लोक) · `mahabharat_stavaraj` — भीष्म स्तवराज
(32 खंड, 108 श्लोक)।

`puran/` (→ D-113, D-114) — ग्रंथ «वेद और पुराण — परिचय»: `_kram.json` + `puran_ved` (चार वेद,
7 खंड) · `puran_parichay` (पुराण क्या हैं, 7 खंड) · `puran_atharah` (अठारह पुराण एक-एक, 18 खंड):
**सार** — वेदों की संहिताओं का ढाँचा और पुराणों की अपनी सूचियाँ; परिचय है, पाठ नहीं।

```
app/assets/paath/saptashati/   सप्तशती यहीं रही (उसकी `_kram.json` में अब `id`)

app/lib/vidhi/granth.dart            GranthKram · GranthHissa · GranthPaath · GranthSuchiEntry
app/lib/vidhi/saptashati.dart        अब सिर्फ़ typedef — SaptashatiKram = GranthKram
app/lib/vidhi/bhandar.dart           GranthBhandar (suchi, kram) + PaathBhandar.pathFor
app/lib/screens/granthalaya_screen.dart   सूची: गीता, सप्तशती
app/lib/screens/granth_screen.dart        अध्याय-सूची + "जहाँ छोड़ा वहीं से"
app/lib/screens/saptashati_screen.dart    अब GranthScreen का पतला लिफ़ाफ़ा
app/lib/screens/paath_screen.dart         GranthNavigation — नीचे की पट्टी
```

| नाम | क्या |
|---|---|
| `GranthKram` | एक ग्रंथ का क्रम — `id`, `naam`, `parichay`, `hisse`; हर पाठ की id `<ग्रंथ>_…` से शुरू होनी ही चाहिए |
| `GranthSuchiEntry` | सूची की एक पंक्ति — `chhotaNaam`, `ikai` ("अध्याय"/"पाठ"/"प्रसंग"), `khandIkai` ("श्लोक"/"पाठ"/"पद"), `gintiNaam` (सूची में "47 श्लोक" या "26 पद"; न लिखा हो तो "श्लोक") |
| `GranthSuchiEntry.saptashati` | सप्तशती कोड में लिखी है (`_suchi.json` में नहीं) |
| `GranthBhandar.granthIds` | जिन ग्रंथों के पाठ ऐप में हैं — id से फ़ोल्डर तय होता है |
| `GranthNavigation` | पट्टी: "गीता · अध्याय 2/18", पिछला/अगला; कुंजी `<ग्रंथ>_aakhri_khand_<पाठ>` |
| `Charan.granthSuchi` (`granth` = पहला) | पूजा के कदम पर ग्रंथ के बटन — JSON में `"granth"` नाम भी हो सकता है, सूची भी। कृष्ण पूजा: गीता + विष्णु सहस्रनाम; हनुमान और राम पूजा: सुंदरकांड |
| `PaathPrakar.granth` | "चालीसा और आरती" की छन्नी में नहीं आता |

| औज़ार / जाँच | क्या |
|---|---|
| `tools/banao_granth.py <id>` | `tools/granth_paath/<id>/` → ऐप की JSON। दो ढाँचे: गीता वाला (`mool.txt` + `arth/`) और `"dhancha": "khand"` (`paath/<कुंजी>.txt` — सप्तशती, सूक्त…) |
| `tools/jaancho_granth.py` | ऐप की JSON औज़ार के नतीजे से हूबहू है या नहीं + कंटेंट के नियम |
| `tools/banao_pandit_folder.py` | `docs/pandit_jaanch/` — अब अपनी पुरानी, बची हुई `.md` फ़ाइलें भी हटाता है (क्रम-अंक खिसकने पर) |
| `tools/lipi.py` | रोमन (`roman_sanskrit`; `roman_hindi` — अवधी/हिंदी, शब्द के अंत का "अ" नहीं), नुक़्ता खोलना (`khula`), देवनागरी अंक, `pancham()` (संकट → सङ्कट) |
| `tools/milan.py` | मिलान के साझा औज़ार — तुलना की कुंजी (`kunji_dev`, `kunji_iast`), पंक्तियाँ जोड़ना (`jodo`) |
| `tools/granth_paath/saptashati/milan/` | सप्तशती का मिलान; `sudhar.py` — पाठ के सुधारों की तालिका (→ D-103) |
| `tools/granth_paath/gita/milan/` | पाँच स्रोतों का मिलान → `mool.txt` |
| `tools/granth_paath/sundarkand/` | `kram.json` (`"lipi": "hindi"`), `paath/01…12.txt`; `milan/sk_mool.py` — आधार से 108 सुधारों की तालिका (→ D-106) |
| `tools/granth_paath/vishnusahasranama/` | `paath/01…03.txt`; `milan/naam_jaanch.py` — हज़ार नाम, क्रम, हर नाम अपने श्लोक में (repo के भीतर से चलता है) (→ D-107) |
| `tools/granth_paath/mahabharat/` | अठारह पर्वों का **सार** — `"prakar": "saar"`; `paath/*.txt` में शीर्षक + गद्य, `= अर्थ` नहीं; `kaisePadhein` में «⚠ … शब्दशः पाठ नहीं» ज़रूरी (औज़ार इसके बिना रुक जाता है) (→ D-111) |
| `app/test/mahabharat_test.dart` | 26 जाँचें — इक्कीस पन्ने क्रम में; भीष्म स्तवराज: श्लोक-अंक 1…108 बिना छेद, 46 «…आत्मने नमः» और अर्थ में उतने ही नमस्कार, ग्यारह सुधार; सार: दोनों गिनतियाँ अंक-दर-अंक, "यह सार है" खुला, "अर्थ दिखाएँ" नहीं; यक्ष प्रश्न: शीर्षकों के श्लोक-अंक 1…133 बिना छेद, हर खंड में उतने ही `॥`, पाँच सुधार, याद वाले श्लोक |
| `tools/granth_paath/puran/milan/` (गजेन्द्र मोक्ष) | `v85/` (**मूल** — पुस्तिका, आँख से) · `kh85/` (खेमराज की पोथी, आँख से) · `gajendra_milan.py` (दोनों का मशीन-मिलान) · `gm3.py` (पुराण के दूसरे पाठ से; स्रोत-फ़ाइलें `GM_SRC` में) · `gajendra_paath.py` (→ `paath/gajendra.txt`; `SUDHAR`, `KHAND` — अर्थ इसी में; इसे `puran_likho.py` बुलाता है) (→ D-121) |
| `tools/granth_paath/puran/` | **वेद और पुराण — परिचय** (→ D-113, D-114) + **गजेन्द्र मोक्ष** का पूरा पाठ (→ D-121) — `kram.json` और `paath/*.txt` हाथ से नहीं, `milan/puran_likho.py` से; गिनतियाँ `milan/pu_suchi.py` (पुराण) और `milan/ved_suchi.py` (वेद) की तालिकाओं में; `pu_jaanch.py` / `ved_jaanch.py` उन्हें गवाहों और डिजिटल पाठों पर दोबारा जाँचते हैं |
| `app/test/puran_test.dart` | 31 जाँचें — चार पन्ने; गजेन्द्र मोक्ष: श्लोक-अंक 1…84 बिना छेद, छह वक्ता, पुस्तिका वाले बारह शब्द हैं और दूसरे पाठ वाले नहीं, एक सुधार, अर्थ में गढ़े शब्द नहीं, "ऐप का दावा नहीं"; चार वेद: ऋग्वेद की मण्डल-वार गिनती और जोड़, बाक़ी तीन की गिनतियाँ, «इस ऐप में» सत्रह फ़ाइलों से; अठारह खंड क्रम में; हर पुराण की दोनों गिनतियाँ तालिका से हूबहू और जोड़ 4,00,000 / 4,04,800; शिव-या-वायु; «इस ऐप में» की हर पंक्ति उस कथा की फ़ाइल से; "यह परिचय है" खुला |
| `tools/granth_paath/mahabharat/milan/` | भीष्म स्तवराज: `v47/` (**मूल**), `bs_k.py`/`bs3.py` (तीन पाठों से मशीन-मिलान), `stavaraj_paath.py` (→ `paath/stavaraj.txt`; अर्थ इसी में) (→ D-115) · यक्ष प्रश्न: `v313/` (छपी पुस्तक से आँख से पढ़ा पाठ — **यही मूल है**), `yaksha3.py`/`yaksha4.py` (तीन पाठों से मशीन-मिलान), `yaksha_paath.py` (→ `paath/yaksha.txt`; अर्थ इसी में) (→ D-112) |
| `PaathPrakar.saar` | `vidhi/paath.dart` — गद्य का सार; `paath_screen` में शीर्षक "सार", बटन नहीं, अक्षर `bodyLarge` |
| `tools/granth_paath/upanishad/` | `paath/*.txt` (खंड `मंत्र N`, तैत्तिरीय में `अनुवाक N`); `kram.json` में तैत्तिरीय पर `gintiNaam`; `milan/` — S को गवाहों और छपी टीका के OCR से कसना, 163 सुधारों की तालिका (→ D-109) |
| `app/test/upanishad_test.dart` | 34 पाठों की गिनती (460 मंत्र + 31 अनुवाक + 8); हर उपनिषद का शांति पाठ = शांति मंत्रों वाला; बँटे हुए पाठ और उनका ⓘ; तैत्तिरीय "अनुवाक" में |
| `tools/granth_paath/sukta/` | `paath/*.txt` (खंड `मंत्र N`); `milan/` — ऋग्वेद, यजुर्वेद और श्री सूक्त का मिलान (→ D-108) |
| `app/test/sukta_test.dart` | 16 + 16 + 7 + 15 मंत्र; कोई स्वर-चिह्न नहीं; पुरुष सूक्त के दो पाठ सचमुच अलग; ⓘ; लक्ष्मी पूजन से रास्ता |
| `app/test/vishnusahasranama_test.dart` | 13 + 107 + 22 श्लोक; नाम १ से १००० बिना टूटे; ⓘ; कृष्ण पूजा के दो बटन |
| `app/test/sundarkand_test.dart` | 344 पद, दोहा १–६० बिना छूटे, 526 चौपाई-पंक्तियाँ, विराम, भूलें लौटी नहीं, ५९.३ का नोट, स्क्रीन, हनुमान पूजा से रास्ता |
| `app/test/granth_test.dart` | गिनती 700, क्रम, हर खंड भरा, नुक़्ता, उवाच 59, समापन |
| `app/test/granth_screens_test.dart` | ग्रंथालय → अध्याय → अगला; याद रखना; कृष्ण पूजा से गीता |

### नया ग्रंथ जोड़ना हो तो
`tools/granth_paath/gita/00_PADHIYE.md` के आख़िरी खंड में पाँचों कदम हैं।
🔑 `app/assets/granth/<id>/*.json` **हाथ से कभी नहीं** — औज़ार से।

### कुंडली — `engine/lib/src/kundali.dart` + `dasha.dart` (→ D-101, D-105)

✅ `kundaliIsReady = true` (2 अक्टूबर 2026 — लग्न NASA से 15″)। ऐप की स्क्रीनें इसी पर टिकी हैं।

`graha.dart`, `sun.dart`, `moon.dart`, `sunrise.dart` (नाक्षत्र काल) के ऊपर
बैठती है; `panchang.dart` को छूती नहीं।

| नाम | क्या |
|---|---|
| `computeKundali(janmUtc, place, {spashtRahu})` | **मुख्य प्रवेश-द्वार** → `Kundali` |
| `Kundali` | `lagna` · `grahas` (नौ) · `bhav(g)` · `chandraSeBhav(g)` · `navamshaBhav(g)` · `bhavMein(n)` · `lagnaSandhiMein()` |
| `RashiSthiti` | एक निरयन देशांतर से: `rashi` · `ansh` · `nakshatra` · `charan` · `navamsha` |
| `GrahaSthiti` | `RashiSthiti` + `graha` · `gati` · `vakri` |
| `enum KundaliGraha` | सूर्य … केतु, नौ |
| `lagnaSayan` · `lagnaNirayan` · `localSiderealTime` | लग्न और उसकी जड़ |
| `vimshottariMahadasha(janmUtc, चंद्र)` | दस `DashaKhand` — जन्म से 120 साल |
| `vimshottariAntardasha(maha)` | नौ अंतर्दशाएँ |
| `nakshatraSwami` · `janmParDashaShesh` · `vimshottariKram` · `vimshottariVarsh` | तालिकाएँ |

| `janmPanchang(janmUtc, place, {masaSystem})` → `JanmPanchang` | `janm_panchang.dart` — जन्म के **क्षण** की तिथि, नक्षत्र-चरण, योग, करण; वार सूर्योदय से; मास-संवत् जन्म की तिथि के |
| `bharatSamayAntar(घड़ी)` · `yuddhKalKiGhadi` · `bharatSamayPehlaSaal` | `bharat_samay.dart` — भारत की घड़ी का इतिहास (1941–45 में +6:30) |

`test/kundali_test.dart` · `test/lagna_nasa_test.dart` (NASA से 96 क्षण) ·
`test/janm_test.dart` · `tool/kundali_cli.dart` — छपी जन्मपत्री से मिलाने के लिए।

**ऐप में (→ D-105):**

| फ़ाइल | क्या |
|---|---|
| `app/lib/state/kundali_profiles.dart` | `KundaliProfile` (नाम, जन्म की घड़ी, जगह) — सिर्फ़ फ़ोन में; `place` में घड़ी का अंतर अपने आप |
| `app/lib/screens/kundali_profiles_screen.dart` | सूची + `KundaliForm` (ब्यौरा भरना, घड़ी वाली चेतावनियाँ) |
| `app/lib/screens/kundali_screen.dart` | चार पट्टियाँ: कुंडली · ग्रह · दशा · पंचांग; चित्र PNG बनकर भेजना; ⓘ "यह गणना कैसे हुई" |
| `app/lib/widgets/kundali_chitra.dart` | उत्तर भारतीय चित्र (`CustomPainter`); `bhavVibhag()` — लग्न / चंद्र / नवमांश का बँटवारा |
| `app/test/kundali_screens_test.dart` | 17 जाँचें — छोटे फ़ोन, बड़े अक्षर, और वर्जित शब्द |

⛔ फलादेश, राशिफल, उपाय — इन फ़ाइलों में नहीं हैं और नहीं आएँगे।

### अवकहड़ा और गुण मिलान — `avakahada.dart` + `gun_milan.dart` (→ D-110)

सिर्फ़ तालिकाएँ — खगोल `kundali.dart` से आता है (चंद्रमा का निरयन देशांतर)।

| नाम | क्या |
|---|---|
| `avakahada(चंद्र)` → `Avakahada` | `naamAkshar` · `naamAksharKiJagah` (ङ, ण, ञ पर) · `abhijitAkshar` · `varna` · `vashya` · `vashyaPurana` · `yoni` · `gana` · `nadi` · `rashiSwami` |
| `enum Varna · Vashya · Yoni · Gana · Nadi` | नाम देवनागरी में; `Yoni.saral` बोलचाल का नाम |
| `gunMilan(varChandra:, kanyaChandra:)` → `GunMilan` | `koot` (आठ `KootAnk`) · `kul` · `puraniTalikaSeKul` (अलग हो तभी) |
| `KootAnk` | `ank` · `puraniTalikaSe` (योनि, गण — अलग हो तभी) · `talikaBantiHai` (वश्य) · `varKa` · `kanyaKa` |
| `grahaMaitriAnk` · `tara` · `taraAnk` · `bhakootAnk` | नियम से निकलने वाले अंक |
| `RashiSthiti.nakshatraSeemaSeDoori` · `charanSeemaSeDoori` | `kundali.dart` में — चंद्रमा सीमा के पास हो तो चेतावनी के लिए |
| `avakahada_data.dart` | ⚠ **औज़ार से बनी** — `python tools/banao_avakahada.py`; तालिकाएँ `[कन्या][वर]` |

`test/avakahada_test.dart` (20) — तालिकाएँ यहाँ **दोबारा टाइप** हैं, औज़ार वाली प्रति से
अलग। `tools/banao_avakahada.py --jaancho` (फ़ाइल औज़ार से हूबहू?) · `--bhed` (पुस्तकों
के बीच के फ़र्क़ — `docs/18` अध्याय २६ यहीं से)।

| फ़ाइल | क्या |
|---|---|
| `app/lib/screens/kundali_screen.dart` | "पंचांग" पट्टी के नीचे `_avakahadaKhand` — सात पंक्तियाँ, दो खुले वाक्य, ⓘ "ये तालिकाएँ कहाँ से" |
| `app/lib/screens/gun_milan_screen.dart` | वर/कन्या का चुनाव (सहेजी कुंडलियों में से), कुल, आठ कूट, ⓘ "ये अंक कैसे निकले"; `gunAnk()` — "1½" |
| `app/lib/screens/kundali_profiles_screen.dart` | `गुण मिलान` का बटन — दो कुंडलियाँ हों तभी |
| `app/test/gun_milan_test.dart` | 15 जाँचें — अंक इंजन वाले ही, तीन खुले सच, छोटा फ़ोन, तेरह वर्जित शब्द |

⛔ फ़ैसला ("इतने गुण पर…"), "दोष", किसी कूट का फल, परिहार — नहीं हैं और नहीं आएँगे।
