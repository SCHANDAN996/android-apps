=====================================================
 KISAN CALCULATOR — PLAY CONSOLE UPLOAD GUIDE
 (Is folder ki har file kahan use hogi)
=====================================================

STEP 1: PLAY CONSOLE ME APP BANAO
---------------------------------
Play Console (play.google.com/console) → "Create app"
- App name       → app-name.txt se copy karo (30 chars limit)
- Default language → Hindi (hi-IN)
- App type       → App
- Free/Paid      → Free

STEP 2: STORE LISTING (Grow → Store presence → Main store listing)
-------------------------------------------------------------------
- App name          → app-name.txt
- Short description → short-description.txt (80 chars limit)
- Full description  → full-description.txt (4000 chars limit)
- App icon          → icon-512.png (512x512, exact yahi size chahiye)
- Feature graphic   → feature-graphic-1024x500.png (1024x500)
- Phone screenshots → screenshots/ folder ki 6 PNG files
                      (01 se 06 tak, isi order me upload karo)

STEP 3: APP CONTENT (Policy → App content)
-------------------------------------------
- Privacy policy URL → privacy-policy-url.txt me hai
- Data safety form   → Sab me "No" — app koi data collect NAHI karta,
                       koi data share NAHI karta, internet use NAHI karta
- Content rating     → Questionnaire bharo: Utility/Tools category,
                       koi violence/gambling/ads nahi → "Everyone" rating milegi
- Target audience    → 18+ (ya 13+) chuno; kids app NAHI hai
- Ads                → "No, my app does not contain ads"

STEP 4: RELEASE (Production → Create new release)
--------------------------------------------------
- App bundle upload karo:
  build/app/outputs/bundle/release/app-release.aab
  (project folder me hai; naya banana ho to: flutter build appbundle --release)
- Release notes (hi-IN):
    पहला वर्जन — भूमि कन्वर्टर, प्लाट नाप, फसल मुनाफा, EMI और सूद कैलकुलेटर।
- Save → Review release → Rollout to Production

⚠️ ZAROORI YAAD RAKHO
----------------------
1. KEYSTORE BACKUP: android/app/kisan-upload.jks + password —
   Google Drive/pendrive pe copy rakho. Kho gaya to app update
   kabhi nahi kar paoge!
2. applicationId: com.chandansingh.kisan_calculator — ab kabhi mat badalna.
3. Organization account hai to closed testing zaroori nahi —
   seedha Production ja sakte ho.
4. Review me 1-7 din lagte hain (pehli app me zyada lag sakta hai).

ASSETS DOBARA BANANE HON TO
----------------------------
- Icon/banner/screenshots: flutter test tool/generate_store_assets.dart
- Launcher icon (app ke andar wala): flutter test tool/generate_icon.dart
  phir: dart run flutter_launcher_icons
