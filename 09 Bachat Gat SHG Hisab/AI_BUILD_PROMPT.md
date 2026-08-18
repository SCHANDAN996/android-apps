# AI BUILD PROMPT — Bachat Gat / SHG Hisab (बचत गट हिसाब)

> **उपयोग (मेरे लिए):** पूरा English हिस्सा AI को दो + PLAN.md + (अगर उपलब्ध हो) Dudh/Hajiri apps का `lib/db/` module और Kisan Calculator का sood (simple interest) logic। बाद में `0.1 PLAY STORE ASSETS PROMPT`।

---

## ROLE
Senior Flutter developer. Build a complete, production-ready Android app from this spec. This is the most data-model-heavy app of my portfolio — prioritize correctness of money math over UI flair. Write unit tests for all money calculations.

## PRODUCT
**Bachat Gat Hisab** — Hindi-first, 100% offline ledger for Indian women's Self-Help Groups (SHG / बचत गट / समूह). The group secretary records monthly savings (जमा), internal loans (कर्ज़), interest (ब्याज), and repayments — replacing the error-prone paper register. India has 8M+ SHGs; existing government apps are complex and online.

## STANDARD PROJECT RULES
- Flutter stable, Android-only, minSdk 23, Material 3, < 20 MB, offline, no login.
- DB: sqflite clean module (reuse my provided pattern if given). Hindi default + English strings. Very large fonts (semi-literate users), high contrast.
- Ads LIGHT: banner only on reports screen. NO interstitials (trust-sensitive women users).
- Freemium: 1 group free; 2+ groups via IAP ₹199/year subscription OR ₹499 lifetime (in_app_purchase).
- JSON backup/restore is CRITICAL here (group's money records) — auto-remind monthly to backup. in_app_review after 3rd meeting saved.

## DATA MODELS
```
groups(id, name, monthlySaving REAL, interestRatePctPerMonth REAL, meetingDay INT, startDate)
members(id, groupId, name, phone?, joinDate, active INT)
meetings(id, groupId, date, note)
contributions(id, meetingId, memberId, amount REAL, type TEXT('saving'|'fine'|'other'))
loans(id, groupId, memberId, principal REAL, ratePctPerMonth REAL, issuedDate, purpose TEXT, status TEXT('active'|'closed'))
repayments(id, loanId, meetingId?, date, principalPart REAL, interestPart REAL)
```

## MONEY MATH (exact; unit-test everything)
- Simple monthly interest (village style, like my Kisan Calculator's sood): interestDue = outstandingPrincipal × rate% × monthsElapsed (months counted by meeting cycle; partial month = full month, configurable).
- On repayment: interest first, then principal (standard SHG practice; show the split clearly).
- Member passbook: totalSaved = Σsavings; loanOutstanding = principal − ΣprincipalParts; interestPaid = ΣinterestParts.
- Group fund = Σall savings + Σinterest received + Σfines − Σactive loan principals outstanding = cash in box + on loan. Show both: "कैश में" and "कर्ज़ पर".

## SCREENS
1. **Group home** — fund summary card (कुल जमा / कैश / कर्ज़ पर), next meeting chip, buttons: इस महीने की बैठक, कर्ज़, सदस्य, रिपोर्ट.
2. **Meeting entry (core UX)** — date; member list where each row shows expected saving pre-filled (group's monthlySaving) with tick to confirm or edit amount; unpaid members clearly marked; running total at bottom; loan repayments recordable inline for members with active loans (auto-suggest interest due + principal input); SAVE creates meeting + all rows atomically (transaction).
3. **Loans** — active list (member, outstanding, interest accrued); new loan flow (member, amount ≤ available cash — warn otherwise, rate pre-filled from group, purpose); loan detail with repayment history; close loan.
4. **Member passbook** — per member: savings history, loan history, one shareable summary (WhatsApp text).
5. **Reports** — monthly meeting summary (share as Hindi text: date, present, collected, loans given, repaid, cash balance); yearly member-wise table.
6. **Settings** — group settings, backup (with monthly reminder), IAP, language.

## THEME (unique)
Seed magenta/maroon (#880E4F) with soft pink surfaces; icon: circle of hands / rangoli-style circle + rupee. Very large tap targets.

## EDGE CASES
- Editing an old meeting recalculates all downstream interest displays (interest is computed-on-view from repayment records, never double-stored).
- Member leaves group → deactivate, settle passbook view remains.
- Loan larger than cash → warn but allow (groups sometimes use bank linkage).
- All money ops in DB transactions; restore idempotent.

## BUILD ORDER
1. DB + groups/members + group home
2. Meeting entry flow (atomic, fast) + savings math
3. Loans + interest engine (unit tests first) + repayments
4. Passbooks + reports + WhatsApp texts
5. IAP + backup reminders + ads-light + polish + README

## ACCEPTANCE CHECKLIST
- [ ] Interest: ₹5000 loan @2%/month, 3 months, repay ₹2000 → interest ₹300 first, principal ₹1700, outstanding ₹3300 (unit test)
- [ ] Group fund always equals cash + outstanding (invariant test)
- [ ] Meeting entry for 15 members < 60 seconds
- [ ] Backup→restore identical; airplane OK; analyze clean; AAB builds
