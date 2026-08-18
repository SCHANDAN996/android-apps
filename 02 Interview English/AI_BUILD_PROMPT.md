# AI BUILD PROMPT — Interview English (बोलकर Practice)

> **उपयोग (मेरे लिए):** पूरा English हिस्सा किसी भी AI को दो + PLAN.md। ज़रूरी: मेरे SpeakEasy app का voice pipeline code भी साथ दो (STT/TTS वाला हिस्सा) — spec में Option A उसी के reuse की है। App बनने के बाद root की `0.1 PLAY STORE ASSETS PROMPT` file use करो।

---

## ROLE
You are a senior Flutter developer. Build a complete, production-ready Android app from this spec.

## PRODUCT
**Interview English** — an offline app for Hindi-speaking job seekers in India to practice English job-interview answers BY SPEAKING. Users listen to model answers (TTS), speak their answer (STT), and get a pronunciation/fluency score. UI is bilingual: instructions in Hindi (Devanagari), learning content in English with Hindi meanings.

## STANDARD PROJECT RULES
- Flutter latest stable, Android-only, minSdk 23, Material 3, size target < 40 MB (STT model included).
- Offline-first: all lessons bundled as JSON assets; voice works offline.
- State: Riverpod/Provider. Persistence: shared_preferences + a small local DB (sqflite) for progress.
- AdMob: TEST IDs in code, real IDs via config file. Interstitial ONLY after completing a mock-interview round; rewarded ad to unlock premium packs; small banner on category list only. Never interrupt a speaking exercise with an ad.
- in_app_review after 3rd completed lesson.
- Settings: TTS speed (slow/normal), language of instructions (Hindi default/English), reset progress, privacy policy + more-apps placeholders.
- Deliverables: full project + README + content JSON files.

## VOICE PIPELINE
- **Option A (preferred):** I will provide my existing SpeakEasy app's voice code — reuse its offline STT + TTS + scoring modules as-is.
- **Option B (if A unavailable):** TTS via `flutter_tts` (en-IN voice, speed 0.4/0.5 toggle). STT via `vosk_flutter` with the small English model (~40 MB) bundled or downloaded on first run. Scoring: compare recognized words to target answer using word-overlap: score = matchedKeywords/totalKeywords × 100, where each question's JSON lists 5-8 keywords. Show score bands: 80+ "बहुत बढ़िया", 50-79 "अच्छा, फिर बोलें", <50 "सुनिए और दोहराइए".

## CONTENT (the app IS this content — generate it fully)
Create `assets/content/` JSON files. Schema per question:
```json
{
  "id": "fresher_01",
  "category": "fresher",
  "question": "Tell me about yourself.",
  "question_hi": "अपने बारे में बताइए।",
  "tips_hi": "2 लाइन पढ़ाई, 1 लाइन skill, 1 लाइन goal — रटो मत, अपना बनाओ।",
  "answers": [
    {"level": "easy", "text": "I am Rahul from Varanasi. I have completed B.Com this year. I am good at MS Excel and I learn things quickly. I want to start my career in your company and grow with hard work."},
    {"level": "medium", "text": "..."}
  ],
  "keywords": ["name", "completed", "skill", "career", "hard work"],
  "important_words": [{"word": "completed", "hi": "पूरा किया"}, {"word": "career", "hi": "करियर"}]
}
```
**Generate 60 questions total** across categories: `fresher` (15), `hr_common` (15), `sales_job` (8), `bank_exam` (8), `teacher` (7), `it_support` (7). Every question: 2 answers (easy = 40-60 words simple English; medium = 70-90 words), Hindi tips, keywords, 3-5 important words with Hindi meaning. English must be simple, Indian-context, grammatically correct. Categories `sales_job` onward are "premium packs" (unlocked by one rewarded ad each, permanently).

## SCREENS
1. **Home** — "आज का सवाल" card (rotates daily) + category grid (with lock icon on premium packs) + progress ring (questions practiced).
2. **Question list** — per category, tick marks on practiced ones.
3. **Practice screen (core)** — top: question (EN + HI). Sections: (a) सुनिए — play model answer TTS with slow/normal buttons and highlighted text; (b) समझिए — tips + important words; (c) बोलिए — big mic button, records, shows recognized text + score + which keywords were hit/missed; retry button. Bottom: अगला सवाल.
4. **Mock Interview** — picks 5 random practiced-category questions, mic-only (no model answer shown first), final score screen with per-question breakdown, then interstitial, then share-score card.
5. **Progress** — streak days, total practiced, average score, weakest category.

## THEME (unique)
Seed color indigo (#283593), clean professional look (tie/briefcase motif in icon), NOT similar to my SpeakEasy app's look. Rounded cards, big mic FAB.

## EDGE CASES
- Mic permission denied → explain in Hindi, allow listen-only mode.
- STT model missing/failed → listen+read mode with graceful message.
- TTS voice unavailable → fall back to default English voice.

## BUILD ORDER
1. Skeleton + theme + content JSON loading + home/category/list screens
2. Practice screen with TTS (listen flow)
3. STT + scoring (speak flow)
4. Mock interview + progress + streak
5. Ads + rewarded unlock + review prompt
6. Polish + README

## ACCEPTANCE CHECKLIST
- [ ] All 60 questions load; every answer plays via TTS; mic scoring returns sensible scores
- [ ] Premium pack unlock via rewarded ad persists
- [ ] Works fully offline in airplane mode (after any model download)
- [ ] No ad ever appears during recording
- [ ] flutter analyze clean; release AAB builds
