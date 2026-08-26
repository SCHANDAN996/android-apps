# 14 — Puja Library Expansion Plan

**Status:** Planning only. No new ritual text, mantra, procedure, FAQ or verification badge is approved by this document.  
**Scope:** Vidhivat should launch additions as clearly labelled household guides, never as a universal substitute for a Pandit or Acharya.

This plan follows the content audit in `docs/13_CONTENT_VERIFICATION_AUDIT.md`. The current audit fixes and source-evidence workflow remain a release dependency; adding more Puja names must not multiply unverified content.

---

## Product principle

Every new entry must declare one of these scopes before its content is written:

| Scope | Meaning in the app |
|---|---|
| `self_guided` | Simple household guidance can be followed independently after sources, safety and wording are verified. |
| `regional_profile` | A named regional/family tradition is shown; the UI must say that variants exist. |
| `preparation_only` | Meaning, preparation and safety information; the app must not present it as a complete DIY rite. |
| `expert_assisted` | Requires a Pandit, Acharya or trained practitioner for the central ceremony. |

Initial content profile for the library: **उत्तर भारतीय सरल गृहस्थ/स्मार्त-पौराणिक पद्धति**. This label must appear wherever a user could otherwise assume a universal procedure.

---

## ✅ Phase A — हो गया (26 अगस्त 2026)

छहों पूजाएँ बन चुकी हैं और `assets/vidhi/` में हैं। इन्हें
`planned_puja_catalog.dart` से हटा दिया गया है, और एक जाँच अब पहरा देती
है कि कोई id दोनों जगह न रहे।

| पूजा | सामग्री · कदम · समय | मंत्र | scope |
|---|---|---|---|
| हनुमान पूजा | 25 · 12 · 58 मि | 6 / 7 | `self_guided` |
| सूर्य अर्घ्य | 6 · 5 · 15 मि | 1 / 2 | `self_guided` |
| तुलसी पूजा | 11 · 7 · 19 मि | 3 / 4 | `self_guided` |
| सरस्वती पूजा | 22 · 11 · 50 मि | 4 / 7 | `self_guided` |
| राम पूजा | 22 · 11 · 58 मि | 5 / 7 | `self_guided` |
| कृष्ण पूजा | 24 · 12 · 70 मि | 5 / 7 | `self_guided` |

**जो इस plan ने माँगा और मिला:** declared scope · tradition profile
(उत्तर भारतीय सरल गृहस्थ पद्धति) · हर मंत्र पर स्रोत और भरोसे का दर्जा ·
required/optional सामग्री · safety notes (सूरज, जल, दीपक, सिंदूर-तेल,
दूध का प्रसाद) · कोई फल/नतीजे का वादा नहीं · कंटेंट और widget जाँचें ·
artwork पहले से मौजूद।

**जो जान-बूझकर नहीं भरा:** सरस्वती का ध्यान-श्लोक, आदित्यहृदय,
राम-गायत्री, हर आरती, और देवी वाली क्षमा प्रार्थना — हर एक पर वजह लिखी है।

**अभी बाक़ी:** ऑडियो (0/126), IAST, पंडित जी की जाँच (0/18)।

---

## Phase A — First six recommended additions

These are the best next candidates after the P0 content fixes. They are familiar, useful in ordinary homes and can be designed as simple guides rather than high-risk samskaras.

| Priority | Puja / guide | Suggested scope | Why it belongs in Vidhivat | Required content before implementation |
|---:|---|---|---|---|
| 1 | हनुमान पूजा | `self_guided` | High everyday/Tuesday/Saturday interest; simple devotional journey. | Named household tradition, exact prayer/mantra sources, no promised protection claims. |
| 2 | सूर्य अर्घ्य | `self_guided` | Short morning practice; useful daily engagement. | Safe water/sun-exposure guidance, regional wording, verified text or text-free guided action. |
| 3 | तुलसी पूजा | `self_guided` | Small daily/seasonal home ritual; low material burden. | Household variant, plant-care/safety note, source-labelled action steps. |
| 4 | सरस्वती पूजा | `self_guided` | Study/exam and Vasant Panchami relevance. | A named form, no guarantee about marks/results, verified offerings/texts. |
| 5 | राम पूजा | `self_guided` | General devotional use and Ram Navami collection. | Selected tradition, exact source evidence for any mantra and meaning. |
| 6 | कृष्ण पूजा | `self_guided` | Janmashtami and general household devotion. | Selected form, clear festival/non-festival variants, no invented childhood/Janmashtami ritual. |

### Phase A common screen template

Each guide should use the existing journey:

```text
Overview → material checklist → what/why/how step → verified text (where present) → progress → completion → source details
```

Each addition also needs:

