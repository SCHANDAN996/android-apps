# 🛡️ Pro Kisan — Data Safety & Play Console Declarations

Use these exact answers when filling out the mandatory forms in **Google Play Console → App Content**.

> 🔴 **9 अगस्त 2026 को बदला — पहले पढ़िए।**
>
> यह फ़ाइल मूल रूप से **25 जुलाई** की है, यानी **Google Drive backup जुड़ने
> से पहले** की। तब ऐप का कोई भी data फ़ोन से बाहर नहीं जाता था।
>
> अब जाता है (किसान की मर्ज़ी से)। इसलिए **भाग 4अ नीचे जोड़ा गया है** —
> और नीचे की पुरानी तालिका उससे **अधूरी** है। दोनों पढ़कर भरिए।

---

## 4अ. 🆕 Google Drive backup — Data Safety में क्या जोड़ना है

ऐप अब दो चीज़ें फ़ोन से बाहर भेजता है — **तभी जब किसान ख़ुद Google खाता
जोड़े**। सेटिंग्स → "Google में सुरक्षित" से।

| Data type | Collected | Shared | ज़रूरी? | मक़सद |
|---|---|---|---|---|
| **Email address** | **Yes** | No | Optional | App functionality — कौन सा खाता जुड़ा है वह दिखाने के लिए |
| **Other user-generated content**<br>(दूध का हिसाब, ग्राहक, भुगतान, पशु, खेत) | **Yes** | No | Optional | App functionality — किसान की **अपनी** Google Drive में backup |

### क्यों "Collected = Yes"

Play की परिभाषा में *collected* = **device से बाहर गया**। Drive में जाता
है, इसलिए `Yes` कहना ही सही है — भले हमारे server पर कुछ न आता हो।

### क्यों "Shared = No"

*Shared* = किसी **तीसरे** को दिया गया। यहाँ data किसान की अपनी Drive में
जाता है। हम `drive.appdata` scope इस्तेमाल करते हैं — उससे उसकी बाक़ी
Drive तक हमारी पहुँच नहीं है, और हमारे server पर कुछ नहीं आता।

### ⚠️ जो मेल खाना चाहिए

Data Safety में "Yes" कहने के बाद **privacy पन्ना भी वही कहे** — Play
दोनों साथ पढ़ता है, टकराव मिला तो listing रुकती है।

privacy पन्ने में ये तीन चीज़ें होनी चाहिए (9 अगस्त वाले संस्करण में हैं):
- भाग **1अ / 1a** — Google Drive backup का ज़िक्र
- भाग **6** — Drive की फ़ाइल कैसे मिटाएँ
- `❌ Do not require an account — Google sign-in is entirely optional`

### App access का जवाब नहीं बदलता

`All functionality is available without any special access` — **यही रहेगा**।
Google खाता जोड़ना पूरी तरह मर्ज़ी है; बिना उसके भी पूरा ऐप चलता है।

---

## 1. Government Apps Declaration (⚠️ Critical)

- **Question:** *"Is your app created for or on behalf of a government entity?"*
- **Answer:** **No** 
- **Selection:** `No, this app is not created for or on behalf of a government entity`
- **Reasoning:** Pro Kisan provides government scheme information gathered from public domains for awareness, but is an independent private application.

---

## 2. App Access & Ads

- **App Access:** `All functionality is available without any special access` (No login or password required).
- **Contains Ads:** **No** (`No, my app does not contain ads`).

---

## 3. Target Audience & Content Rating

- **Target Audience:** **18 and over** (Farmers / Dairy Operators) or 13+.
- **Content Rating:** Questionnaire → All answers **No** (Result = **Everyone** / IARC Rating Certificate).

---

## 4. Data Safety Form Answers

### General Questions:
- Does your app collect or share user data? → **Yes**
- Is all user data encrypted in transit? → **Yes** (HTTPS for Weather/News APIs)
- Do you provide a way for users to request data deletion? → **Yes** (Via support email `all.chandansingh@gmail.com`)

### Data Types Breakdown:

| Data Category | Collected? | Shared? | Required / Optional | Purpose |
|---|---|---|---|---|
| **Approximate Location** | Yes | No | Optional | App functionality (Weather forecast) |
| **Precise Location** | Yes | No | Optional | App functionality (GPS Field Area measurement) |
| **Name** | Yes | No | Optional | App functionality (Optional feedback form) |
| **Phone Number** | Yes | No | Optional | Customer support / Optional feedback form |
| **Contacts** | **No** (On-device only) | No | Optional | "कॉन्टैक्ट से चुनें" — contact का नाम/नंबर सिर्फ़ phone के local database में save होता है, कभी upload नहीं होता। Google की परिभाषा में "collected" = device से बाहर भेजा गया — यहाँ ऐसा नहीं होता, इसलिए **No**। |
| **Photos** | No (On-device only) | No | Optional | Cattle photo display (stored locally on phone) |
| **Financial / Ledger Data** | No (On-device only) | No | Required | Stored in offline SQLite database on phone |

---

## 5. App-level Permissions (2026-07-25 की APK/AAB के अनुसार)

App startup पर एक बार permission dialogs आते हैं (notification → location → contacts)। Manifest में:

| Permission | क्यों | Data Safety असर |
|---|---|---|
| `INTERNET` | मौसम, मंडी भाव, समाचार API | — |
| `ACCESS_FINE/COARSE_LOCATION` | मौसम + GPS खेत नाप | Location = Collected (ऊपर टेबल) |
| `READ_CONTACTS` | ग्राहक जोड़ते समय "कॉन्टैक्ट से चुनें" | On-device only — Collected नहीं |
| `CAMERA` | पशु की फ़ोटो | On-device only |
| `POST_NOTIFICATIONS` | सुबह/शाम एंट्री रिमाइंडर | — |
| `SCHEDULE_EXACT_ALARM` | रिमाइंडर सही समय पर (user-grantable) | — |
| `READ/WRITE_EXTERNAL_STORAGE` (पुराने Android) | backup file | — |

> ⚠️ **`USE_EXACT_ALARM` जान-बूझकर नहीं लिया गया।** Google उसे सिर्फ़ अलार्म-घड़ी/कैलेंडर ऐप को देता है — हमारे जैसे ऐप में वह policy violation बन जाता।
> **`MANAGE_EXTERNAL_STORAGE` (All files access) भी नहीं** — वह सिर्फ़ file-manager/antivirus के लिए है; बैकअप उसके बिना काम करता है।

### Prominent Disclosure (Google User Data policy की माँग)
Location/Contacts जैसी संवेदनशील अनुमति से **पहले** ऐप अपनी भाषा में एक स्क्रीन दिखाता है कि कौन सी अनुमति किस काम आती है, और "अभी नहीं" का विकल्प देता है। Review में पूछा जाए तो यही जवाब है।

### Technical compliance
- **targetSdk 35** (Android 15) — Play की मौजूदा अनिवार्यता पूरी।
- **Ads: नहीं** — AdService अभी खाली stub है। बाद में ads जोड़ें तो Console की "Contains ads" घोषणा **बदलनी पड़ेगी**।
- **TrustManager:** सर्टिफ़िकेट जाँच बंद नहीं की गई — सिर्फ़ अपने एक VPS host का SHA-256 pinning है (`lib/services/ssl_pinning.dart`)। बाकी हर host की जाँच सख़्त।

**Review में सवाल आए तो जवाब:** "Contacts are read only when the user taps 'Pick from contacts' while adding a customer, to prefill name and phone number. This data is stored only in the app's local offline database and is never transmitted off the device."
