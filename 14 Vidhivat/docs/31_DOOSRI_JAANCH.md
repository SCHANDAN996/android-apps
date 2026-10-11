# 31 — दूसरी जाँच: किसी और AI से, सख़्ती से

> **यह क्या है:** 5–11 अक्टूबर 2026 के काम (D-112 से D-120) को ChatGPT जैसे किसी दूसरे AI से
> जँचवाने का तैयार सामान — कौन-सी फ़ाइल देनी है और क्या पूछना है।
> **क्यों:** यह सारा काम एक ही AI ने किया और उसी ने जाँचा। संस्कृत के छपे पन्ने उसी ने पढ़े,
> अर्थ उसी ने लिखे। दूसरी आँख वही ग़लती पकड़ सकती है जो पहली को दिखी ही नहीं।

## पहले तीन बातें

1. **दूसरा AI भी अंतिम सच नहीं है।** पंचांग की तारीख़ों और संस्कृत के पाठ में वह भी भूल
   करता है, और याद से "सुधार" देता है। इसलिए नीचे के prompt में उससे **सबूत** माँगा गया है।
   वह जो बताए, उसे ऐप में तभी बदला जाएगा जब छपे पन्ने से मिल जाए।
2. **जो वह नहीं कर सकता:** ऐप चलाना, जाँचें चलाना, फ़ोन पर देखना। वे यहीं हो चुकी हैं
   (इंजन 589, ऐप 1302 पास) — पर फ़ोन पर देखना आपका काम है और अब भी बाक़ी है।
3. **एक बार में एक गठरी।** सब कुछ एक साथ देने पर वह ऊपर-ऊपर से पढ़ता है। नीचे पाँच गठरियाँ
   हैं; हर एक अलग बातचीत में दीजिए।

## हर गठरी के साथ यह prompt (पहले यही चिपकाइए)

```
You are a strict, adversarial reviewer. Your job is to FIND ERRORS, not to
praise. Assume the work contains mistakes until you have checked it.

Rules:
1. For every problem give: severity (CRITICAL / MAJOR / MINOR), the exact
   place (file name + line, or verse number), what is wrong, and your
   EVIDENCE (a quoted printed edition with page, or a URL you actually
   opened). No evidence = say "UNVERIFIED SUSPICION".
2. NEVER correct Sanskrit or a date from memory. If you think a word or a
   date is wrong, cite where you checked it. If you could not check, say
   "could not verify" — do not guess.
3. Say how confident you are for each finding: CERTAIN / LIKELY / UNSURE.
4. Do not rewrite the files. Do not suggest style changes. Only correctness.
5. End with two lists: (a) what you checked and found correct,
   (b) what you did NOT check and why.

Reply in simple Hindi (Devanagari). Keep Sanskrit in Devanagari.
```

## गठरी १ — त्योहार की तारीख़ें (D-117) · सबसे ज़रूरी

**फ़ाइलें:** `engine/lib/src/festival.dart` · `engine/test/festival_test.dart`

**फिर यह पूछिए:**

```
This Dart file computes Hindu festival dates. Five festivals (Holika Dahan,
Raksha Bandhan, Rama Navami, Janmashtami, Diwali) use rules taken from the
printed Dharmasindhu; the Sanskrit sentences are quoted in the comments
above each function (_holika, _raksha, _ramNavami, _janmashtami,
_lakshmiPujan).

Check, in this order:
A. For each of the five: is the Sanskrit quoted correctly, and does the
   Hindi explanation in the comment say what the Sanskrit says? Pay special
   attention to: "दिनद्वये मध्याह्नव्याप्तावव्याप्तौ वा परा",
   "त्रिमुहूर्ताधिकोदयव्यापिन्याम्", "घटिकाधिकरात्रिव्यापिनि",
   "सार्धत्रियामा … प्रतिपद् वृद्धिगामिनी", and the Janmashtami
   "निर्णयसंग्रह" passage.
B. Does the code of each function do exactly what its comment says? Look for
   wrong comparisons, off-by-one-day errors, and cases the code does not handle.
C. The test file lists dates for 2024–2030 (Delhi). Check as many as you can
   against a panchang you can open. List every date where your source
   differs, with the source.
D. Janmashtami: the comment marked ⚠ describes one case (Delhi 2032, Mumbai
   2029) where the code follows the text but a reference panchang gives the
   next day. Which is right according to Dharmasindhu and Nirnayasindhu?
   Give the passage you rely on.
```

