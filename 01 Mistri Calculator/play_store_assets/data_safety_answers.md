# Play Console — Data Safety form answers

> **App reality:** 100% offline utility. No login, no account, no server. Stores rates/language locally in `shared_preferences` only. The **only** data leaving the device is via the **Google AdMob SDK** (`google_mobile_ads`). `in_app_review` and `share_plus` do not collect data. There is **no analytics SDK**.
>
> Because AdMob is present, you MUST declare data collection. Answers below reflect Google's published AdMob Data-safety guidance. Verify at: AdMob Help → "Complete the Data safety form in Play Console".

---

## SECTION A — Data collection & security

| Play Console question | Answer to select | Reason |
|-----------------------|------------------|--------|
| Does your app collect or share any of the required user data types? | **Yes** | AdMob collects the Advertising ID (and may collect approx. location / diagnostics). |
| Is all of the user data collected by your app encrypted in transit? | **Yes** | AdMob transmits over HTTPS/TLS. |
| Do you provide a way for users to request that their data be deleted? | **No** | No accounts and no personal data are stored on any server; ad ID is device-controlled (user can reset/delete it in Android Settings → Privacy → Ads). Add this note in the "data deletion" explanation box. |

---

## SECTION B — Data types collected (mark each below)

### ✅ Device or other IDs — **COLLECTED & SHARED**
| Field | Value |
|-------|-------|
| Collected? | Yes |
| Shared? | Yes (with Google/AdMob & advertising partners) |
| Processed ephemerally only? | No |
| Required or optional? | Required (part of showing ads) |
| Purposes | **Advertising or marketing**, **Fraud prevention, security & compliance** |
| Data type | Advertising ID (AAID) |

### ✅ Location → Approximate location — **COLLECTED & SHARED** (declare to be safe)
| Field | Value |
|-------|-------|
| Collected? | Yes (AdMob may derive coarse location from IP for ad relevance) |
| Shared? | Yes |
| Required or optional? | Optional |
| Purposes | **Advertising or marketing** |
| Note | If you configure **non-personalized ads only**, you may omit this — but declaring it is the safe default. Do NOT declare *precise* location (app has no location permission). |

### ✅ App activity → App interactions — **COLLECTED & SHARED** (conservative)
| Field | Value |
|-------|-------|
| Collected? | Yes (ad impressions/clicks) |
| Shared? | Yes |
| Purposes | **Advertising or marketing**, Analytics (AdMob measurement) |

### ✅ App info & performance → Diagnostics / Crash logs — **COLLECTED** (conservative)
| Field | Value |
|-------|-------|
| Collected? | Yes (AdMob SDK diagnostics) |
| Shared? | Yes |
| Purposes | **Analytics**, App functionality |

### ❌ NOT collected — mark these as NO
- Personal info (name, email, phone, address) — **No**
- Financial info (the "My Rates" prices are stored **on-device only** and never transmitted) — **No**
- Health & fitness — **No**
- Messages / Contacts / Calendar — **No**
- Photos / Videos / Audio / Files — **No** (`share_plus` shares text the user chooses; no files collected)
- Web browsing history — **No**
- Precise location — **No**

---

## 🚩 RISK FLAGS — read before submitting
1. **You cannot say "No data collected."** Because AdMob ships in v1.0, that would be a **false declaration** and can get the app suspended. Declare the Advertising ID at minimum.
2. **"My Rates" is user financial-ish data but stays local** — declare it as **not collected** (it never leaves the device). Only mention it in the privacy policy as on-device storage.
3. If you later switch to **non-personalized ads**, you can reduce Location/App-activity declarations — update the form when you change ad settings.
4. Keep **"Contains ads" = Yes** in the separate Play "Ads" declaration (different from Data safety).
5. Not a "Designed for Families" app — target audience is adult professionals; do not opt into the Families programme (AdMob + Families has extra rules).

## Minimum safe declaration (if you want the leanest honest set)
Declare only **Device or other IDs (Advertising ID)** as collected+shared for advertising. This is the smallest defensible answer for a standard AdMob banner+interstitial integration. The extra types above are the conservative superset.
