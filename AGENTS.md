# Revivo — Agent & Developer Workflow Rules

> **Read this file before any work.** It is the single source of truth for *how* we build Revivo.
> Update the **Progress Tracker** (section 9) at the end of every feature.

---

## 1. Project context

Revivo is a Flutter app for car maintenance, odometer, warranty, expense and sharing tracking (Egypt market: **km**, **EGP**, **English LTR + Arabic RTL**).

| Source of truth | Location |
|---|---|
| Step-by-step implementation plan | [`IMPLEMENTATION_PLAN.md`](IMPLEMENTATION_PLAN.md) — follow milestone order |
| Architecture rules | [`ARCHITECTURE_README.md`](ARCHITECTURE_README.md) — follow it exactly |
| Backend API reference (39 endpoints) | [`README.md`](README.md) |
| Full backend handoff (DTOs, rules, errors) | `Backend/Revivo/docs/REVIVO_FLUTTER_BACKEND_HANDOFF.md` |
| Backend gaps (do **not** build these) | `Backend/Revivo/docs/REVIVO_BACKEND_GAPS.md` |
| Figma design | https://www.figma.com/design/YpH0vEGvFiVez3qJrFoZIh — file key `YpH0vEGvFiVez3qJrFoZIh` |

`Backend/` is a separate git repo (ignored here). **Never commit it** and never edit backend code from this project.

---

## 2. Golden rules

1. **Never start implementing without user approval** of the feature scope (screens + endpoints).
2. **One feature at a time.** Finish, verify and update the tracker before starting the next one.
3. **Architecture:** `UI → Cubit → Repository → DioProvider`. Pages never call `DioProvider` or `SharedPref` directly.
4. **Design:** match Figma. Use tokens from `core/styles` and `core/constants` — never hardcode colors, sizes or font families.
5. **Backend is the truth:** display backend-calculated values (status, remainingKm, remainingDays, statistics). Never recalculate them in Flutter.
6. **No new packages** without asking the user first.
7. **No fake features:** nothing from the backend gaps list (password reset, refresh token, push, unread counts, image upload, profile edit…).
8. **Ask, don't guess** when Figma and the backend disagree.

---

## 3. Folder structure (fixed)

```
lib/
├── main.dart
├── core/
│   ├── constants/   app_assets, app_fonts, app_images, app_constants (spacing/radius/sizes)
│   ├── functions/   extensions, navigations, validations
│   ├── routes/      routes.dart (paths + path builders), app_router.dart
│   ├── services/
│   │   ├── apis/    apis.dart (all endpoints), dio_provider.dart, api_error.dart
│   │   └── local/   shared_pref.dart, secure_storage.dart
│   ├── styles/      colors, text_styles, themes
│   ├── utils/       bloc_observer
│   └── widgets/     main_button, custom_text_form_field, custom_svg_picture, dialogs, my_body_view, shimmer/
└── features/<feature>/
    ├── data/
    │   ├── models/       <name>_model.dart, <name>_request_model.dart
    │   └── repository/   <feature>_repo.dart
    └── presentation/
        ├── cubit/        <feature>_cubit.dart, <feature>_state.dart
        ├── pages/        <screen>_screen.dart
        └── widgets/      feature-only widgets
```

Features: `splash`, `auth`, `dashboard`, `garage`, `maintenance`, `warranties`, `odometer`, `statistics`, `alerts`, `sharing`, `account`.
A widget used by **2+ features** moves to `core/widgets/`.

---

## 4. New feature workflow (follow every step, in order)

### Step 1 — Plan (no code)
- [ ] Read this file and the feature's section in `README.md`.
- [ ] Open the Figma page for the feature (node IDs in section 8) and list every screen + state (loading, empty, error, success, dark, read-only).
- [ ] Map each screen to its endpoints, request/response models and error cases (400 fields, 404, 409 messages).
- [ ] List new shared widgets, icons, translation keys and routes needed.
- [ ] **Present the plan to the user and wait for approval.**

### Step 2 — Design extraction
- [ ] Load the `figma-design-to-code` skill before calling `get_design_context`.
- [ ] Call `get_design_context` / `get_screenshot` per screen frame.
- [ ] Export missing SVG icons to `assets/icons/` and register them in `AppAssets`.
- [ ] Add any missing token to `colors.dart` / `app_constants.dart` / `text_styles.dart` (never inline values).