## गठरी २ — गुरु/शुक्र अस्त (D-119)

**फ़ाइलें:** `engine/lib/src/graha_ast.dart` · `engine/test/graha_ast_test.dart` ·
`app/lib/widgets/graha_ast_patti.dart`

```
This code finds when Jupiter and Venus are "asta" (combust). Check:
A. Are the kalamsha values (Jupiter 11; Venus 10, retrograde 8) and the
   quoted Surya Siddhanta verses 9.6–7 correct?
B. Muhurta Chintamani, Samskara-prakarana verses 26–28: is the mapping of
   "bala" and "vriddha" days right — Venus: rising in east 3 days, rising in
   west 10; before setting in east 15, before setting in west 5; Jupiter 15
   and 15? Quote the commentary you rely on.
C. Any logic errors in grahaAstKaal (both methods)?
D. The Hindi text shown to users in graha_ast_patti.dart: is anything in it
   false or overclaiming?
```

## गठरी ३ — शमी और अपराजिता के मंत्र (D-118)

**फ़ाइल:** `app/assets/vidhi/navratri/vijayadashami.json` (कदम «अपराजिता और शमी पूजन»)

```
In the step "अपराजिता और शमी पूजन" check the mantra block: every Sanskrit
word (spelling, sandhi, anusvara/visarga), the roman transliteration, and
whether the Hindi meaning ("arth") says what the Sanskrit says. The text was
taken from Nirnayasindhu, Dharmasindhu and Gita Press Vrat-Parichay; three
variant readings are listed in "vikalp". Is the chosen reading defensible?
```

## गठरी ४ — यक्ष प्रश्न और भीष्म स्तवराज (D-112, D-115)

**फ़ाइलें:** `tools/granth_paath/mahabharat/paath/yaksha.txt` ·
`tools/granth_paath/mahabharat/paath/stavaraj.txt`
(हर खंड: `# शीर्षक`, फिर श्लोक की पंक्तियाँ, फिर `= अर्थ`)

```
These are two Mahabharata texts with Hindi meanings written by an AI.
A. Sanskrit: find typos, wrong sandhi, missing or extra half-verses. Compare
   with a printed vulgate edition (Gita Press / Nilakantha) — NOT the
   critical edition, whose readings differ. Cite the edition.
B. Meanings: find every place where the Hindi says something the Sanskrit
   does not say, leaves out part of the verse, or adds something. In the
   Bhishma Stavaraja look hardest at verses 28, 44, 70, 77, 80 and 89 — the
   author was not sure of these.
Give the verse number for every finding.
```

## गठरी ५ — वेद और पुराण का परिचय (D-113, D-114)

**फ़ाइलें:** `tools/granth_paath/puran/paath/ved.txt` · `parichay.txt` · `atharah.txt` ·
`tools/granth_paath/puran/milan/pu_suchi.py` · `ved_suchi.py`

```
These are short Hindi introductions to the four Vedas and the eighteen
Puranas. Every number in them is supposed to come from the tables in the
two .py files. Check:
A. The verse counts of the eighteen Puranas as given in Bhagavata 12.13 and
   Matsya 53 — is each number right, and are the four Puranas where the two
   lists differ correctly identified?
B. The Veda numbers (Rigveda mandalas / suktas / mantras, Yajurveda
   adhyayas, Samaveda 1875 = 650 + 1225, Atharvaveda kandas / suktas) — which
   recension is each number from, and is it stated correctly?
C. Any statement about a Veda or Purana that is wrong, or that is tradition
   presented as fact.
```

## जवाब आए तो

पूरा जवाब यहाँ (Claude Code में) चिपका दीजिए। हर बात छपे पन्ने से मिलाई जाएगी: जो सच निकले
वह ठीक होगी और `01_DECISIONS` में दर्ज होगी; जो न निकले उसके आगे लिखा जाएगा कि क्यों नहीं मानी।

## जो कोई AI नहीं जाँच सकता — और अब भी बाक़ी है

- **फ़ोन पर चलाकर देखना** (`04_NEXT` की सूची)।
- **पंडित जी** — मंत्र, और `04_NEXT` के तीन सवाल (जन्माष्टमी की एक शाखा, होलिका पर ग्रहण,
  दीपावली का दूसरा मत)।
- **घर का पंचांग** — गुरु/शुक्र अस्त की चार तारीख़ें, और हो सके तो 2027 के होलिका दहन,
  रक्षाबंधन और जन्माष्टमी की तारीख़ें।
