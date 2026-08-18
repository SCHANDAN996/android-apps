# AI BUILD PROMPT — Silai Master (सिलाई मास्टर)

> **उपयोग (मेरे लिए):** पूरा English हिस्सा AI को दो + PLAN.md + DB module (मिले तो)। बाद में `0.1 PLAY STORE ASSETS PROMPT`।

---

## ROLE
Senior Flutter developer. Build a complete, production-ready Android app from this spec.

## PRODUCT
**Silai Master** — Hindi-first, offline measurement + order book for Indian tailors and boutiques. Saves customer naap (measurements) on garment templates, tracks orders (delivery date, advance, balance), reminds about due deliveries.

## STANDARD PROJECT RULES
- Flutter stable, Android-only, minSdk 23, Material 3, < 20 MB, offline, no login.
- DB: sqflite clean module. Hindi default + English strings. JSON backup/restore (naap data is the tailor's business — protect it).
- flutter_local_notifications: delivery reminders (1 day before, 8 AM).
- AdMob TEST IDs: banner on customer list; interstitial only after saving an order, max 1/session.
- Freemium: 30 customers free; unlimited IAP ₹149 lifetime.
- in_app_review after 5th order. Settings standard + rate card editor.

## MEASUREMENT TEMPLATES (assets/templates.json — generate fully)
Schema: `{"id":"kurta","name_hi":"कुर्ता-पजामा","gender":"gents","fields":[{"key":"length","hi":"लंबाई"},...]}`
Units: inches with quarter fractions — input widget must make entering 32¼ / 32½ / 32¾ one-tap easy (number + fraction chips).

**Gents:** कुर्ता-पजामा (लंबाई, छाती, कमर, हिप, कंधा, बाजू, गला, मोहरी, पजामा लंबाई, पजामा कमर), शर्ट (लंबाई, छाती, कमर, कंधा, बाजू, कफ़, गला), पैंट (लंबाई, कमर, हिप, थाई, घुटना, मोहरी, बॉटम), सफ़ारी/कोट (+ crossback), शेरवानी.
**Ladies:** ब्लाउज (लंबाई, छाती, ऊपरी छाती, कमर, कंधा, बाजू, बाजू मोहरी, गला आगे, गला पीछे, तीरा), सलवार-कमीज़ (कमीज़: लंबाई, छाती, कमर, हिप, कंधा, बाजू, गला; सलवार: लंबाई, कमर, हिप, मोहरी), लहंगा (लंबाई, कमर, हिप, घेर), कुर्ती, फ्रॉक (बच्ची), पेटीकोट.
Every template also allows custom extra fields per customer.

## DATA MODELS
```
customers(id, name, phone?, photoPath?, note, createdAt)
measurements(id, customerId, templateId, valuesJson TEXT, note, updatedAt)  -- one per template per customer, editable with history kept in valuesJson versions
orders(id, customerId, templateId?, description, clothReceived INT, orderDate, dueDate, rate REAL, qty INT, advance REAL, status TEXT('pending'|'ready'|'delivered'), photoPath?)
rateCard(id, itemName_hi, rate REAL)
```

## SCREENS
1. **Home** — search bar (name/phone); "आज देने हैं / कल देने हैं" due-orders strip on top; customer list; FAB new customer.
2. **Customer detail** — photo/name/phone; naap chips per saved template (tap to view/edit big cleanly-formatted sheet); orders history; "नया नाप" (template picker → field-by-field entry with fraction chips); "नया ऑर्डर".
3. **Naap sheet view** — large readable table; share as text AND as image (styled widget screenshot) to send to a karigar.
4. **Orders board** — tabs: बाकी / तैयार / दिए गए; each card: customer, item, due date (overdue red), advance/balance; tap to update status (auto-notification cancel on delivered).
5. **Rate card** — editable list (कुर्ता ₹400...), used to prefill order rate.
6. **Settings** — IAP, backup, language, notification time.

## THEME (unique)
Seed rose (#C2185B) with tailor's-chalk white; icon: measuring tape + needle. Elegant but big-font.

## EDGE CASES
- Fraction input parsing exact (store as decimal, display as fraction).
- Customer with no phone OK; duplicate names allowed (photo helps).
- Order without naap allowed (alteration jobs).

## BUILD ORDER
1. DB + customers + templates JSON + naap entry/view
2. Orders + due reminders + status board
3. Share (text + image) + rate card
4. IAP + ads + backup + polish + README

## ACCEPTANCE CHECKLIST
- [ ] 32½ entered in 2 taps; renders back as 32½
- [ ] Due tomorrow → notification fires at set time
- [ ] Naap image share is readable on WhatsApp
- [ ] Backup→restore identical; airplane OK; analyze clean; AAB builds
