# Revivo — Step-by-Step Implementation Plan

> **Purpose:** Token-efficient, self-contained execution roadmap for building Revivo feature by feature in Antigravity.
> Read [`AGENTS.md`](AGENTS.md) for workflow rules, [`ARCHITECTURE_README.md`](ARCHITECTURE_README.md) for patterns, and [`README.md`](README.md) for full DTOs.
> **Rule:** Complete and verify **one milestone at a time**. Update the tracker in [`AGENTS.md`](AGENTS.md) when done.

---

## How to run a milestone (save tokens)

When starting a milestone in a fresh chat (e.g., on Gemini 4 Neon), send a short prompt like:

> `Read AGENTS.md and IMPLEMENTATION_PLAN.md Milestone <N>. Plan Milestone <N> first and wait for my approval before coding.`

To minimize token usage during implementation:
- Only call Figma `get_design_context` / `get_screenshot` for the **node IDs listed in the current milestone** (never re-scan the whole Figma file).
- Only read the files listed under **Files to touch** for that milestone.
- Batch independent file reads/writes in parallel; run `dart analyze` once after edits.

---

## Milestone 0 — Foundation ✅ Done

- Folder structure (`core/`, `features/`), `pubspec.yaml` dependencies, `assets/translations/{en,ar}.json`.
- `AppColors`, `AppTextStyles`, `AppThemes` (light/dark, EN/AR), `AppConstants`, `AppAssets`.
- `Apis` (all 39 routes), `DioProvider` (Bearer + 401 interceptor), `ApiException`, `SecureStorage`, `SharedPref`.
- `Routes`, `AppRouter`, `MyBlocObserver`, shared widgets (`MainButton`, `CustomTextFormField`, `CustomSvgPicture`, `MyBodyView`, `dialogs`, `AppShimmerBox`).

---

## Milestone 1 — Splash & Session Bootstrap ✅ Done

**Goal:** Check saved JWT on startup, validate session with `/api/auth/me`, wire global 401 redirect, and route to Dashboard (if valid) or Welcome (if logged out/expired).

- **Figma:** Brand styling from `02 Design System` (`8:27` Foundations).
- **Endpoints:** `GET /api/auth/me` (`Apis.me`).
- **Models & Data:**
  - `lib/features/auth/data/models/user_model.dart` (`id`, `name?`, `email?`) — reused by Auth, Garage (owner check), and Account.
  - `lib/features/auth/data/repository/auth_repo.dart` → `static Future<UserModel> fetchCurrentUser()`.
- **Files to create/update:**
  - `lib/features/splash/presentation/cubit/splash_cubit.dart` & `splash_state.dart`
  - `lib/features/splash/presentation/pages/splash_screen.dart`
  - `lib/core/routes/app_router.dart` (wire `BlocProvider` for `SplashCubit`)
  - `lib/main.dart` (wire `DioProvider.init(onUnauthorizedCallback: ...)` to navigate via `navigatorKey` to `Routes.sessionExpired`)
  - `assets/translations/{en,ar}.json` (splash tagline if needed)
- **Rules & edge cases:**
  - No saved password / no auto re-login.
  - If `SharedPref.isLoggedIn` is false → go to `Routes.welcome`.
  - If token exists → call `GET /api/auth/me`:
    - `200` → save user map in `SharedPref.saveUserMap`, go to `Routes.dashboard`.
    - `401` → session cleared by interceptor → go to `Routes.sessionExpired` (or `Routes.welcome` on first boot).
    - Network error → show retry UI (do **not** clear token on offline/network error).
- **Done when:** `dart analyze` clean, unit test for `UserModel` / `SplashCubit`, routes cleanly on logged-out and logged-in paths.

---

## Milestone 2 — Authentication (Welcome, Register, Login, Auth Error, Session Expired) ✅ Done

**Goal:** Complete onboarding and authentication flow matching Figma page `03`.

- **Figma (`2:3`):**
  - Welcome `3:75`
  - Register `3:91`
  - Login `3:112`
  - Auth error `3:131`
  - Session expired `3:151`
- **Endpoints:**
  - `POST /api/auth/register` (`Apis.register`) → `201 {id}` (**no token**)
  - `POST /api/auth/login` (`Apis.login`) → `200 {accessToken}`
  - `GET /api/auth/me` (`Apis.me`) → `200 UserModel`
