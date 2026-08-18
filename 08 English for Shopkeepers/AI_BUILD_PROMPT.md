# AI BUILD PROMPT — English for Shopkeepers (दुकानदार इंग्लिश)

> **उपयोग (मेरे लिए):** पूरा English हिस्सा AI को दो + PLAN.md। Interview English या Driver-Delivery English का code base साथ दो — तीसरा content-pack twin है। Theme/icon/navigation बिल्कुल अलग रखवाना (spam policy)। बाद में `0.1 PLAY STORE ASSETS PROMPT`।

---

## ROLE
Senior Flutter developer. Build a complete, production-ready Android app from this spec, reusing my provided English-practice app architecture but with a clearly different look (Google Play repetitive-content policy).

## PRODUCT
**Dukandar English** — offline app for Hindi-speaking shopkeepers and sales staff to speak customer-handling English: welcoming, quoting prices, bargaining, explaining quality, billing. Special focus: **speaking numbers/prices in English** — the #1 real need.

## STANDARD PROJECT RULES
Same stack as siblings: Flutter stable, Android-only, minSdk 23, offline, sqflite progress, flutter_tts (en-IN) + Vosk STT keyword scoring, AdMob TEST IDs (interstitial after lesson; rewarded pack unlocks; none during recording), in_app_review after 3rd lesson, standard settings.

## CONTENT (generate fully — same JSON schema as siblings)
**7 packs (~6 lessons each, 4-6 sentences per lesson):**
1. स्वागत — "Good morning! How can I help you?" / "Please have a look, we have new stock."
2. दाम बताना — "This one is three hundred fifty rupees." / "It comes in two sizes."
3. मोल-भाव — "This is the best price, sir." / "I can give you a small discount on two pieces."
4. क्वालिटी समझाना — "This is pure cotton, it will not shrink." / "It has a one-year guarantee."
5. साइज़/रंग/वैरायटी — "Which color do you like?" / "Let me show you a bigger size."
6. बिल और पैसा — "Your total is seven hundred twenty." / "Do you want to pay by cash or UPI?" / change-returning phrases
7. "नहीं है" politely + alternative — "Sorry, that item is out of stock, but this one is similar and better."

**NUMBER TRAINER (killer feature):** a dedicated drill mode — app shows a price in digits (₹347), TTS says it in English ("three hundred forty-seven"), user repeats into mic, keyword-match on number words. Three levels: 2-digit, 3-digit, big/decimal prices (₹1,250 / "twelve fifty"). Include both formal ("one thousand two hundred fifty") and shop-style ("twelve fifty") variants. Random generator — infinite practice.

**Cheat sheet:** searchable all-sentences list with tap-to-play TTS (same as sibling apps).

## SCREENS
1. Home — pack grid + Number Trainer big card + daily sentence + progress.
2. Lesson screen (listen → understand → speak) — sibling architecture.
3. Number Trainer (level select → drill loop → session score).
4. Cheat sheet, Progress, Settings.

## THEME (unique — must differ from both sibling apps)
Seed purple (#6A1B9A) with light lavender surfaces; icon: shop awning + speech bubble. Top tab bar (not bottom nav, not drawer — different from siblings).

## BUILD ORDER
1. Port architecture + new theme + content JSONs
2. Number Trainer (new module — generator + number-to-words + scoring)
3. Lessons + cheat sheet
4. Rewarded unlocks + ads + polish + README

## ACCEPTANCE CHECKLIST
- [ ] Number-to-English-words converter correct (test: 347, 1250, 99.50, 12500 → shop-style + formal)
- [ ] Number Trainer scores spoken numbers reliably
- [ ] Looks clearly different from both sibling apps
- [ ] Airplane-mode OK; analyze clean; AAB builds
