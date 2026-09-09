# Vidhivat project audit

**Audit date:** 25 August 2026  
**Scope:** Read-only repository audit. No production UI or application code was changed.

## Executive summary

This is a well-structured offline-first Flutter application with a separate, tested Dart Panchang engine. The Puja journey already exists in usable form:

`Puja Library → Puja Overview → Materials → Guided steps → Mantra / meaning / source state`

The right next move is an incremental premium redesign of that journey, retaining the existing engine, content schema, offline storage, and verification safeguards. It is **not** a rebuild.

## Environment and package layout

| Area | Finding |
|---|---|
| Flutter app | `app/`, package/application id `com.vidhivat` |
| Dart version constraint | `app/pubspec.yaml`: `^3.5.0`; resolved lockfile: Dart `>=3.12.0 <4.0.0` |
| Flutter version constraint | `app/pubspec.lock`: Flutter `>=3.44.0` |
| Installed SDK | Flutter/Dart are available at `C:\src\flutter\bin`; their version output could not be captured in this audit session, so it is not asserted here. |
| Engine | `engine/`, standalone pure-Dart `panchang_engine` package, connected by local path dependency |
| Server/network | No backend. Content and calculations are bundled locally. |
| Android | Native Android shell, Java 17, default Flutter SDK min/target SDK values |

## Current architecture

### Application entry and navigation

- Entry point: `app/lib/main.dart`.
- Startup loads local preferences before `runApp`.
- `VidhivatApp` supplies the light/dark Material 3 themes.
- `HomeShell` keeps six root tabs alive in an `IndexedStack`: **Vidhi, Aaj, Calendar, Sankalp, Chaughadiya, Settings**.
- Secondary navigation uses direct `MaterialPageRoute` pushes; there is no named-route/deep-link layer, which is acceptable at the current app size.

### State and persistence

- `app/lib/state/settings.dart` has one app-wide `ChangeNotifier` (`settings`).
- `shared_preferences` stores city, masa system, yajman name/gotra, and per-Puja material checkmarks locally.
- There is no external state-management library, repository abstraction, or server state. This is appropriate for the current offline-only scope.

### Domain layers

- `engine/lib/src/`: calculations for Panchang, astronomy, festivals, Chaughadiya/hora, Sankalp, and unfinished/hidden Shubh Muhurat work.
- `app/lib/vidhi/vidhi.dart`: typed JSON domain models and strict schema validation.
- `app/lib/vidhi/bhandar.dart`: asset-backed Puja catalogue/data loader with caching.
- `app/assets/vidhi/`: 12 Puja JSON files plus the lightweight `_suchi.json` index.

## Existing product surface

| Capability | Current implementation | Assessment |
|---|---|---|
| Puja Library | Category-grouped list of 12 Pujas | Exists; no rebuild needed |
| Puja overview | Time, difficulty, materials count, step preview, FAQs, source/tradition area | Exists; ideal base for redesign |
| Materials checklist | Required-only filter, persistent checks, WhatsApp sharing | Exists and should be retained |
| Guided Puja | One step per `PageView`, large text, linear progress, large actions, wakelock | Exists; needs experience polish and persistence |
| Sanskrit / transliteration / meaning | Displayed per available mantra | Exists |
| Verification transparency | Unverified Puja and draft/empty mantra warnings, source and confidence state | Strong existing safeguard; preserve exactly |
| Sankalp | Generated from the Panchang engine inside the relevant step | Exists |
| Audio | Audio filename is modelled in JSON, but no recordings, player, assets, or audio dependency exist | Intentionally pending |
| Completion | Last step currently returns to the previous page | Needs a dedicated completion experience |
| Progress tracking | Current step progress only while the player is open | Needs durable in-progress/completed state |

## Reusable components and visual foundation

- Theme: `app/lib/theme.dart` provides Material 3 light/dark palettes using haldi, sindoor, tulsi, ink, and paper tones. Text sizes are deliberately large for seated Puja use.
- Shared UI: `app/lib/widgets/common.dart`
  - `Panna` page scaffold/list padding
  - `Khand` card section
  - `Pankti` label/value row
  - `Chetavni` warning callout
  - Hindi date/time helpers and Hindu-day offset labels
- Puja components: list, overview, materials, and player are already split into focused screens.
- Fonts: no custom font family or font assets are declared. Current Devanagari rendering uses platform fallback.

## Content and trust status

- 12 Puja files; **344 materials**, **139 guided steps**, **92 mantra slots**.
- 55 mantra drafts have source/confidence metadata; 37 are deliberately blank.
- 0/12 Pujas are marked Pandit-verified.
- Validation prevents a mantra from being labelled verified without both Devanagari text and a source; it also prevents incomplete verification metadata from silently appearing ready.

This is a major strength. Phase 1 must only improve presentation and user flow; it must not manufacture, alter, or upgrade ritual/mantra authority.

## Tests and quality controls

