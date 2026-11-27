# Flutter Feature-First Cubit Architecture Blueprint

> **Purpose**: This document is a complete architectural guide and implementation blueprint extracted from the `afforestation_app` Flutter codebase. It is designed to be handed directly to an AI coding agent (or developer) to scaffold and build a **new Flutter project** following the exact same structure, patterns, and conventions.

---

## 1. Architecture Overview

This project uses a **Feature-First Layered Architecture** built around **Cubit (`flutter_bloc`)**, **`go_router`**, **`Dio`**, **`SharedPreferences`**, and **`easy_localization`**.

### Core Principles
- **Separation of `core/` and `features/`**: Shared infrastructure (routing, networking, local storage, theming, shared widgets, helpers) lives in `lib/core/`. All domain functionality is isolated into self-contained feature folders under `lib/features/<feature_name>/`.
- **Two-Layer Feature Structure (`data/` + `presentation/`)**: Every feature splits cleanly into:
  - `data/`: Request/response models (`models/`) and API communication (`repository/`).
  - `presentation/`: State management (`cubit/`), full screens (`pages/`), and feature-scoped UI components (`widgets/`).
- **Predictable Unidirectional Data Flow**:

```text
UI (Page / Widgets)
   │  dispatches method call (e.g., cubit.login(...))
   ▼
Cubit (Presentation Logic)
   │  emits LoadingState -> calls Repository
   ▼
Repository (Data Layer)
   │  reads token from SharedPref -> calls DioProvider -> parses JSON Models
   ▼
DioProvider (Core HTTP Client) ◄──► Backend REST API
   │  returns parsed Model(s) or throws Exception(message)
   ▼
Cubit
   │  emits SuccessState(data) or ErrorState(message)
   ▼
UI (BlocConsumer / BlocBuilder)
   ├─ listener: navigation (go_router), SnackBars, dialogs
   └─ builder: renders loading, content, or error UI
```

---

## 2. Tech Stack & Dependencies

Add the following packages to `pubspec.yaml` in the new project:

### Core Architecture Dependencies (Required)
| Package | Role |
|---|---|
| `flutter_bloc` | Cubit / BLoC state management (`BlocProvider`, `BlocBuilder`, `BlocConsumer`, `BlocObserver`) |
| `go_router` | Declarative routing, route constants, `extra` parameter passing, `GlobalKey<NavigatorState>` |
| `dio` | HTTP client with centralized base URL, timeouts, headers, and error handling |
| `shared_preferences` | Local key-value persistence (auth token, user JSON, role, cached credentials, flags) |
| `easy_localization` | Multi-language / RTL support (`en`, `ar`, etc.) via JSON files in `assets/translations/` |

### UI & Utility Dependencies (Recommended / As Needed)
| Package | Role |
|---|---|
| `google_fonts` | Centralized typography (`GoogleFonts.inter()`, etc.) |
| `flutter_svg` | Rendering SVG icons via `CustomSvgPicture` |
| `gap` | Clean spacing in `Row` / `Column` layouts |
| `shimmer` | Skeleton loading placeholders |
| `cached_network_image` | Cached remote images with placeholders |
| `lottie` | Animated loading dialogs / empty states |
| `image_picker`, `path_provider`, `share_plus` | Media picking, file export, and native sharing |

### Assets Configuration (`pubspec.yaml`)
```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/icons/
    - assets/translations/
```
Include `assets/translations/en.json` and `assets/translations/ar.json` (at minimum `{}` if starting empty) so `EasyLocalization` initializes cleanly.

---

## 3. Canonical Directory Structure

Use this exact folder layout for the new project:

