# 02 — Interview English (Priority: HIGH)

## Ek line mein
Naukri ke interview ke sawal-jawab **bolkar** practice karo — offline voice practice, Hindi explanation ke saath.

## Target User
- Fresher graduates, private job seekers (sales, BPO, retail, office boy se manager tak)
- Sarkari interview (bank, SSC descriptive) wale bhi
- 18-30 saal, tier 2/3, Hindi medium background

## Problem
Interview mein English bolna sabse bada darr hai. YouTube par videos hain lekin **practice** ka koi tareeka nahi — bolne ki practice chahiye, sunne ki nahi. Koi offline app nahi jo mic se sunkar batchaye ki sahi bola ya nahi.

## MVP Features (v1)
1. **Top 50 interview questions** — "Tell me about yourself", "Why should we hire you", etc.
   - Har question ka: Hindi meaning, 2-3 sample answers (easy/medium level), important words
2. **Bol kar practice** — SpeakEasy ka voice pipeline: user answer bolta hai, app pronunciation/fluency check karta hai
3. **Sun kar seekho** — TTS se sample answer sunao (slow/normal speed)
4. **Mock Interview Mode** — 5 random questions ka round, end mein score
5. **Categories** — Fresher, Sales job, Bank, Teacher, IT support
6. **Daily 1 question** notification

## Baad ke Features (v2+)
- Self-introduction builder (user apni detail bhare → ready introduction banke mile)
- HR questions vs technical basics
- Group Discussion phrases pack

## Screens
1. Home — categories + "Aaj ka Question" card
2. Question list screen
3. Practice screen (SpeakEasy lesson screen jaisa — sun, bol, score)
4. Mock interview screen
5. Progress screen

## Engine Reuse
SpeakEasy ka poora engine:
- Voice pipeline (STT scoring, TTS) — 90% reuse
- Lesson/practice screen UI — 80% reuse
- Sirf content (questions + answers JSON) naya hai

## Monetization
- Interstitial har mock interview ke baad
- Rewarded ad se premium answer packs unlock
- ₹149 lifetime full unlock

## ASO / Keywords
- interview english, interview questions answers hindi, interview ki taiyari, english bolna seekhe interview, job interview practice app
- Naam suggestion: "Interview English - Bolkar Practice"

## Competition
- Interview questions ke PDF/text apps bahut hain, lekin **voice-practice wala offline** app nahi ke barabar — yahi difference hai, ASO mein "bolkar practice" push karo

## Kitna Time Lagega
2 hafte (engine ready hai, mostly content likhna hai)

## Success Metric (3 mahine)
- 15,000+ installs (interview keyword volume high hai)
- Practice completion rate 40%+