- Engine test suite covers astronomy, reference dates, festivals, Chaughadiya/hora, Sankalp, moonrise, and Shubh Muhurat safeguards.
- Flutter tests cover Puja JSON validation and the main Puja screens at phone dimensions.
- Project documentation reports: engine `dart test` 157 checks; app `flutter analyze` clean and 41 tests passing after the most recent phone QA.
- The audit attempted `flutter --version`, `dart test`, `flutter analyze`, and `flutter test`, but this environment returned no readable command output. Those results are therefore **not freshly verified by this audit** and should be rerun before implementation.

## What to keep, what to change

### Keep intact

- `engine/` calculation boundaries and path dependency.
- JSON content schema, verification checks, source/confidence fields, and deliberate empty-mantra behavior.
- Offline-first/local-only policy, wakelock in the player, material checklist persistence, and ad-free guided Puja rule.
- Existing Hindi-first copy and large readable type as a functional requirement.

### Improve incrementally

1. **Design system:** make the existing dark premium direction coherent across colour tokens, surfaces, typography, spacing, buttons, chips, progress, and warning states.
2. **Navigation shell:** refine the root bar/action hierarchy without breaking the six existing destinations.
3. **Puja library and overview:** elevate discovery, status and readiness while preserving source transparency.
4. **Guided Puja:** make each step clearly answer: what to do, why, what is needed, what to recite, how to do it, and whether it is done.
5. **Progress and completion:** persist a resumable session, show meaningful step completion, and replace the final `pop()` with a completion screen.
6. **Audio:** add only after licensed/original, Pandit-reviewed recordings are available; then introduce a minimal player with its own test coverage.

## Current gaps / risks

- No screenshot or design-reference asset is present in this repository, so exact visual matching cannot yet be audited from source.
- No custom Devanagari font is bundled; typography quality may vary by device.
- Guided-Puja progress is not durable across app restarts and there is no completion record.
- Completion is not a screen/state today; the last action simply navigates back.
- Audio is correctly deferred, but the model currently has no usable audio UI state.
- The global mutable settings singleton is simple and suitable today, but new persisted Puja-session state should be isolated rather than added indiscriminately to it.
- Release configuration is still default/debug-signed and the Android label remains `vidhivat`; these are release-phase concerns, not Phase 1 work.

## Recommended implementation phases

1. **Design system** — introduce premium dark tokens and reusable component variants; retain accessible sizes and all warning semantics.
2. **Navigation and shell** — refine tab bar/safe areas and app-level hierarchy.
3. **Puja Library** — redesign catalogue categories, readiness and verification signals.
4. **Puja Overview** — redesign readiness, checklist, step outline, FAQs and source sections.
5. **Materials** — retain sharing/checks while improving group hierarchy and completion feedback.
6. **Guided Puja** — improve the single-step experience and explicit step structure.
7. **Progress and completion** — persist/resume sessions and add a dedicated completion screen.
8. **Audio** — only when approved recordings/assets exist.
9. **Polish and QA** — widget tests, `flutter analyze`, `flutter test`, and real-device verification at 360×800 dp.

## Exact files to modify first (when `IMPLEMENT PHASE 1` is given)

1. `app/lib/theme.dart` — design tokens, typography and Material component themes.
2. `app/lib/widgets/common.dart` — premium reusable cards, headings, badges, warnings, buttons/progress primitives while keeping existing helpers compatible.
3. `app/lib/main.dart` — only if the new shell/navigation styling needs a small integration change.
4. `app/test/vidhi_screens_test.dart` — update/add visual-behaviour widget coverage for any Phase 1 component behaviour.

Do **not** modify the Panchang engine, Puja JSON, verification rules, audio dependencies, or Android release configuration in Phase 1 unless a separate requirement explicitly calls for them.

## Proposed `AGENTS.md` (not created)

```md
# Vidhivat agent rules

1. Read `README.md`, `docs/04_NEXT.md`, and `CLAUDE.md` before changing code.
2. Never invent or present a mantra, ritual, translation, source, or verification as authoritative. Preserve `draft`, `khaali`, and `paas` semantics.
3. Keep the app offline-first: no backend, login, community, booking, donations, or routine-operated feature.
4. Keep `engine/` pure Dart. Panchang calculations belong in the engine, never in Flutter screens.
5. Guided Puja remains ad-free and must preserve large, two-foot-readable type and wakelock behaviour.
6. Reuse `theme.dart` and `widgets/common.dart`; do not duplicate app-wide UI patterns.
7. Add/adjust tests for behaviour changes, run analysis/tests, and verify changed screens on a 360×800 device viewport and a real Android device.
8. Record major decisions in `docs/01_DECISIONS.md`, completed work in `docs/03_PROGRESS.md`, changed next steps in `docs/04_NEXT.md`, and content changes in `docs/06_CONTENT_TRACKER.md`.
```

## Audit conclusion

The repository is ready for a careful Phase 1 visual-system implementation. The first implementation should be scoped to shared presentation primitives and must leave the trusted content pipeline and existing Puja logic untouched.
