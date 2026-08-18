# 13 — Douyin Video Downloader (Utility App)

## Ek Line Mein
Douyin (Chinese TikTok) ki video links se bina watermark ke videos aur photos fast download karne wala offline-first tool.

## Target User
- Content Creators jo Douyin se videos lekar react/edit karte hain.
- Video editors aur social media managers jo reference videos download karna chahte hain.
- Common users jinhe status/sharing ke liye Douyin videos bina watermark ke chahiye.

## Problem
Douyin (Chinese TikTok) se directly watermark-free high-quality video download karne ka official option nahi milta. Online tools complex hote hain aur unme spammy ads aur captcha hote hain. Ek simple, clean aur premium mobile app jo link paste karte hi video download kar de, uski demand bahut high hai.

## MVP Features (v1)
1. **Auto Link Paste & Detection** — App open hote hi clipboard se Douyin link automatically detect karke input field mein paste kar dega.
2. **Watermark-Free Download** — Link parse karke background video stream nikalega aur bina watermark ke download karega.
3. **Photo Album/Slide Support** — Agar Douyin link photo gallery/album hai, to saare photos download karne ka option.
4. **Built-in Media Gallery & Player** — App ke andar hi download kiye hue videos/photos dekhne ke liye functional player aur simple local gallery.
5. **Multi-Engine Fallback Parsing** — Local HTML parsing + public high-speed API (api.douyin.wtf) ka hybrid approach taaki updates ke baad bhi app chalta rahe.
6. **One-Tap Share** — Direct WhatsApp/Telegram/Instagram par single click se video share karne ka button.
7. **Offline-First Storage** — Videos user ke phone storage (Gallery) mein public downloads folder mein jayenge.

## Monetization
- **AdMob Integration**: Interstitial ad download complete hone par, aur banner ad UI ke bottom mein.
- **In-App Purchase**: ₹99/lifetime premium support for ad-free experience.

## ASO / Keywords
- douyin video downloader, download douyin without watermark, douyin video save, douyin link downloader, douyin photo saver, douyin saver.

## Kitna Time Lagega
1-2 Din (Flutter UI + Dart parser).
