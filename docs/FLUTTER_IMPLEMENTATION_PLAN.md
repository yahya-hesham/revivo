# Flutter implementation plan

## Architecture and package decisions

Use a feature-first layout: `lib/app/` for app composition, router and theme; `lib/core/` for network, secure storage, errors, and truly shared widgets; `lib/features/` for authentication, garage, maintenance, warranties, mileage, statistics, notifications, sharing, and profile. Within a feature, use `presentation/` and `data/`; add `domain/` only for substantial business rules. Keep API models and mappers close to their feature. Avoid generic repository layers until duplication proves they help.

Retain **flutter_bloc** for state management and **Dio** for HTTP; both are already declared. Add **go_router** when implementing guarded navigation, and **flutter_secure_storage** when implementing JWT persistence. Consider `json_serializable` only after reviewing actual DTO count and shape. Keep `flutter_svg`. Align fonts with the new Figma Manrope/Noto Sans Arabic design; current Geist tokens are stale. Do not add Firebase or notification-delivery dependencies yet. No new packages were installed during discovery.

## Navigation

Entry: Welcome → Register or Login → Garage. Authenticated shell: Garage, Alerts, Account. Vehicle context: Overview, History, Insights, with nested actions for maintenance, recurring service, warranties, mileage, and sharing. Store selected vehicle identity in route state/path so deep links and back behavior are predictable. Gate owner write actions for shared read-only vehicles. Expired JWT redirects to Login after clearing local credentials.

## Feature and API map

| Feature | Verified route family |
| --- | --- |
| Authentication/profile | `POST /api/auth/register`, `POST /api/auth/login`, `GET /api/auth/me` |
| Garage/catalog/images | `GET/POST /api/vehicles`, `GET/PUT/DELETE /api/vehicles/{vehicleId}`, `/api/car-catalog/makes`, `/models`, `/models/{modelId}/years`, `/car-image` |
| Maintenance | `GET/POST /api/vehicles/{vehicleId}/maintenance`, `GET/PUT/DELETE .../maintenance/{id}` |
| Periodic service | `PUT .../maintenance-items/{itemId}/schedule`, `GET .../maintenance-status`, `GET .../upcoming-maintenance` |
| Warranties | `GET .../warranties`, `GET/PUT/DELETE .../maintenance/{recordId}/warranty` |
| Mileage | `POST .../odometer`, `GET .../odometer/history` |
| Statistics | `GET .../statistics/overview`, `/mileage?year=...`, `/expenses?year=...` |
| Alerts/settings | `GET .../alerts`, `GET/PUT .../notification-settings` |
| Sharing | `GET/POST .../shares`, `DELETE .../shares/{shareId}`, `GET /api/vehicles/shared`, `GET /api/vehicle-invitations`, `POST .../{shareId}/accept` or `/reject` |

Use actual request and response contracts from `/Users/macbookpro/Revivo/postman/Revivo.postman_collection.json` and backend DTOs when each feature begins. The route table alone is not a DTO specification. Registration does not return a JWT. Maintenance record, schedule, and warranty are separate saves; preserve partial-success state and retry only failed steps. Analytics include partial/confidence fields; do not render missing mileage as zero. Sharing separates owned and shared lists and prohibits writes for accepted shared access.

## Milestones and screen order

1. **Foundation (small/medium):** reconcile new Figma tokens; app theme and localization shell; `--dart-define` API config; Dio client, secure storage, auth-aware router; Android release internet permission. Verify a minimal real API request on simulator and emulator.
2. **Identity and garage (medium):** Welcome, Register, Login, Garage empty/list, catalog selection, add vehicle, vehicle overview. Establish loading/error/empty patterns.
3. **Core care (large):** maintenance history/detail/record/edit, recurring schedule/status, warranty forms and details. Handle partial saves and conflicts.
4. **Mileage and insights (medium/large):** odometer update/history, overview stats, expense and driving charts with accessible data lists and partial-period labels.
5. **Alerts and sharing (medium/large):** vehicle alerts, owner-only preferences, invite/accept/reject/revoke, shared read-only views.
6. **Polish (medium):** dark-theme coverage, Arabic/English localization and RTL, safe areas, text scaling, keyboard, accessibility, image attribution, device QA.

## Testing and acceptance

Add focused unit tests for nontrivial mapping and state transitions; widget tests for auth gating, form validation, loading/errors, and owner versus shared controls; integration tests for the critical login → vehicle → maintenance path against a controlled API fixture. Run `flutter analyze`, `flutter test`, Android and iOS debug builds, and manual checks on both mobile platforms. No Flutter tests exist yet; add them alongside behavior rather than placeholder assertions.

## Open requirements

- Confirm exact DTOs and error envelopes against backend code or a running OpenAPI document before API integration.
- Verify local API host routing and certificate trust separately on iOS Simulator, Android Emulator, and physical devices.
- Confirm all new design token values, illustrations/export rights, dark variants, and interaction details from the Figma file. Only page structure was inspected in this audit.
- Validate Arabic copy and RTL behavior with a native speaker; the design currently has one Arabic specimen.
- The backend has no push delivery, password reset, refresh token, account editing, or persisted alert-read state. Avoid promising those flows in the app.
- Determine durable attribution for saved Unsplash vehicle images; backend vehicle DTO stores URL without photographer credit.