```text
lib/
├── main.dart                                  # App bootstrap, init services, EasyLocalization, MaterialApp.router
├── core/
│   ├── constants/
│   │   ├── app_assets.dart                    # Static paths to SVG/icon assets
│   │   ├── app_fonts.dart                     # Font family getters (GoogleFonts)
│   │   └── app_images.dart                    # Static paths to raster/Lottie assets
│   ├── functions/
│   │   ├── extensions.dart                    # BuildContext extensions (e.g., context.isArabic)
│   │   ├── navigations.dart                   # Thin helpers around go_router (pushTo, pushToBase, pop)
│   │   └── validations.dart                   # Reusable form field validators (email, phone, etc.)
│   ├── routes/
│   │   ├── routes.dart                        # Route path string constants
│   │   └── app_router.dart                    # GoRouter configuration & navigatorKey
│   ├── services/
│   │   ├── apis/
│   │   │   ├── apis.dart                      # Base URL & all REST endpoint constants
│   │   │   └── dio_provider.dart              # Centralized Dio wrapper (init, get, post, put, patch, delete)
│   │   └── local/
│   │       └── shared_pref.dart               # Centralized SharedPreferences wrapper
│   ├── styles/
│   │   ├── colors.dart                        # AppColors semantic color palette
│   │   ├── text_styles.dart                   # Reusable TextStyles
│   │   └── themes.dart                        # AppThemes.lightTheme (and darkTheme if needed)
│   ├── utils/
│   │   └── bloc_observer.dart                 # Global BlocObserver for logging state transitions & errors
│   └── widgets/
│       ├── custom_svg_picture.dart            # Standardized SvgPicture.asset wrapper
│       ├── custom_text_form_field.dart        # Styled TextFormField with password visibility toggle
│       ├── dialogs.dart                       # Floating SnackBar / loading dialog helpers
│       ├── main_button.dart                   # Standardized primary button
│       ├── my_body_view.dart                  # Standard screen padding wrapper
│       └── shimmer/                           # Reusable skeleton loading widgets
└── features/
    ├── splash/
    │   └── presentation/
    │       └── pages/
    │           └── splash_screen.dart         # Startup delay, session check, auto-login, role routing
    ├── auth/
    │   ├── data/
    │   │   ├── models/
    │   │   │   ├── auth_params.dart           # Login response model (token, role, id, email)
    │   │   │   └── user_model.dart            # Serialized user info model
    │   │   └── repository/
    │   │       └── auth_repo.dart             # login(), register() + SharedPref persistence
    │   └── presentation/
    │       ├── cubit/
    │       │   ├── auth_cubit.dart
    │       │   └── auth_state.dart
    │       ├── pages/
    │       │   ├── login_screen.dart
    │       │   └── register_screen.dart
    │       └── widgets/                       # Form header, footer, dropdown, submit button
    ├── dashboard/
    │   ├── data/
    │   │   ├── models/
    │   │   └── repository/
    │   └── presentation/
    │       ├── pages/                         # Role-based home screens (e.g., admin_view.dart, user_view.dart)
    │       └── widgets/
    │           └── main_layout.dart           # BottomNavigationBar + IndexedStack shell
    └── <your_feature>/
        ├── data/
        │   ├── models/
        │   │   ├── <feature>_request_model.dart
        │   │   └── <feature>_response_model.dart
        │   └── repository/
        │       └── <feature>_repo.dart
        └── presentation/
            ├── cubit/
            │   ├── <feature>_cubit.dart
            │   └── <feature>_state.dart
            ├── pages/
            │   └── <feature>_screen.dart
            └── widgets/
                └── <feature>_card.dart
```

---

## 4. App Bootstrap (`lib/main.dart`)

Initialize all core singletons **before** `runApp()` in this exact order:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/routes/app_router.dart';
import 'core/services/apis/dio_provider.dart';
import 'core/services/local/shared_pref.dart';
import 'core/styles/themes.dart';
import 'core/utils/bloc_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize core services
  DioProvider.init();
  await SharedPref.init();
  await EasyLocalization.ensureInitialized();

  // 2. Optional: attach BlocObserver for debug logging
  Bloc.observer = MyBlocObserver();

  // 3. Launch app wrapped with EasyLocalization
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routerConfig: AppRouter.routes,
    );
  }
}
```

---

## 5. Core Layer Implementation Guide

### 5.1 Networking (`lib/core/services/apis/`)

1. **`apis.dart`** — Single source of truth for the base URL and every endpoint path:
```dart
class Apis {
  static const String baseUrl = 'https://your-api-domain.com';

  // Auth
  static const String login = '/User/Login/login';
  static const String register = '/User/Register/register';

