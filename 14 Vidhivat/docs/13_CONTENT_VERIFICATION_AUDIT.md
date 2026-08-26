# Vidhivat Content Verification Audit & Responsible Launch Plan

**Audit date:** 26 August 2026  
**Audit type:** Read-only content, source, consistency and safety review  
**Current status:** Research complete; no Puja JSON, UI, production code or verification flag was changed during this audit  
**Purpose:** Independent review by Opus 5 (or another reviewer) before any religious-content changes are implemented

---

## 1. Executive decision

The current content should **not** be presented as any of the following:

- “पूरी तरह शास्त्र-सम्मत”
- “पंडित द्वारा प्रमाणित”
- “हर हिन्दू परंपरा के लिए एकमात्र सही विधि”
- “पंडित/आचार्य का पूर्ण विकल्प”
- “सभी 12 पूजाएँ पूर्ण और verified”

The application can still be launched without a Pandit review, but only after the high-confidence errors and safety blockers documented below are resolved and the product is positioned as:

> **स्रोत-समीक्षित सरल घरेलू पूजा मार्गदर्शिका। पूजा-विधि क्षेत्र, संप्रदाय, वेद-शाखा, परिवार और कुल-परंपरा के अनुसार बदल सकती है।**

The appropriate verification claim is **source-reviewed**, not **religiously sanctioned**. AI and textual research can verify exact text, source attribution, transliteration, literal meaning, internal consistency and evidence quality. They cannot grant universal religious authority or replace an Acharya in rites where an Acharya is structurally required.

### Approval decision

| Question | Decision |
|---|---|
| Is the audit/research complete? | **Yes** |
| Was any religious content changed during the audit? | **No** |
| Can the current 12-Puja content be approved as-is? | **No** |
| Can a limited source-reviewed household guide be launched after corrections? | **Yes** |
| Can every samskara/rite be offered as priest-free DIY? | **No** |

---

## 2. Scope inspected

The audit covered:

- all 12 Puja JSON files under `app/assets/vidhi/`
- all Puja steps and durations
- all material checklist entries
- all filled and empty mantra slots
- Devanagari, Roman text, meanings and source strings
- FAQs and absolute religious/outcome claims
- verification/trust metadata
- Sankalp construction and its own grammar review document
- audio readiness
- safety-sensitive instructions
- content tracker consistency
- source quality and commercial-use/licensing concerns

### Inventory snapshot

| Puja | Steps | Materials (required/optional) | Filled mantra slots / total | Recorded trust metadata high/medium/low |
|---|---:|---:|---:|---:|
| Ganesh Puja | 11 | 23 (19/4) | 4/8 | 4/0/4 |
| Grih Pravesh | 14 | 36 (30/6) | 5/10 | 5/0/5 |
| Kalash Sthapana | 11 | 31 (29/2) | 5/8 | 5/0/3 |
| Karwa Chauth | 12 | 25 (22/3) | 4/8 | 4/0/4 |
| Lakshmi Puja | 13 | 35 (31/4) | 5/8 | 5/0/3 |
| Mundan | 12 | 30 (25/5) | 5/8 | 5/0/3 |
| Nitya Puja | 9 | 15 (11/4) | 4/6 | 4/0/2 |
| Rudrabhishek | 11 | 31 (24/7) | 4/8 | 4/0/4 |
| Satyanarayan | 14 | 44 (34/10) | 7/9 | 4/3/2 |
| Shraddha | 10 | 23 (19/4) | 3/5 | 3/0/2 |
| Upanayan | 13 | 33 (30/3) | 5/8 | 5/0/3 |
| Vahan Puja | 9 | 18 (14/4) | 4/6 | 4/0/2 |
| **Total** | **139** | **344 (288/56)** | **55/92** | **52/3/37** |

Additional facts:

- 37 of 92 mantra slots are empty.
- The 55 filled mantra instances collapse to only **8 unique Sanskrit texts** reused across the app.
- Every filled mantra is currently marked `draft`; none is marked `paas`.
- All 12 Puja files currently have `jaanch.paas: false`.
- Audio is absent for all 92 mantra slots.
- Roman fields use plain ASCII and contain no proper IAST diacritics.
- The top-level procedure metadata does not provide a claim-level bibliography, edition, page, verse or URL.

