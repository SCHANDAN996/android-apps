# AI BUILD PROMPT — English for Drivers & Delivery (ड्राइवर-डिलीवरी इंग्लिश)

> **उपयोग (मेरे लिए):** पूरा English हिस्सा AI को दो + PLAN.md। अगर Interview English app बन चुका है तो उसका पूरा code base दो — यह app उसी architecture का content-pack twin है (सिर्फ़ content + theme बदलेगा)। बाद में `0.1 PLAY STORE ASSETS PROMPT`।

---

## ROLE
Senior Flutter developer. Build a complete, production-ready Android app from this spec. If my Interview English app code is provided, reuse its architecture (content JSON loader, practice screen, voice pipeline) but the UI theme, icon, and navigation MUST look clearly different (Google Play repetitive-content policy).

## PRODUCT
**Driver-Delivery English** — offline app for Hindi-speaking cab drivers (Ola/Uber/Rapido) and delivery partners (Zomato/Swiggy/Amazon/Blinkit) to learn and PRACTICE the exact English sentences their work needs. Listening comprehension is as important as speaking here.

## STANDARD PROJECT RULES
Same as Interview English: Flutter stable, Android-only, minSdk 23, offline-first, sqflite progress, TTS (`flutter_tts` en-IN) + offline STT (Vosk small EN) with keyword-match scoring, AdMob TEST IDs (interstitial after lesson complete; rewarded unlocks packs; no ads during recording), in_app_review after 3rd lesson, standard settings.

## CONTENT (generate fully — assets/content/*.json)
Same schema as Interview English but situation-based. Two tracks with packs:

**Driver track (5 packs, ~8 lessons each):**
1. Pickup call: "Hello sir, I am your driver. I have reached the pickup point." / "Please share your exact location."
2. Navigation talk: "Should I take the highway?" / "There is heavy traffic, it may take ten more minutes."
3. Ride problems: late, wrong pin, toll, AC requests, luggage help
4. Payment & rating: "The payment is pending on the app." / polite rating request
5. **Listening pack (rewarded):** common passenger sentences → user picks Hindi meaning (MCQ) — "Can you turn down the music?", "Take a left after the signal."

**Delivery track (5 packs):**
1. Reaching customer: "I am at your gate." / "Please share the OTP."
2. Address problems: "The location is showing somewhere else. Please guide me."
3. Order issues: item missing, leave-at-door, payment pending, return pickup
4. Polite phrases: greeting, apology for delay, thanks
5. **Listening pack (rewarded):** customer sentences MCQ.

Each lesson: 4-6 sentences; every sentence has: English, Hindi meaning, "कब बोलें" note, TTS play (slow/normal), speak-practice with keyword scoring. Total ≈ 80 lessons' worth of sentences (~350 sentences). Simple, polite, Indian-context English — generate all of it.

**Cheat Sheet feature (killer feature):** a searchable offline list of ALL sentences grouped by situation, with big text and instant TTS play — designed to be glanced at DURING work. Accessible from home in one tap. This screen must load instantly.

## SCREENS
1. Home — choose track (Driver 🚗 / Delivery 📦 style, but use Material icons not emoji), daily sentence card, cheat-sheet quick button, progress.
2. Pack list → lesson screen (listen → understand → speak, same flow as Interview English).
3. Listening quiz screen (audio plays → 3 Hindi options).
4. Cheat sheet (search + category chips + tap-to-play).
5. Progress + settings.

## THEME (unique — must differ from Interview English)
Seed amber/dark-yellow (#FF8F00) with dark navy accents; icon: steering wheel + chat bubble. Bottom navigation instead of Interview English's drawer/tab style.

## BUILD ORDER
1. Reuse/port architecture + new theme + content JSONs
2. Cheat sheet (fast + searchable)
3. Lessons + listening quiz
4. Rewarded unlocks + ads + review + polish + README

## ACCEPTANCE CHECKLIST
- [ ] All content loads; cheat sheet search works offline instantly
- [ ] Listening MCQs play audio without showing text first
- [ ] Looks clearly different from Interview English side-by-side
- [ ] Airplane-mode OK; analyze clean; AAB builds