  // Feature endpoints
  static const String items = '/api/items';
  static const String itemsSearch = '/api/items/search';
}
```

2. **`dio_provider.dart`** — Static HTTP client wrapper configured once in `main()`:
```dart
import 'package:dio/dio.dart';
import 'apis.dart';

class DioProvider {
  static late Dio dio;

  static void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: Apis.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
      ),
    );
  }

  static Future<Response> get({
    required String endpoint,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) => dio.get(
    endpoint,
    data: data,
    queryParameters: queryParameters,
    options: Options(headers: headers),
  );

  static Future<Response> post({
    required String endpoint,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) => dio.post(
    endpoint,
    data: data,
    queryParameters: queryParameters,
    options: Options(headers: headers),
  );

  static Future<Response> put({
    required String endpoint,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) => dio.put(
    endpoint,
    data: data,
    queryParameters: queryParameters,
    options: Options(headers: headers),
  );

  static Future<Response> patch({
    required String endpoint,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) => dio.patch(
    endpoint,
    data: data,
    queryParameters: queryParameters,
    options: Options(headers: headers),
  );

  static Future<Response> delete({
    required String endpoint,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) => dio.delete(
    endpoint,
    data: data,
    queryParameters: queryParameters,
    options: Options(headers: headers),
  );
}
```
> **Auth Header Convention**: Repositories read the JWT token via `SharedPref.getToken()` and pass `headers: token.isNotEmpty ? {'Authorization': 'Bearer $token'} : null`. (For the new project, you may optionally attach a `Dio` `InterceptorsWrapper` in `DioProvider.init()` to inject `Authorization` automatically and handle `401` responses globally.)

---

### 5.2 Local Storage (`lib/core/services/local/shared_pref.dart`)

Centralizes all `SharedPreferences` keys and JSON serialization for user sessions:
- Keys: `kToken`, `kUser`, `kRole`, `kEmail`, `kPassword`.
- `init()` initializes `static late final SharedPreferences prefs`.
- `isLoggedIn` checks `prefs.getString(kToken)?.isNotEmpty ?? false`.
- `saveUserInfo(User? user)` / `getUserInfo()` serializes/deserializes the user object via `jsonEncode` / `jsonDecode`.
- `saveToken`, `getToken`, `saveRole`, `getRole`.
- `saveCredentials(email, password)` / `getCredentials()` / `clearCredentials()` (uses Dart 3 record return type `({String email, String password})?` for auto-login).
- Generic `setString`, `getString`, `setBool`, `getBool`.

---

### 5.3 Routing & Navigation (`lib/core/routes/` & `lib/core/functions/navigations.dart`)

1. **`routes.dart`**: Defines every path as a `static const String` (e.g., `splash = '/splash'`, `login = '/'`, `register = '/register'`, `admin = '/admin'`, `user = '/user'`, etc.).
2. **`app_router.dart`**:
   - Declares a top-level `final navigatorKey = GlobalKey<NavigatorState>();`.
   - Configures `GoRouter(initialLocation: Routes.splash, navigatorKey: navigatorKey, routes: [...])`.
   - Passes arguments via `state.extra` (e.g., `final extra = state.extra as Map<String, String>?;`).
   - Can scope a feature `BlocProvider` directly inside a `GoRoute.builder` when a screen owns a Cubit:
     ```dart
     GoRoute(
       path: Routes.search,
       builder: (context, state) => BlocProvider(
         create: (context) => SearchCubit(),
         child: const SearchScreen(),
       ),
     ),
     ```
3. **`navigations.dart`**: Thin wrappers around `go_router` so screens never depend directly on navigation boilerplate:
   - `pushTo(context, route, {extra})` → `context.push(...)`
   - `pushReplacement(context, route, {extra})` → `context.pushReplacement(...)`
   - `pushToBase(context, route, {extra})` → `context.go(...)` (clears stack)
   - `pop(context)` → `context.pop()`

---

### 5.4 Design System (`lib/core/styles/` & `lib/core/constants/`)

- **`AppColors` (`colors.dart`)**: Material-style semantic color tokens (`primary`, `onPrimary`, `secondary`, `onSecondary`, `tertiary`, `background`, `onBackground`, `surface`, `onSurface`, `onSurfaceVariant`, `error`, `onError`, plus action badge tokens like `editBg`, `editText`, `deleteBg`, `deleteText`).
- **`AppFonts` (`app_fonts.dart`)**: Exposes `GoogleFonts.<font>().fontFamily`.
- **`TextStyles` (`text_styles.dart`)**: Named semantic styles (`appBarTitleStyle`, `screenHeaderTitleStyle`, `cardSectionTitleStyle`, `listRowTitleStyle`, `buttonTextStyle`, `hintTextStyle`, `errorTextStyle`).
- **`AppThemes` (`themes.dart`)**: Configures `ThemeData` globally (`scaffoldBackgroundColor`, `appBarTheme`, `inputDecorationTheme`, `textButtonTheme`, `dividerTheme`).
- **`AppAssets` (`app_assets.dart`)**: Static constants for every SVG/image asset path so raw strings are never duplicated across widgets.

---

### 5.5 Utilities & Shared Widgets

- **`MyBlocObserver` (`core/utils/bloc_observer.dart`)**: Logs `onEvent`, `onChange`, `onTransition`, and `onError` using `dart:developer` `log()`.
- **`extensions.dart`**: `extension Localization on BuildContext { bool get isArabic => locale.languageCode == 'ar'; }`.
- **`validations.dart`**: Pure validation functions (`isEmailValid`, `isEgyptianPhone`, etc.) passed into `TextFormField.validator`.
- **`core/widgets/`**: Reusable UI primitives (`CustomTextFormField` with built-in password obscure toggle, `CustomSvgPicture`, `MainButton`, `MyBodyView`, `showMyDialog` SnackBar helper, `showLoadingDialog`, and `shimmer/` skeleton loaders).

---

## 6. Feature Module Implementation Patterns

Every feature follows the same structure and conventions. Below are the exact patterns used in this codebase.

### 6.1 Models (`features/<name>/data/models/`)
- Plain Dart classes (no code-gen required).
- Separate request models (`toJson()`) and response models (`fromJson(Map<String, dynamic> json)`).
- **Defensive JSON parsing**: Handle backend casing variations (`json['token'] ?? json['Token']`), fallback keys (`json['name'] ?? json['fullName']`), and safe type coercion (`int.tryParse(json['id'].toString())`).

### 6.2 Repositories (`features/<name>/data/repository/`)
- Group related API calls into a feature repository class with `static Future<...>` methods.
- Standard method template:
```dart
class FeatureRepo {
  static Future<List<ItemModel>> fetchItems() async {
    try {
      final token = SharedPref.getToken();
      final response = await DioProvider.get(
        endpoint: Apis.items,
        headers: token.isNotEmpty ? {'Authorization': 'Bearer $token'} : null,
      );

      if (response.statusCode == 200) {
        final list = response.data as List<dynamic>;
        return list
            .map((e) => ItemModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load items.');
      }
    } on DioException catch (e) {
      debugPrint('Dio error (fetchItems): ${e.response?.data ?? e.message}');
      throw Exception(_extractError(e.response?.data, e.message));
    } catch (e) {
      debugPrint('fetchItems error: $e');
      rethrow;
    }
  }

  static String _extractError(dynamic data, String? dioMessage) {
    if (data is String && data.trim().isNotEmpty) return data;
    if (data is Map) {
      for (final key in ['message', 'title', 'error', 'errors']) {
        if (data[key] != null && data[key].toString().trim().isNotEmpty) {
          return data[key].toString();
        }
      }
    }
    return (dioMessage != null && dioMessage.trim().isNotEmpty)
        ? dioMessage
        : 'Server connection error';
  }
}
```
- **Cross-feature reuse**: Feature repositories may compose shared lookup methods from another repository (e.g., `AddAfforestationRepo` delegates lookup fetches to `MangeRepo`) instead of duplicating endpoints.

### 6.3 Cubit & States (`features/<name>/presentation/cubit/`)
1. **State File (`<feature>_state.dart`)**:
   - One `abstract class <Feature>State {}` base class.
   - Standard lifecycle subclasses:
     - `<Feature>InitialState`
     - `<Feature>LoadingState`
     - `<Feature>SuccessState` (carries immutable/unmodifiable data + derived counts)
     - `<Feature>ActionSuccessState(String message)` (for transient toast/SnackBar feedback after create/update/delete, followed immediately by re-emitting `SuccessState`)
     - `<Feature>ErrorState(String message)`
   - For multi-step / cascading forms, add granular states (e.g., `LoadingInitialState`, `InitialSuccessState`, `LoadingSubItemsState`, `SubItemsLoadedState`, `SubmittingState`, `SubmitSuccessState`).

2. **Cubit File (`<feature>_cubit.dart`)**:
   - Extends `Cubit<<Feature>State>`.
   - Stores working state (lists, selected filter values) as fields on the Cubit.
   - Uses `Future.wait([...])` when loading multiple independent endpoints in parallel.
   - Strips `'Exception: '` from caught exceptions before emitting `ErrorState`.
   - Emits `List.unmodifiable(...)` in `SuccessState` to guarantee UI rebuilds and prevent accidental mutation.

### 6.4 Pages & Widgets (`features/<name>/presentation/pages/` & `widgets/`)
- Provide the Cubit either in `AppRouter` or at the root of the page using `BlocProvider(create: (_) => FeatureCubit()..loadInitialData(), child: ...)`.
- Use **`BlocConsumer<FeatureCubit, FeatureState>`** when a screen needs both side effects and UI rebuilds:
  - `listener`: Show `SnackBar` on `ErrorState` / `ActionSuccessState`, or navigate via `context.go(...)` / `pushTo(...)` on success.
  - `builder`: Access cubit via `context.read<FeatureCubit>()`, render loading spinners/shimmers on `LoadingState`, render content on `SuccessState`.
- Always use `GlobalKey<FormState>()` and dispose all `TextEditingController`s in `StatefulWidget.dispose()`.
- Extract complex sections (cards, headers, dropdowns, tables, dialogs) into `features/<name>/presentation/widgets/`.

---

## 7. Key Application Flows in This Architecture

### 7.1 Splash, Auto-Login & Role-Based Routing
1. App opens at `Routes.splash` (`SplashScreen`).
2. After a short delay (checking `if (mounted)`), it inspects `SharedPref.isLoggedIn` and `SharedPref.getCredentials()`.
3. If cached credentials exist, it calls `AuthRepo.login(...)` to refresh the token and user session.
4. On success, it reads `SharedPref.getRole()` and routes with `context.go(...)`:
   - Admin role → `Routes.admin` (`MainLayout`)
   - Standard user role → `Routes.user` (passing `extra` map with user details)
5. If not logged in or auto-login fails → `context.go(Routes.login)`.

### 7.2 Main Shell (`MainLayout` with `IndexedStack`)
- Wraps primary tabs in a `Scaffold` with `IndexedStack(index: _currentIndex, children: _screens)` and a `BottomNavigationBar(type: BottomNavigationBarType.fixed)` so switching tabs **preserves scroll position and Cubit state**.
- Wraps the `Scaffold` in `SafeArea(top: false, child: scaffold)` on Android (`Platform.isAndroid`) to prevent gesture bar overlap.
- Tab-scoped Cubits (like `SearchCubit`) are provided directly around their tab widget inside `_screens`.

### 7.3 CRUD Management Pattern
- Initial load: `getItems()` → `LoadingState` → `SuccessState(items, counts)`.
- Delete: call repo → remove from local list → emit `ActionSuccessState('Deleted')` (triggers SnackBar in listener) → immediately emit updated `SuccessState`.
- Update: call repo → emit `ActionSuccessState('Updated')` → refresh via `await getItems()`.

### 7.4 Cascading Form Pattern
- `loadInitialData()` uses `Future.wait` to populate top-level dropdowns.
- Selecting a parent dropdown (`onParentChanged`) clears dependent selections/lists, emits a granular loading state, fetches child items, and emits child-loaded state.
- `submit()` validates all selections, builds a typed `*RequestModel`, posts via repo, and emits `SubmitSuccessState`.

### 7.5 Search, Filtering & Analytics Pattern
- Cubit holds nullable filter fields (`fromDate`, `toDate`, `selectedUserId`, etc.) and dropdown lists.
- `loadDropdowns()` fetches all filter options in parallel with `Future.wait`.
- `search()` builds `SearchRequestModel` and fetches results into `_allResults` (pagination/grouping handled cleanly on the presentation side or via paginated response model).
- Summary/analytics methods compute totals and distinct counts from the returned dataset and emit dedicated summary states.

---

## 8. Step-by-Step Playbook for Starting a New Project

Follow these phases in order when building the new app:

### Phase 1: Bootstrap
1. Run `flutter create <app_name>`.
2. Add core dependencies to `pubspec.yaml` (`flutter_bloc`, `go_router`, `dio`, `shared_preferences`, `easy_localization`, `google_fonts`, `flutter_svg`, `gap`, `shimmer`).
3. Create `assets/icons/` and `assets/translations/{en.json,ar.json}` and register them in `pubspec.yaml`.

### Phase 2: Build `lib/core/`
1. Create `core/styles/{colors.dart, text_styles.dart, themes.dart}` and `core/constants/{app_assets.dart, app_fonts.dart, app_images.dart}`.
2. Create `core/services/apis/{apis.dart, dio_provider.dart}` and `core/services/local/shared_pref.dart`.
3. Create `core/routes/{routes.dart, app_router.dart}` and `core/functions/{navigations.dart, extensions.dart, validations.dart}`.
4. Create `core/utils/bloc_observer.dart` and baseline `core/widgets/` (`custom_text_form_field.dart`, `custom_svg_picture.dart`, `main_button.dart`, `dialogs.dart`, `my_body_view.dart`).
5. Wire `lib/main.dart` with service initialization, `Bloc.observer`, `EasyLocalization`, and `MaterialApp.router`.

### Phase 3: Foundation Features
1. Implement `features/auth/` (`models`, `repository`, `cubit`, `pages/login_screen.dart`, `pages/register_screen.dart`).
2. Implement `features/splash/` (`splash_screen.dart` with auto-login and role-based routing).
3. Implement `features/dashboard/` (`MainLayout` shell + role-specific home screens).

### Phase 4: Adding Any New Feature (6-Step Checklist)
For every new feature `<feature>`:
1. **Endpoints**: Add route constants to `lib/core/services/apis/apis.dart`.
2. **Models**: Create request/response classes in `lib/features/<feature>/data/models/`.
3. **Repository**: Create `lib/features/<feature>/data/repository/<feature>_repo.dart` using `DioProvider` + `SharedPref.getToken()` + `DioException` error extraction.
4. **Cubit & States**: Create `lib/features/<feature>/presentation/cubit/<feature>_state.dart` and `<feature>_cubit.dart`.
5. **UI**: Create screen(s) in `pages/` and sub-components in `widgets/` using `BlocProvider` + `BlocConsumer`.
6. **Routing**: Add path constant to `Routes` (`routes.dart`) and register `GoRoute` in `AppRouter` (`app_router.dart`).

---

## 9. Conventions & Guardrails for the New Agent

To keep the new codebase cleaner and more consistent than the original reference project, enforce these rules:

1. **Consistent Folder Naming**: Always use `data/models/`, `data/repository/`, and `presentation/{cubit, pages, widgets}/` for **every** feature (do not skip `presentation/` or mix `repo/` vs `repository/` or `page/` vs `pages/`).
2. **Strict Layer Boundaries**:
   - Pages/Widgets must **never** call `DioProvider` directly — always go through `Cubit -> Repository -> DioProvider`.
   - `lib/core/` should stay feature-agnostic (avoid importing feature models inside `core/` where possible; e.g., store raw user JSON maps in `SharedPref` or place the base `UserModel` in `core/models/`).
3. **No Commented-Out Dead Code**: Keep `dialogs.dart`, `main_button.dart`, and `Bloc.observer` active and wired from day one.
4. **Safe Async UI**: Always check `if (!mounted) return;` (or `if (!context.mounted) return;`) before navigating or showing SnackBars after `await`.
5. **Single Source of Truth for Auth Headers**: Consider adding a `Dio` `InterceptorsWrapper` in `DioProvider.init()` to automatically attach `Authorization: Bearer <token>` from `SharedPref.getToken()` so repositories don't repeat header boilerplate on every call.
6. **Clean File & Class Naming**: Use consistent `snake_case` filenames matching their class names (avoid typos like `aurth_repo.dart`, `extenstion.dart`, or `AuthSucess`).