### Step 3 — Data layer
- [ ] Add endpoints to `core/services/apis/apis.dart` (if not already there).
- [ ] Create models in `data/models/` — plain Dart, `fromJson` / `toJson`, nullable fields exactly as the backend DTO (README section 4+).
- [ ] Create `<feature>_repo.dart` with `static` methods:
  ```dart
  try {
    final res = await DioProvider.get(endpoint: Apis.x);
    return Model.fromJson(res.data);
  } on DioException catch (e) {
    throw ApiException.fromDioException(e);
  }
  ```

### Step 4 — Cubit & states
- [ ] States: `Initial`, `Loading`, `Success(data)`, `ActionSuccess(message)`, `Error(message / ApiException)`; add granular states for multi-step forms.
- [ ] Catch `ApiException`; keep `fieldErrors` so forms can show errors under the right field.
- [ ] Use `Future.wait` for parallel independent calls; emit `List.unmodifiable` data.

### Step 5 — UI
- [ ] Pages in `pages/`, extracted parts in `widgets/`.
- [ ] `BlocConsumer`: **listener** → navigation, SnackBars (`showMyDialog`); **builder** → loading (shimmer), empty, error (retry), content.
- [ ] Use `MainButton`, `CustomTextFormField`, `MyBodyView`, theme text styles.
- [ ] All user-visible text via `easy_localization` keys (`'auth.login_title'.tr()`), added to **both** `en.json` and `ar.json`.
- [ ] RTL-safe: use `EdgeInsetsDirectional`, `AlignmentDirectional`, `start`/`end` — never `left`/`right`.
- [ ] Forms: `GlobalKey<FormState>`, dispose every controller, check `if (!context.mounted) return;` after `await`.
- [ ] Shared (read-only) vehicles: hide all write actions and show the read-only badge.

### Step 6 — Routing
- [ ] Add path constant (+ path builder for params) in `routes.dart`.
- [ ] Register `GoRoute` in `app_router.dart`; provide the Cubit with `BlocProvider` in the route builder or page root.

### Step 7 — Verify
- [ ] `dart analyze` → **No issues found**.
- [ ] `flutter test` passes (add cubit/model tests for non-trivial logic).
- [ ] Run the app against the backend and walk through every screen and state.
- [ ] Compare each screen with its Figma screenshot.

### Step 8 — Close the feature
- [ ] Update the **Progress Tracker** (section 9) and **Decisions log** (section 10).
- [ ] Summarize to the user: what was built, files changed, what's left. The user commits.

---

## 5. Backend / API rules

- Base URL: `Apis.baseUrl`, override with `--dart-define=API_BASE_URL=...` (Android emulator: `http://10.0.2.2:5269`).
- Token: saved via `SharedPref.saveToken` (stored in secure storage). `DioProvider` attaches `Authorization: Bearer` automatically.
- **401** → session cleared by interceptor → go to *Session expired* / Login. No refresh token exists.
- **404** also means "no access" (e.g. revoked share) — show a friendly state, not a crash.
- **409** → show `ApiException.message` (backend text).
- **400** → show `ApiException.fieldError('fieldName')` under the matching field (lookup is case-insensitive).
- Register returns **no token** → after register, log in.
- Vehicle DTO has **no make/model names** → resolve from the catalog.
- Owner vs shared: compare `vehicle.ownerId` with `/auth/me` id.
- Maintenance save order: **record → schedule (itemId) → warranty (recordId)**; on partial failure retry only the failed step (Figma "Partial save" screen).
- Statistics: `null` distance = **no data**, never show `0`. Label `Estimated` / partial values.
- Alerts: no global endpoint → aggregate `GET V/alerts` per vehicle; no unread counts.

---

## 6. Coding conventions

- `snake_case` file names matching class names; no typos (`repository/`, not `repo/`).
- `const` constructors wherever possible.
- No commented-out dead code, no `print` (use `debugPrint` / `log`).
- Money: `intl` `NumberFormat` + `EGP`; distances: thousands separator + `km`; dates via `intl` `DateFormat`.
- Never use Material `Colors` for brand colors — use `AppColors`.

---

## 7. Commands

```sh
flutter pub get
dart analyze
flutter test
flutter run --dart-define=API_BASE_URL=http://localhost:5269
```

---

## 8. Figma map (file key `YpH0vEGvFiVez3qJrFoZIh`)