- a transparent artwork asset with a consistent card scale
- material list with required versus optional status
- source/tradition/variant note on every strong claim
- safety/medical/fire/environmental note where relevant
- no audio until the text and pronunciation class are verified
- content and widget tests

---

## Phase B — Festival collection

Implement only after the Phase A template and evidence ledger are stable.

| Puja / guide | Suggested scope | Important constraint |
|---|---|---|
| धनतेरस पूजा | `regional_profile` | Present as a Dipavali household custom, not a wealth guarantee. |
| गोवर्धन पूजा / अन्नकूट | `regional_profile` | Food safety, ingredient alternatives and local tradition note. |
| भाई दूज पूजा | `regional_profile` | Different regions use different names and steps. |
| रक्षाबंधन पूजा | `regional_profile` | Keep the simple household ritual distinct from any universal claim. |
| मकर संक्रांति पूजा | `regional_profile` | State the regional/seasonal variation clearly. |
| वसंत पंचमी collection | `regional_profile` | May link to Saraswati Puja but should not duplicate its core guide. |
| राम नवमी collection | `regional_profile` | May link to Ram Puja with a festival-specific overview. |
| जन्माष्टमी collection | `regional_profile` | May link to Krishna Puja with a festival-specific overview. |

---

## Phase C — Regional guides

These should not appear without a selected regional profile and carefully scoped language.

| Puja / vrata | Proposed profile needed | Key caution |
|---|---|---|
| हरितालिका तीज | North Indian regional profile | Fasting health advice and local variants. |
| वट सावित्री | North/West Indian profile | Avoid claims of guaranteed longevity; add fasting safety. |
| छठ पूजा | Bihar/Purvanchal profile | Water-body, sun exposure, fasting and environmental safety; no generic DIY launch. |
| वरलक्ष्मी व्रत | South Indian profile | Do not merge with North Indian Lakshmi Puja. |
| करवा चौथ expanded guide | Punjabi/North Indian profile | First resolve current Nirjala/Achamana contradiction and medical advice. |
| दुर्गा अष्टमी / कन्या पूजन | Selected regional/household profile | Respectful, consent-based, food/allergy and family-variant guidance. |

---

## Keep restricted or preparation-only

The following should not be added as unrestricted complete DIY Puja flows:

| Rite | Recommended app mode | Reason |
|---|---|---|
| पूर्ण हवन | `expert_assisted` | Fire, mantra placement and procedural risk. |
| पूर्ण रुद्राभिषेक | `expert_assisted` | Vedic recitation/recension/pronunciation requirements. |
| श्राद्ध/पिंडदान | `preparation_only` | Kinship, performer, sequence and regional rules vary substantially. |
| उपनयन | `preparation_only` / `expert_assisted` | Acharya is central to the rite. |
| मुंडन | `preparation_only` | Child razor and hygiene safety. |
| विवाह संस्कार | `preparation_only` / `expert_assisted` | Major samskara with family/tradition/legal complexity. |
| हवनयुक्त गृह प्रवेश | `expert_assisted` | Fire/Vastu/ritual variation and missing current core content. |

---

## Mandatory evidence record for every new Puja

Before an entry moves from plan to implementation, create a record containing:

```text
puja_id
display_name
tradition_profile
scope
primary_source_or_institutional_manual
edition_or_url
selected_variant
mantra_text_source
meaning_author
ritual_action_source
materials_source
safety_notes
copyright_or_license_status
review_status
```

Do not mark a guide as source-reviewed until text, procedure, safety and licensing have each passed separately.

---

## Recommended development order

1. ~~Complete current P0 content audit corrections and source ledger.~~ ✅ 26 अग — देखो D-035, D-036, D-037
2. ~~Build the Phase A content manifest for all six candidates.~~ ✅
3. ~~Implement **Hanuman Puja** as the first full template.~~ ✅
4. ~~Reuse the template for Surya Arghya and Tulsi Puja.~~ ✅
5. ~~Add Saraswati, Ram and Krishna with their own artwork.~~ ✅
6. Add festival collections as curated entry points that link to the canonical guide rather than duplicating mantra text.
7. Start regional collection only after tradition-profile UI and source-expansion panels are complete.

---

## What not to do

- Do not create ritual text from AI memory and mark it authoritative.
- Do not use one Puja’s steps as a template for a different deity/festival without source review.
- Do not show one regional custom as universal Hindu practice.
- Do not add Vedic audio through unverified TTS.
- Do not make prosperity, health, long-life, protection or exam-success guarantees.
- Do not launch high-risk samskaras as priest-free completion flows.
- Do not add an image asset without checking transparency, consistent card composition and APK-size impact.

---

## Current actionable choice

After review of this plan, the recommended first implementation ticket is:

> **Hanuman Puja — उत्तर भारतीय सरल गृहस्थ पद्धति — source/evidence manifest first, then UI and guided flow.**

No new Puja content is implemented by this document alone.