- **Files to create/update:**
  - `lib/features/auth/data/models/auth_request_models.dart` (`RegisterRequestModel`, `LoginRequestModel`)
  - `lib/features/auth/data/repository/auth_repo.dart` (`register`, `login`, `fetchCurrentUser`, `logout`)
  - `lib/features/auth/presentation/cubit/auth_cubit.dart` & `auth_state.dart` (preserve `Map<String, List<String>> fieldErrors` on error)
  - `lib/features/auth/presentation/pages/{welcome_screen,register_screen,login_screen,session_expired_screen}.dart`
  - `lib/features/auth/presentation/widgets/` (auth header, error banner matching `3:131`, password rules hint)
  - `lib/core/routes/app_router.dart` (register `welcome`, `register`, `login`, `sessionExpired`)
  - `assets/translations/{en,ar}.json` (`auth.*` keys)
- **Rules & edge cases:**
  - **No forgot/reset password** link (backend gap).
  - Register returns no token → on `201`, show success message and navigate to `Login` (pre-fill email optionally).
  - Login → save token via `SharedPref.saveToken` → call `GET /api/auth/me` → save user → `context.go(Routes.dashboard)`.
  - Map 400 field errors (`Name`, `Email`, `Password`, `Credentials`) under the matching inputs; show 409 duplicate email and 401 bad credentials in the error banner (`3:131`).
- **Done when:** `dart analyze` clean, auth cubit tests pass, register → login → dashboard and 401 → session expired work against backend.

---

## Milestone 3 — Dashboard Shell (Bottom Navigation) ✅ Done

**Goal:** Authenticated 3-tab shell preserving tab state and scroll position.

- **Figma:** Navigation `3:54` (page `2:2`), Icons `8:2` (Garage), `8:10` (Alerts), `8:18` (Account).
- **Shared assets to export:** `nav_garage.svg`, `nav_alerts.svg`, `nav_account.svg` → register in `AppAssets`.
- **Files to create/update:**
  - `lib/features/dashboard/presentation/widgets/main_layout.dart` (`IndexedStack` + custom/themed bottom nav, `SafeArea(top: false)` on Android)
  - `lib/features/dashboard/presentation/pages/dashboard_screen.dart`
  - `lib/core/routes/app_router.dart` (register `Routes.dashboard`)
- **Rules:**
  - 3 tabs only: **Garage**, **Alerts**, **Account**.
  - Vehicle detail screens push on top of the shell via `go_router`.
  - No fake unread badge on Alerts tab.
- **Done when:** `dart analyze` clean, tab switching preserves state, matches `3:54` in light & dark mode.

---

## Milestone 4 — Garage, Add Vehicle & Vehicle Dashboard ✅ Done

**Goal:** Owned & shared vehicle lists, 3-step car catalog wizard + Unsplash preview, Vehicle Dashboard, and Vehicle Settings.

- **Figma (`2:4`):**
  - Garage empty `3:164`, Garage `3:181`, Loading garage `10:1209`
  - Add car `3:205`, Model and year `3:228`, Car details `3:250`, Car added `3:271`, Image unavailable `10:1234`
  - Dashboard `3:288`, Dashboard dark `3:350`, Vehicle settings `3:326`
- **Endpoints:**
  - `GET /api/car-catalog/makes`, `/models`, `/models/{modelId}/years`, `/car-image`
  - `GET /api/vehicles`, `GET /api/vehicles/shared`, `POST /api/vehicles`, `GET/PUT/DELETE /api/vehicles/{id}`
  - Dashboard summary composes: `GET V/maintenance-status`, `GET V/upcoming-maintenance`, `GET V/statistics/overview`, `GET V/alerts` (with `Future.wait`).