These facts do not prove that all content is false. They prove that the current system does not demonstrate whole-Puja authenticity.

---

## 3. Finding classification used in this report

To avoid confusing regional variation with error, findings are classified as follows:

1. **Confirmed error:** Directly contradicted by a primary/institutional source or by the app’s own data.
2. **Internal contradiction:** Two app instructions cannot both be followed as written.
3. **Missing evidence/content:** The claim may be valid, but the source or required content is absent.
4. **Tradition-dependent:** Multiple valid forms may exist; a named tradition is required before choosing one.
5. **Safety blocker:** The instruction can create medical, fire, toxic, driving or environmental risk.

Only categories 1–3 should be treated as content defects without further religious judgement. Category 4 must be scoped and labelled, not automatically “corrected” into one universal form.

---

## ✅ 4-अ. इनमें से क्या ठीक हो चुका (26 अगस्त 2026)

यह audit read-only था। नीचे दर्ज ग़लतियों में से जो ठीक हो चुकी हैं:

| बिंदु | हालत | कहाँ |
|---|---|---|
| 4.1 ग़लत गणपति citation | ✅ **ठीक** — दावा ख़ुद जाँचकर सुधारा, भरोसा घटाया | D-037 |
| 4.2 संकल्प का व्याकरण | ⬜ चेतावनी बनी हुई है, सुधार पंडित जी से | D-020, docs/11 |
| 4.3 देवी वाली क्षमा प्रार्थना | 🟡 नई पूजाओं में देवी संदर्भ पर **ख़ाली** छोड़ी गई; पुरानी में `vikalp` में चेतावनी | — |
| 4.4 करवा चौथ निर्जल बनाम आचमन | ✅ **ठीक** — अब "जल पिए बिना" साफ़ लिखा है | — |
| 4.5 सत्यनारायण कथा/षोडशोपचार | ✅ **दावे सुधरे** — नाम से "और कथा" हटा, कदम "उपचार पूजन" हुआ | — |
| 4.6 रुद्राभिषेक में रुद्र पाठ नहीं | ✅ **नाम बदला** → "सरल शिव अभिषेक" | — |
| 4.7 रोमन IAST नहीं है | 🟡 हर फ़ाइल में "सिर्फ़ पढ़ने की सहायता" लिखा; असली IAST बाक़ी | — |
| 5.1 समय बनाम कदमों का जोड़ | ✅ **ठीक, और ढाँचे में बंद** | D-036 |
| 5.2 गायब सामग्री | ✅ **ठीक** — पंचामृत, दूर्वा, पिंड का आटा | — |
| 5.3 required/optional टकराव | ✅ **ठीक** — दूर्वा, मोदक, वार, कलश का व्रत | — |
| 5.4 ट्रैकर की गिनती | ✅ **ठीक** — अब जाँच JSON से गिनकर छापती है | — |
| 7. सुरक्षा | 🟡 नई छह पूजाओं में डाली गईं; पुरानी में बाक़ी | — |
| 11. scope अलग करना | ✅ **हो गया** | D-035 |

⬜ **अब भी बाक़ी:** IAST, संकल्प का व्याकरण, कथा का लाइसेंस, ऑडियो,
पुरानी बारह पूजाओं की सुरक्षा-चेतावनियाँ, और पंडित जी की असली जाँच (0/18)।

---

## 4. Confirmed high-priority content errors

### 4.1 Wrong source attribution for the repeated Ganapati text

Eleven Puja files use:

```text
ॐ गणानां त्वा गणपतिं हवामहे
प्रियाणां त्वा प्रियपतिं हवामहे
निधीनां त्वा निधिपतिं हवामहे
वसो मम।
```

Example locations:

- `app/assets/vidhi/ganesh_poojan.json:265`
- source metadata at `app/assets/vidhi/ganesh_poojan.json:269`

The app attributes this exact combined text to `ऋग्वेद २.२३.१`. That citation is incorrect.

- Rigveda 2.23.1 continues with `कविं कवीनामुपमश्रवस्तमम्...`.
- The text used in the app corresponds to the opening portion of Vajasaneyi Madhyandina Samhita 23.19.

Authoritative comparison:

- [Government Vedic Heritage Portal — Rigveda 2.23.1](https://vedicheritage.gov.in/samhitas/rigveda/shakala-samhita/rigveda-shakala-samhita-mandal-02-sukta-023/)
- [Government Vedic Heritage Portal — Vajasaneyi Madhyandina Samhita 23.19](https://vedicheritage.gov.in/samhitas/yajurveda/vajasneyi-madhyandina-samhita/samhita-patha-21-30-adhyaya-23/)

The current Hindi meaning “हमारे यहाँ पधारिए और बस जाइए” is also not a precise literal rendering of `वसो मम`.

**Required action:** Correct the source, verify the complete selected reading, preserve/declare Vedic svara policy, rewrite the meaning independently, and update every reused occurrence through one canonical mantra record.

### 4.2 Sankalp Sanskrit is not ready for a verified badge

The existing project document `docs/11_SANKALP_VYAKARAN.md` itself identifies unresolved grammar:

- current `{तिथि} तिथौ` does not decline the tithi name; for example, `नवमी तिथौ` versus a locative form such as `नवम्यां तिथौ`
- current `{गोत्र} गोत्रोत्पन्नः` is always masculine; a female yajman requires a feminine form such as `गोत्रोत्पन्ना`
- the generated `{नाम} अहं` may require the conventional `नाम/नामाहं` construction

Implementation locations:

- `engine/lib/src/sankalp.dart:105`
- `engine/lib/src/sankalp.dart:121`
- `engine/lib/src/sankalp.dart:122`

The code intentionally keeps `needsPanditReview: true`; existing tests freeze current output but do not prove Sanskrit correctness.

**Required action:** Keep the warning. Do not set Sankalp to verified until grammar, user gender/form, name construction and selected prayoga convention are resolved and tested.

### 4.3 Deity/gender mismatch in the shared Kshama prayer

The shared prayer includes masculine/Vishnu-addressed forms such as:

```text
क्षम्यतां परमेश्वर
भक्तिहीनं जनार्दन
यत्पूजितं मया देव
```

It is also reused in Lakshmi, Kalash/Navratri and Karwa Chauth contexts. The app’s own variant note recognizes that देवी contexts require forms such as `परमेश्वरि`, `सुरेश्वरि` or `देवि`.

**Required action:** Do not mechanically replace words. Establish a sourced full prayer for each declared deity context and verify grammar as a complete text.

### 4.4 Karwa Chauth Nirjala contradiction

`app/assets/vidhi/karwa_chauth.json` says:

- after Sargi, the user keeps a day-long `निर्जल व्रत`
- a later step instructs three water sips during Achamana
- the supplied meaning explicitly says water is drunk three times

These instructions directly contradict one another as written.

**Required action:** Select and source a specific regional practice. If that practice uses mental/touch Achamana during a Nirjala fast, say so explicitly; do not instruct drinking water.

### 4.5 Satyanarayan title and Shodashopachara are incomplete

`app/assets/vidhi/satyanarayan.json` is titled as Puja **and Katha**, but the five Katha chapters are not present. A step only tells the user to read/listen to them.

The step labelled `षोडशोपचार पूजन` lists approximately twelve named offerings rather than a complete declared set of sixteen.

An institutional practical source lists a complete sixteen-offering framework, including Padya, Arghya, Achamana, Snana, Vastra, Abhushana, Gandha, Pushpa, Dhupa, Dipa, Naivedya, subsequent Achamana, Tambula, Stava, Tarpana and Namaskara:

- [MSRVVP Mandir Prabandhan textbook](https://msrvvp.ac.in/skill_course/textbook/Mandir_Prabandhan_Kanishtha_Sahayak_27_06_24.pdf)

**Required action:** Either supply a licensed, edition-scoped Katha and a fully sourced selected procedure, or remove “और कथा”/“षोडशोपचार” claims until complete.

### 4.6 Current Rudrabhishek has no core Rudra recitation

The main Rudra/Shiva mantra slots for water abhisheka, Panchamrita, Bilva and Aarti are empty. No sourced Sri Rudram/Rudrashtadhyayi sequence is present.

**Required action:** Until a complete tradition-scoped procedure is sourced, rename/position it as **सरल शिव अभिषेक**, not full Rudrabhishek. Do not synthesize Vedic Rudra content.

### 4.7 Roman transliteration is not pronunciation-safe

Current examples use ASCII forms such as:

```text
gananam tva ganapatim
hrishikeshaya
pundarikaksham
kshamyatam
```

They omit long vowels, retroflex consonants, `ś/ṣ`, anusvara/visarga distinctions and other Sanskrit phonetic information. Canonical IAST would contain forms such as `gaṇānāṃ`, `hṛṣīkeśāya`, `puṇḍarīkākṣam` and `kṣamyatām` as appropriate to the verified base text.

**Required action:** Call the present field “सरल Roman सहायता” only, or replace it with human-proofread IAST derived from the verified canonical text. Never use the current ASCII field as authoritative TTS input.

---

## 5. Confirmed internal data and material contradictions

### 5.1 Every declared Puja duration is lower than its sequential step total

| Puja | Declared minutes | Sum of step minutes | Difference |
|---|---:|---:|---:|
| Ganesh | 30 | 42 | +12 |
| Grih Pravesh | 120 | 157 | +37 |
| Kalash | 60 | 80 | +20 |
| Karwa Chauth | 60 | 75 | +15 |
| Lakshmi | 90 | 103 | +13 |
| Mundan | 60 | 87 | +27 |
| Nitya | 15 | 22 | +7 |
| Rudrabhishek | 60 | 67 | +7 |
| Satyanarayan | 90 | 132 | +42 |
| Shraddha | 60 | 89 | +29 |
| Upanayan | 180 | 219 | +39 |
| Vahan | 25 | 31 | +6 |

**Required action:** Decide whether step times are sequential estimates or overlapping/preparation time. Recalculate from one documented rule and test it.

### 5.2 Missing materials required by steps

- Ganesh Puja requires Panchamrita bathing, but its checklist does not include the five Panchamrita ingredients.
- Kalash, Karwa Chauth and Rudrabhishek call for Durva during their Ganesh step, but Durva is absent from their checklists.
- Shraddha asks for barley flour or rice flour for Pinda, but the checklist provides whole grain only.

### 5.3 Direct required/optional conflicts

- Ganesh Durva is marked required and “इसके बिना पूजा अधूरी”, while the FAQ says Puja may continue without it.
- 21 Modaks are required in the checklist, while the FAQ permits 5, 11 or as many as available.
- Kalash Sankalp states a nine-day fast, while its FAQ says fasting is not necessary.
- Ganesh `vaarSuchi: [2]` encodes Tuesday only, but the accompanying note claims Tuesday and Wednesday.
- Satyanarayan Gangajal guidance says that if Gangajal is unavailable, add “one drop” to clean water, without explaining which drop is available.

### 5.4 Documentation tracker inconsistencies

- `docs/06_CONTENT_TRACKER.md` states 345 materials; the current data contains 344.
- Satyanarayan mantra coverage is shown inconsistently in different tracker sections.
- The tracker’s claim about five shared mantras across all 12 files does not match actual occurrence counts.

**Required action:** Regenerate tracker metrics from JSON rather than maintaining counts manually.

---

## 6. Unsupported absolute claims that require sourcing or softer language

These are not all necessarily false, but they are currently presented too absolutely:

- “दूर्वा के बिना पूजा अधूरी”
- “तुलसी के बिना नैवेद्य अधूरा”
- “जौ जितने हरे होंगे उतना शुभ”
- milk boiling/spilling as a prosperity indicator
- crushing lemons under vehicle wheels as removal of evil eye
- Karwa Chauth as a factual cause of a husband’s long life
- one regional number/order/direction as universally mandatory

**Required action:** Classify each claim as one of:

- शास्त्रीय स्रोत
- उत्तर भारतीय प्रचलित पद्धति
- क्षेत्रीय/लोकपरंपरा
- परिवार/कुल परंपरा देखें
- सरल app adaptation
- प्रतीकात्मक मान्यता; परिणाम की गारंटी नहीं

Do not convert a customary belief into a measurable health, safety, prosperity or protection guarantee.

---

## 7. Safety blockers

These items require correction before public release even if their ritual source is found.

### 7.1 Karwa Chauth health advice

Illness, pregnancy and medication-related fasting advice should direct the user to a qualified medical professional, not only an elder or Pandit. The app must not pressure a vulnerable user into Nirjala fasting.

### 7.2 Mundan child safety

Instructions involving a razor, hot water, Dahi/Haldi and substances on a freshly shaved child’s scalp lack sterile-tool, wound, allergy, burn and first-aid guidance. The app should not instruct an untrained parent to perform the shave.

### 7.3 Akhand Jyoti/fire safety

Any overnight or nine-day lamp instruction requires explicit supervision, stable non-flammable placement, ventilation and child/pet safety. It must never imply that an open flame should be left unattended.

### 7.4 Vehicle Puja safety

Lemons under wheels, fire/camphor, coconut placement and the immediate first drive can create driving and fire hazards. The ritual area must be cleared and a safety inspection completed before movement.

### 7.5 Toxic plants and Abhisheka liquid

Datura and Aak can be toxic. The app must not imply that offerings or mixed Abhisheka liquids containing unsafe substances should be consumed. Skin, eye, child and pet contact warnings are required.

### 7.6 Environmental disposal

Hair, flowers, barley, thread, ash and other ritual materials should not automatically be instructed to be thrown into flowing water. Provide lawful local disposal guidance and biodegradable alternatives.

---

## 8. Tradition-dependent points — do not mark these as automatic errors

The following can differ among valid traditions and require a named profile before the app selects a form:

- fourth Achamana name: `हृषीकेश` versus `गोविन्द`
- Lakshmi/Ganesh right-left placement
- 21 Durva bundles, blades or pairs
- 11/21 Modaks or lamps
- necessity and rules of Akhand Jyoti
- Karwa count, seven rotations, Sargi and Bayna procedure
- Mundan in the first, third or fifth year and whether a Shikha is retained
- Grih Pravesh entry order, coconut and milk boiling customs
- Shraddha performer, Pinda composition, Tarpana order and substitutions
- Bilva orientation and whether Abhisheka water is received
- Upanayan age, Yajnopavita count and Matribhojana

The existing `हृषीकेशाय नमः` North Indian simplified Achamana is institutionally attested and is not a confirmed error merely because another tradition uses `गोविन्दाय नमः`:

- [MSRVVP Smarta Yajna textbook](https://msrvvp.ac.in/skill_course/textbook/Smarta_Yajna_Kanishtha_Sahayak_27_06_24.pdf)
- [Uttarakhand Open University ritual course](https://uou.ac.in/sites/default/files/slm/BASL%28N%29-121.pdf)

The multiplicity of Grihya Sutras also demonstrates that there is no single universal domestic procedure independent of Vedic branch and tradition:

- [Government Vedic Heritage Portal — Kalpa/Grihya Sutra overview](https://vedicheritage.gov.in/hi/vedangas/kalpa/)
- [Government Vedic Heritage Portal — Ritual classification](https://vedicheritage.gov.in/hi/rituals/)

---

## 9. Per-Puja launch assessment

This table evaluates the **current content**, not the permanent religious status of a Puja.

| Puja | Current recommended scope | Main blockers before release |
|---|---|---|
| Nitya Puja | First candidate for self-guided source-reviewed release | verify common texts, IAST, meaning, time and procedure sources |
| Ganesh Puja | Candidate for simplified self-guided release | wrong Vedic citation, Durva/Modak contradictions, Panchamrita materials |
| Lakshmi Puja | Named regional household version after audit | देवी Kshama mismatch, claims, missing core slots, fire safety |
| Kalash/Navratri | Named regional simplified version after audit | main Devi invocation/content gaps, fast contradiction, Akhand Jyoti safety |
| Karwa Chauth | Regional folk-vrata guide after audit | Nirjala/Achamana conflict, absent Katha/core content, medical advice |
| Satyanarayan | Blocked until completed | Katha absent, Shodashopachara incomplete, edition/license required |
| Vahan Puja | Contemporary customary blessing after safety corrections | no ancient vehicle-specific prescription, lemon/fire/driving safety, no protection guarantee |
| Rudrabhishek | Rename to simple Shiva Abhisheka until complete | Rudra recitation absent, toxic offering/consumption issues, Vedic audio requirement |
| Grih Pravesh | Simple non-fire blessing only; full rite expert-assisted | Vastu/Lakshmi/Havan core gaps and strong tradition variance |
| Mundan | Preparation, meaning and safety information only | child razor safety and core Vedic/samskara steps absent |
| Shraddha/Tarpana | Simple Pitri remembrance/Jalanjali only | core mantra slots absent; performer, kinship and procedure are tradition-dependent |
| Upanayan | Education/preparation only; Acharya-assisted ceremony | current content itself says an Acharya is essential; cannot be full DIY |

Relevant research references for the restricted/variant nature of samskaras include:

- [IGNCA — Srauta and Grihya Sutras](https://ignca.gov.in/Asi_data/17904.pdf)
- [Grihya Sutras, Sacred Books of the East volume 29](https://archive.sacred-texts.com/hin/sbe29/index.htm)
- [Grihya Sutras, Sacred Books of the East volume 30](https://archive.sacred-texts.com/hin/sbe30/index.htm)

These older public-domain translations are useful discovery references, not a substitute for choosing and documenting a current edition/tradition.

---

## 10. What research/AI can and cannot verify

### Can verify with evidence

- whether the displayed Sanskrit matches a named edition/recension
- whether a citation points to the correct work, chapter and verse
- Devanagari transcription consistency
- IAST transliteration derived from the canonical text
- literal Hindi meaning and whether it overclaims
- whether a mantra’s deity/gender/context matches the selected step
- whether the same canonical mantra is reused consistently
- internal conflicts between steps, materials, FAQs and durations
- whether a procedure is supported by a named practical/textual source
- whether a claim is textual, institutional, regional or folkloric
- whether source and media licensing is documented
- obvious medical, fire, toxic, driving and environmental risks

### Cannot honestly certify alone

- that one procedure is universally correct for all Hindu traditions
- religious sanction on behalf of every Sampradaya, Veda-shakha or family tradition
- initiation or authorization where a Guru/Acharya is part of the rite
- trained Vedic pronunciation merely from unaccented text or synthetic speech
- promised supernatural, medical, prosperity or accident-prevention outcomes
- “Pandit-approved” status without an actual identified reviewer

If no Pandit is available, a Sanskrit/Karmakand academic, Vedic studies institution or tradition-specific practitioner can perform a limited remote evidence review. The UI must truthfully identify the reviewer’s actual role.

---

## 11. Source hierarchy to use

Use sources in this order:

1. Exact primary text with recension/Shakha/section.
2. Named critical or printed edition with editor, year, page/verse.
3. Institutional digitization or manuscript catalogue.
4. Peer-reviewed ritual study or ethnography.
5. Government/university practical Prayoga manual.
6. Temple/Matha/community guide only as evidence for that named current tradition.
7. Blog, YouTube, Quora, SEO page or AI output only as a discovery lead, never final authority.

Preferred research starting points:

- [IGNCA Government Vedic Heritage Portal](https://vedicheritage.gov.in/)
- [MSRVVP](https://msrvvp.ac.in/)
- [Uttarakhand Open University](https://uou.ac.in/)
- [GRETIL university repository](https://gretil.sub.uni-goettingen.de/)
- [Puja: A Study in Smarta Ritual — University of Vienna](https://sdn-istb.univie.ac.at/publications/pdnrl-15-buehnemann/)

Repository presence alone is not proof of correctness. A repository file may be unproofread, may omit Vedic accents, or may have restrictions on reuse.

---

## 12. Audio and Vāgdhenu policy

The user-proposed [Vāgdhenu](https://prathosh.in/vagdhenu/) system may be evaluated for non-Vedic Sanskrit voice guidance, but it must not be treated as authoritative Vedic chanting.

Its [model card](https://huggingface.co/prathoshap/vagdhenu) states that Vedic svara is not supported.

### Allowed only after review

- non-Vedic Shloka or prose
- exact verified input text
- human listening/pronunciation QA
- visible label: `AI-generated Sanskrit voice`
- model/data/license attribution recorded

### Do not use it for

- Sri Rudram/Rudrashtadhyayi
- accented Vedic Ganapati text
- Vedic Sri Sukta or other svara-dependent recitation
- any audio labelled “verified Vedic chanting”

For Vedic audio, use a trained human reciter or a properly licensed institutional recording with Shakha and recitation style identified.

---

## 13. Copyright and licensing

Ancient Sanskrit base text may be in the public domain, but a modern transcription, critical apparatus, transliteration, translation, recording and website presentation may have separate copyright.

- [Vedic Heritage Portal copyright policy](https://vedicheritage.gov.in/copyright-policy/) requires attention to reproduction permission.
- [SanskritDocuments FAQ](https://sanskritdocuments.org/faq/) does not automatically authorize commercial/promotional copying.
- [TITUS usage terms](https://titus.uni-frankfurt.de/texte/textex.htm) restrict commercial use.
- [Indian Copyright Act — Section 22](https://copyright.gov.in/Copyright_Act_1957/chapter_v.html)

### Safest content-production approach

- independently transcribe from a legally usable/public-domain base edition
- record the exact edition and page/verse
- write original Hindi meanings
- mechanically derive IAST and human-proofread it
- obtain explicit audio permission or create a new licensed recording
- retain attribution/license evidence in the content manifest

---

## 14. Required content manifest

Each canonical mantra/procedure claim should eventually record:

```text
content_id
tradition_profile
scope: self_guided | simplified | expert_required
work
recension_or_shakha
section_page_verse
edition_editor_year
public_url
license
canonical_devanagari
vedic_svara_present
iast
easy_hindi_pronunciation (optional and clearly labelled)
hindi_meaning_author
ritual_action_source
variant_note
safety_note
verified_by
reviewer_role
verified_at
confidence
```

The present non-empty source-string check is not sufficient verification. Source-review status must depend on structured evidence, not merely the existence of text such as a book/blog name.

---

## 15. What must be done

1. Freeze authoritative/verified status until the evidence ledger is complete.
2. Choose one declared profile, initially recommended as `उत्तर भारतीय सरल स्मार्त/पौराणिक गृहस्थ पद्धति`.
3. Create canonical records for the eight unique Sanskrit texts before editing 55 duplicated instances.
4. Fix the wrong Ganapati citation and independently rewrite its literal meaning.
5. Resolve Sankalp grammar and user-form handling before removing its warning.
6. Replace ASCII-only pronunciation data with verified IAST; keep easy Roman only as a separately labelled aid.
7. Give every procedural action, strong claim and FAQ a claim-level source or a clear tradition/folk label.
8. Complete or rename incomplete features: Satyanarayan Katha, Shodashopachara and Rudrabhishek.
9. Resolve all step/material/FAQ/time contradictions.
10. Add medical, fire, child, toxic, driving and environmental safety gates.
11. Separate self-guided, simplified and expert-required Puja modes.
12. Clear commercial-use rights for every modern text, meaning and audio asset.
13. Test generated metrics rather than manually maintaining tracker totals.
14. Show expandable source details in the UI before displaying a source-reviewed badge.
15. Preserve a change log showing old text, new text, reason, source and reviewer.

---

## 16. What must not be done

1. Do not mark all existing `jaanch.paas` or mantra statuses as passed in bulk.
2. Do not invent missing mantra, Katha, ritual or Sanskrit grammar.
3. Do not use blogs, Quora, Web portals or AI output as final religious authority.
4. Do not silently combine fragments from different sources into a “canonical mantra”.
5. Do not call ASCII Roman text proper Sanskrit transliteration or use it for authoritative audio.
6. Do not use non-Vedic TTS for svara-dependent Vedic chanting.
7. Do not copy modern translations, transcriptions or recordings without checking rights.
8. Do not present regional customs as universal Shastra requirements.
9. Do not promise long life, prosperity, evil-eye removal, accident protection or guaranteed ritual results.
10. Do not make Upanayan, full Shraddha/Pindadaan, child Mundan, Havan-based Grih Pravesh or full Rudrabhishek unrestricted DIY flows.
11. Do not instruct an unattended open flame, unsafe fasting, untrained razor use, toxic consumption or unsafe vehicle movement.
12. Do not remove the unverified warning simply because the UI looks incomplete.
13. Do not change production content until this report and the selected tradition profile are independently reviewed.

---

## 17. Recommended implementation phases after independent review

### Phase 0 — Decision freeze

- Obtain review of this document.
- Select the exact launch claim and tradition profile.
- Do not alter verification flags.

### Phase 1 — Evidence ledger and canonical texts

- Inventory eight unique Sanskrit texts.
- Record exact sources, licenses, Devanagari, IAST and original meanings.
- Separate Vedic and non-Vedic audio classes.

### Phase 2 — P0 factual and safety corrections

- Correct the Ganapati citation.
- Repair Sankalp grammar design.
- Resolve deity/gender mismatches.
- Resolve Nirjala/Achamana conflict.
- Fix materials, durations and internal contradictions.
- Add safety restrictions.

### Phase 3 — Per-Puja procedure audit

- Review all 139 actions and 58 FAQs.
- Use two credible references where a strong procedure claim is retained.
- Record tradition variants rather than erasing them.

### Phase 4 — Scope and content completion

- Complete or rename Satyanarayan and Rudrabhishek.
- Restrict expert-dependent samskaras.
- Define truthful self-guided/simplified/expert-required modes.

### Phase 5 — UI and data-model transparency

- Add structured source details and status badges.
- Replace “Pandit verified” with truthful evidence-based wording.
- Show variant and safety notes at the relevant step.

### Phase 6 — Audio

- Human Vedic recording for svara-dependent text.
- Human-QA synthetic audio only for permitted non-Vedic content.
- Record license, voice type and reviewer.

### Phase 7 — Release gate

Release a Puja as source-reviewed only when all applicable gates pass:

```text
TEXT_VERIFIED
MEANING_VERIFIED
PROCEDURE_SOURCE_VERIFIED
TRADITION_SCOPED
INTERNAL_CONSISTENCY_PASSED
SAFETY_REVIEWED
LICENSE_CLEARED
AUDIO_HUMAN_VERIFIED (when audio exists)
```

---

## 18. Files likely to change later — not changed by this audit

After approval, implementation will probably touch:

- `app/assets/vidhi/*.json`
- `app/lib/vidhi/vidhi.dart`
- `engine/lib/src/sankalp.dart`
- related content/schema/Sankalp tests
- verification/source UI widgets
- `docs/06_CONTENT_TRACKER.md`
- `docs/08_VERIFICATION.md`
- `docs/11_SANKALP_VYAKARAN.md`

This list is advisory. No file above was modified as part of the research audit.

---

## 19. Questions for the Opus 5 independent review

The next reviewer should answer these explicitly:

1. Do the confirmed-error classifications have sufficient evidence?
2. Is any “confirmed error” actually a valid tradition variant that should be reclassified?
3. Is `उत्तर भारतीय सरल स्मार्त/पौराणिक गृहस्थ पद्धति` a sufficiently precise initial scope, or must it be narrower?
4. Is the proposed self-guided versus expert-required division responsible?
5. Are any safety blockers missing?
6. Is the source hierarchy appropriate for a commercial mobile application?
7. Are the proposed verification gates sufficient to support a `स्रोत-समीक्षित` badge?
8. Which four Puja flows should be verified first for the smallest safe launch?
9. Should the current Rudrabhishek be renamed immediately or remain unavailable until complete?
10. What exact evidence would be required before Sankalp can lose its review warning?

### Suggested reviewer response format

```text
OVERALL DECISION: APPROVE PLAN | APPROVE WITH CHANGES | REJECT

CONFIRMED FINDINGS ACCEPTED:
- ...

FINDINGS TO RECLASSIFY:
- finding
- reason
- stronger source

MISSING RISKS/ERRORS:
- ...

RECOMMENDED LAUNCH SCOPE:
- ...

MANDATORY CHANGES BEFORE IMPLEMENTATION:
1. ...
2. ...

OPTIONAL IMPROVEMENTS:
- ...
```

---

## 20. Final audit conclusion

The application has a useful household guidance structure, but the current religious content is not yet ready for a blanket authenticity claim. Its largest problems are not that every action is necessarily wrong; they are incorrect attribution, incomplete central content, reused drafts, weak provenance, internal contradictions, unsafe edge cases and failure to distinguish textual rule from regional custom.

The responsible path is:

> **Evidence ledger → canonical text verification → factual/safety corrections → tradition-scoped procedure audit → limited transparent launch.**

Until those gates pass, keep current verification warnings and do not represent the application as an authoritative replacement for a Pandit or Acharya.
