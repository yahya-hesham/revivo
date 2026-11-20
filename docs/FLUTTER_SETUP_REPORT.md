# Flutter setup report

Audit date: 16 November 2026. Scope: setup and discovery only. No feature screens or API workflows were implemented.

## Environment audit

| Check | Verified result |
| --- | --- |
| Flutter | 3.38.5, stable, framework revision `f6ff1529fd` |
| Dart | 3.10.4, stable |
| `flutter doctor -v` | Flutter, Xcode, Chrome, connected desktop/web targets, and network resources passed. Android toolchain warned that some SDK licenses are unaccepted. |
| Android | SDK 36.1.0, platform android-36, build tools 36.1.0, emulator 36.3.10.0; Java 25.0.1. No Android device was reported by doctor. |
| iOS | Xcode 26.2, CocoaPods 1.17.0, deployment target 15.0. No iOS simulator was reported by doctor. A direct `simctl` check failed to connect to CoreSimulatorService in this execution environment. |
| Connected targets | macOS desktop and Chrome web only. Mobile-device runtime has not been verified. |
| Git | Clean `main` tracking `origin/main` before changes. No branch switch, commit, or push. |

Initial Flutter commands inside the restricted sandbox failed writing `/usr/local/share/flutter/bin/cache/engine.stamp`; the required diagnostics were rerun with SDK-cache access. The first `flutter pub get` failed because `pubspec.yaml` required Dart `^3.13.7` while installed Dart was 3.10.4. After lowering the SDK constraint, resolution identified `google_fonts` 9.0.0 as also requiring Dart 3.13. The compatible 8.2.1 release resolved successfully.

## Existing project

`lib/main.dart` renders a Hello World placeholder. `lib/core/` contains static design tokens, English Geist and Arabic Noto Sans Arabic text styles, SVG paths, a Bloc observer, and a static Dio wrapper. The wrapper has 10-second timeouts but its base URL is empty; it is not initialized or used by the app. No route table, feature modules, authentication state, token storage, localization, or API error handling are implemented. `analysis_options.yaml` includes `flutter_lints` and excludes generated platform directories. `assets/icons/` has SVGs. No packaged font files exist; typography currently uses `google_fonts` runtime package. There were no Flutter tests or `test/` directory. The iOS project has a template Runner test target, but no Flutter tests.

Current dependencies: `dio`, `flutter_bloc`, `flutter_svg`, `google_fonts`; dev dependencies: `flutter_lints`, `flutter_test`. Existing Bloc and Dio are practical choices. Riverpod would duplicate the current state-management direction, so retain Bloc unless implementation reveals a reason to change. `go_router` and `flutter_secure_storage` are candidates for the first feature milestone, after routing and auth requirements are fixed. Use manual JSON mapping initially; add `json_serializable` only if DTO volume warrants generated code.

Android `INTERNET` is declared in debug/profile manifests, not the main manifest; release networking will need it. Android identifiers and iOS bundle ID are still `com.example.revivo`. iOS `Info.plist` has no App Transport Security exception. The Android and iOS project files are otherwise Flutter templates; platform builds were not run.

## Figma readiness

The backend handoff identifies the **new** file as [Revivo — Mobile App | Complete UI/UX](https://www.figma.com/design/YpH0vEGvFiVez3qJrFoZIh). The connected Figma account authenticated, and a read-only metadata call returned all eight pages: Product Overview, Design System, Onboarding & Authentication, Garage & Vehicle Management, Maintenance & Warranties, Mileage & Statistics, Notifications & Sharing, and Interactive Prototype. Page-level metadata was read for the seven design/prototype pages. The old file was not accessed.

The handoff documents 51 feature screens, one Arabic RTL specimen, 43 prototype frames, 27 components, four variant sets, and light/dark variable modes. The Figma metadata confirms reusable button, field, status, card, navigation, and chart components and 390 × 844 mobile frames. The intended navigation is Garage, Alerts, Account; within a vehicle: Overview, History, Insights. Design typography is **Manrope** with Noto Sans Arabic. Current Flutter tokens use **Geist** and an earlier teal palette, so they must be reconciled against this new design before implementation. The design has two dark screen variants, not a complete dark-screen set. Responsive behavior, dynamic text scaling, safe areas, keyboard handling, native RTL, and screen-reader behavior still need Flutter validation. Prototype fields are scripted, not live interactions. See the backend handoff for detailed UI caveats.

## Backend integration readiness

The backend was found read-only at `/Users/macbookpro/Revivo`. Its `docs/MOBILE_DESIGN_HANDOFF.md`, Postman collection, and API endpoint files were inspected; routes are real, but no Flutter DTO mapping has been implemented. The backend's former `https://localhost:7076` URL is not portable: iOS Simulator can generally reach host loopback, Android Emulator requires host mapping (commonly `10.0.2.2`), and a physical device needs a reachable development host and trusted certificate. Verify each target rather than embedding an address. Use a build-time `--dart-define=API_BASE_URL=...` value, with a validated nonempty URL and no credentials in source control. Keep HTTPS certificate validation enabled. For local TLS, establish platform trust for the development certificate; if a temporary HTTP development profile is needed, scope platform exceptions to that build and host.

At implementation time, add Android release internet permission, one Dio client with JWT bearer interceptor, secure token storage, request timeouts, API error mapping, and a single 401-to-sign-in transition that clears expired credentials. Do not log tokens. There is no mapped refresh-token or server logout endpoint. Registration returns an ID, then requires login. Notification delivery is not yet implemented on the backend.

## Changes and command results

- `pubspec.yaml`: SDK constraint `^3.13.7` → `^3.10.4`; `google_fonts` `^9.0.0` → `^8.2.1` to match installed Dart. `pubspec.lock` was regenerated by successful `flutter pub get`.
- `flutter pub get` also generated `ios/Podfile` and `macos/Podfile` and added optional CocoaPods includes to the iOS/macOS Flutter xcconfig files. These are Flutter tooling changes; native builds still need verification.
- Added `assets/images/.gitkeep` because `pubspec.yaml` already declared that missing asset directory.
- `flutter --version`: passed, Flutter 3.38.5 / Dart 3.10.4.
- `flutter doctor -v`: completed with Android-license warning, as above.
- `flutter pub get`: initially failed twice due SDK/package constraints, then passed.
- `flutter analyze`: initially reported missing `assets/images/`, then passed with **No issues found**.
- `flutter test`: failed with `Test directory "test" not found.` No tests were invented solely to make the command green.
- No Android/iOS build or emulator launch was verified.

## Remaining blockers

Accept Android SDK licenses; start and verify an Android emulator and iOS simulator; run platform builds; establish a trusted local API connection per target. Confirm the new design tokens and flows against detailed Figma context before coding. Add genuine tests with the first behavior. Decide the final app IDs before distribution. The Flutter project is ready for the first implementation milestone at the source-analysis level, but mobile runtime and API connectivity are not yet proven.