- **Files to create/update:**
  - `lib/features/garage/data/models/` (`car_catalog_models.dart`, `vehicle_model.dart`, `vehicle_request_model.dart`, `car_image_model.dart`)
  - `lib/features/garage/data/repository/garage_repo.dart`
  - `lib/features/garage/presentation/cubit/` (`garage_cubit`, `add_vehicle_cubit`, `vehicle_dashboard_cubit`)
  - `lib/features/garage/presentation/pages/` (`garage_screen`, `add_vehicle_screen`, `vehicle_dashboard_screen`, `vehicle_settings_screen`)
  - `lib/features/garage/presentation/widgets/` (vehicle card `3:39`, hero `3:58`, status chips `3:32`, catalog pickers, image attribution bar)
  - Shared widgets promoted to `lib/core/widgets/`: `status_chip.dart`, `empty_state_widget.dart` (`3:45`).
- **Rules & edge cases:**
  - Vehicle DTO has **no make/model names** → resolve from catalog and cache in memory.
  - Owner vs shared: `vehicle.ownerId == currentUser.id`. Shared vehicles show read-only badge and hide edit/delete/add actions.
  - `car-image` returns `200` for all 5 statuses (`found`, `noImage`, `rateLimited`, `notConfigured`, `unavailable`). Only `found` renders remote image + photographer credit (`url_launcher`); all others show local placeholder (`10:1234`).
  - `DELETE /api/vehicles/{id}` returns `409` while maintenance records exist → display `ApiException.message`.
- **Done when:** `dart analyze` clean, catalog/vehicle model & cubit tests pass, full add/view/edit/delete flow works.

---

## Milestone 5 — Maintenance, Schedules & Warranties ⏳ Next

**Goal:** Paginated service history, record/edit service with partial-save recovery, periodic schedules, upcoming items, and warranties.

- **Figma (`2:5`):**
  - History `4:2`, History empty `4:260`, Details `4:110`, Edit `4:136`
  - Record `4:27`, Next service `4:58`, Upcoming `4:87`, Partial save `4:240`
  - Warranties `4:162`, Warranty details `4:185`, Warranty form `4:210`
- **Endpoints:**
  - `POST/GET V/maintenance`, `GET/PUT/DELETE V/maintenance/{id}`
  - `PUT V/maintenance-items/{itemId}/schedule`, `GET V/maintenance-status`, `GET V/upcoming-maintenance`
  - `GET V/warranties`, `GET/PUT/DELETE V/maintenance/{recordId}/warranty`
- **Files to create/update:**
  - `lib/features/maintenance/data/{models,repository}/`
  - `lib/features/maintenance/presentation/{cubit,pages,widgets}/`
  - `lib/features/warranties/data/{models,repository}/`
  - `lib/features/warranties/presentation/{cubit,pages,widgets}/`
- **Rules & edge cases:**
  - Category & itemName are free text (local suggestions only — no backend search endpoint).
  - **Save order:** `POST maintenance` → save returned `id` & `itemId` → optional `PUT schedule` → optional `PUT warranty`. On failure of step 2 or 3, show **Partial save** (`4:240`) and retry **only** the failed step without duplicating the record.
  - `DELETE maintenance/{id}` returns `409` if a warranty exists → prompt user to delete warranty first.
  - Never recalculate `nextDueDate`, `nextDueMileageKm`, `remainingDays`, `remainingKm`, or `status`. Null due fields → *"No next service set"*.
- **Done when:** `dart analyze` clean, partial-save cubit test passes, CRUD + schedule + warranty flows verified.

---

## Milestone 6 — Odometer & Statistics

**Goal:** Nondecreasing odometer check-in, paginated mileage history, spending & driving insights with custom 12-month bar chart.

- **Figma (`2:6`):**
  - Update mileage `5:2`, Mileage validation `5:24`, Updated status `5:41`, Weekly check-in `5:63`, Mileage history `5:82`
  - Spending `5:105`, Yearly expenses `5:150`, Spending dark `5:256`, No expenses yet `10:1548`
  - Driving insights `5:178`, Estimate explanation `5:217`, Insufficient data `5:237`, Sparse mileage `10:1578`
  - Chart component: Monthly bar chart `3:59` (page `2:2`)
- **Endpoints:**
  - `POST V/odometer`, `GET V/odometer/history`
  - `GET V/statistics/overview`, `GET V/statistics/mileage?year=`, `GET V/statistics/expenses?year=`
- **Files to create/update:**
  - `lib/features/odometer/{data,presentation}/`
  - `lib/features/statistics/{data,presentation}/` (includes custom `MonthlyBarChart` widget matching `3:59`, no `fl_chart`)