| Page | Node | Screens (frame node IDs) |
|---|---|---|
| 02 Design System | `2:2` | Button `3:13`, Field `3:21`, Status chips `3:32`, Maintenance card `3:33`, Notification card `3:36`, Vehicle card `3:39`, Statistics card `3:42`, Empty state `3:45`, Dialog `3:48`, Bottom sheet `3:51`, Navigation `3:54`, Vehicle hero `3:58`, Monthly bar chart `3:59`, Toggle `8:55`, Foundations `8:27` |
| 03 Onboarding & Auth | `2:3` | Welcome `3:75`, Register `3:91`, Login `3:112`, Auth error `3:131`, Session expired `3:151` |
| 04 Garage & Vehicle | `2:4` | Garage empty `3:164`, Garage `3:181`, Add car `3:205`, Model and year `3:228`, Car details `3:250`, Car added `3:271`, Dashboard `3:288`, Vehicle settings `3:326`, Dashboard dark `3:350`, Loading garage `10:1209`, Image unavailable `10:1234` |
| 05 Maintenance & Warranties | `2:5` | History `4:2`, Record `4:27`, Next service `4:58`, Upcoming `4:87`, Details `4:110`, Edit `4:136`, Warranties `4:162`, Warranty details `4:185`, Warranty form `4:210`, Partial save `4:240`, History empty `4:260` |
| 06 Mileage & Statistics | `2:6` | Update mileage `5:2`, Mileage validation `5:24`, Updated status `5:41`, Weekly check-in `5:63`, Mileage history `5:82`, Spending `5:105`, Yearly expenses `5:150`, Driving insights `5:178`, Estimate explanation `5:217`, Insufficient data `5:237`, Spending dark `5:256`, No expenses yet `10:1548`, Sparse mileage `10:1578` |
| 07 Notifications & Sharing | `2:7` | Alerts `6:2`, Alert preferences `6:27`, Share vehicle `6:58`, Manage access `6:77`, Received invitations `6:97`, Shared vehicle `6:115`, Revoke access `6:140`, Account `6:158`, Network error `6:183`, Access removed `6:199`, All clear `6:215` |
| 08 Interactive Prototype | `2:8` | Flow reference only |

---

## 9. Progress tracker

| # | Milestone | Status | Notes |
|---|---|---|---|
| 0 | Foundation: folders, pubspec, core (theme, Dio, storage, router, widgets) | ✅ Done | `dart analyze` clean |
| 1 | Splash & session bootstrap (`/auth/me`, 401 redirect wiring) | ⏳ Next | `IMPLEMENTATION_PLAN.md` #1 |
| 2 | Auth (Welcome, Register, Login, Auth error, Session expired) | ⬜ | Page `2:3` |
| 3 | Dashboard shell (Garage / Alerts / Account tabs) | ⬜ | Navigation `3:54` |
| 4 | Garage & add vehicle (catalog, image, dashboard, settings) | ⬜ | Page `2:4` |
| 5 | Maintenance, schedules, warranties | ⬜ | Page `2:5` |
| 6 | Odometer & statistics | ⬜ | Page `2:6` |
| 7 | Alerts & preferences | ⬜ | Page `2:7` |
| 8 | Sharing & invitations | ⬜ | Page `2:7` |
| 9 | Account (read-only profile, theme, EN/AR, logout) | ⬜ | `6:158` |
| 10 | Polish: Arabic/RTL review, dark mode, accessibility, tests | ⬜ | |

Status legend: ⬜ not started · ⏳ in progress / next · ✅ done

---

## 10. Decisions log

| Date | Decision |
|---|---|
| 2026-11-27 | Architecture = `ARCHITECTURE_README.md` (Cubit, go_router, Dio, SharedPreferences, easy_localization). |
| 2026-11-27 | JWT stored in `flutter_secure_storage` behind the `SharedPref` wrapper; no saved password / no auto re-login. |
| 2026-11-27 | No roles — owner vs shared (read-only) per vehicle. |
| 2026-11-27 | Charts: custom widget (no `fl_chart`). No `get_it` / `equatable`; static repositories. |
| 2026-11-27 | Fonts via `google_fonts` for now (Manrope / Noto Sans Arabic); bundling into `assets/fonts/` is optional later. |
| 2026-11-27 | `Backend/` untracked and ignored in this repo. |