- **Rules & edge cases:**
  - No backdated odometer entry (server stamps UTC time). Reject values `< vehicle.currentMileageKm`.
  - After odometer update, refresh vehicle detail, maintenance status, upcoming, alerts, and statistics.
  - **Statistics null rule:** `distanceKm == null` = **no data** (never show `0`). Clearly label `Estimated` and `isPartial` values.
  - Currency is always `EGP`, formatted with `intl` `NumberFormat`.
- **Done when:** `dart analyze` clean, chart handles null/estimated/partial states, odometer + stats tests pass.

---

## Milestone 7 — Alerts & Notification Preferences

**Goal:** Aggregated in-app Alerts tab across all accessible vehicles and per-vehicle alert preferences.

- **Figma (`2:7`):** Alerts `6:2`, All clear `6:215`, Alert preferences `6:27`, Network error `6:183`.
- **Endpoints:**
  - `GET V/alerts` (called per accessible vehicle via `Future.wait` and aggregated client-side)
  - `GET/PUT V/notification-settings`
- **Files to create/update:**
  - `lib/features/alerts/{data,presentation}/`
  - Wire Alerts tab in `MainLayout`.
- **Rules & edge cases:**
  - **No push notifications, no read/dismiss state, no unread count badge.**
  - Shared users can read `GET notification-settings` (display read-only) and cannot `PUT`.
  - `timeZoneId` must be a valid server time zone string (e.g. `Africa/Cairo`, `UTC`).
- **Done when:** `dart analyze` clean, multi-vehicle aggregation works, owner vs shared settings permissions respected.

---

## Milestone 8 — Sharing & Invitations

**Goal:** Owner invites registered users by email, views/revokes access; recipient accepts/rejects invitations and views shared vehicles read-only.

- **Figma (`2:7`):** Share vehicle `6:58`, Manage access `6:77`, Revoke access `6:140`, Received invitations `6:97`, Shared vehicle `6:115`, Access removed `6:199`.
- **Endpoints:**
  - `POST/GET V/shares`, `DELETE V/shares/{shareId}`
  - `GET /api/vehicle-invitations`, `POST .../accept`, `POST .../reject`
- **Files to create/update:**
  - `lib/features/sharing/{data,presentation}/`
- **Rules & edge cases:**
  - No invitation email is sent — copy should tell the owner the invitee will see it in-app.
  - Handle `409` (already invited / no longer pending) with `ApiException.message`.
  - Handle `404` mid-session on a shared vehicle → show **Access removed** (`6:199`) and return to Garage.
- **Done when:** `dart analyze` clean, full two-account invite → accept → read-only → revoke flow verified.

---

## Milestone 9 — Account

**Goal:** Read-only profile, theme toggle (Light/Dark), language toggle (EN/AR), invitations entry point, and local sign-out.

- **Figma (`2:7`):** Account `6:158`.
- **Endpoints:** `GET /api/auth/me` (read-only).
- **Files to create/update:**
  - `lib/features/account/presentation/{cubit,pages,widgets}/`
  - Theme mode persistence via `SharedPref` (`kThemeMode`) wired into `MainApp` in `lib/main.dart`.
  - Wire Account tab in `MainLayout`.
- **Rules & edge cases:**
  - **No profile edit or account delete** (backend gap).
  - Sign-out calls `SharedPref.clearSession()` and navigates to `Routes.welcome`.
- **Done when:** `dart analyze` clean, EN/AR and Light/Dark switches persist across restarts, sign-out clears secure token.

---

## Milestone 10 — Polish, Arabic RTL, Dark Mode & QA

**Goal:** Final quality pass across all screens before release.

- Audit every screen in **Arabic RTL** (`EdgeInsetsDirectional`, `AlignmentDirectional`, mirrored chevrons/back arrows, Noto Sans Arabic spacing).
- Audit **Dark Mode** contrast across all cards, charts, inputs, and dialogs.
- Check accessibility: 48dp minimum touch targets, semantic labels, system text scaling (`textScaler`), never convey status by color alone.
- Run `dart analyze`, `flutter test`, and full end-to-end walkthrough on iOS Simulator & Android Emulator (`--dart-define=API_BASE_URL=http://10.0.2.2:5269`).
