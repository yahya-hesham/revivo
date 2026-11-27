# Revivo (Flutter) — Backend API Reference

Revivo is a car maintenance and warranty tracker (Egyptian market, EGP and km, English LTR and Arabic RTL).
The backend is in `Backend/Revivo` (.NET 10 Minimal API, SQL Server, Identity + JWT).

- **Local base URL:** `https://localhost:7076` or `http://localhost:5269`. On an Android emulator use `10.0.2.2` instead of `localhost`.
- **Figma:** https://www.figma.com/design/YpH0vEGvFiVez3qJrFoZIh/Revivo-%E2%80%94-Mobile-App-%7C-Complete-UI-UX
- **Full source docs:** `Backend/Revivo/docs/REVIVO_FLUTTER_BACKEND_HANDOFF.md`, `REVIVO_BACKEND_GAPS.md`, `postman/`.

---

## 1. Conventions

| Topic | Rule |
|---|---|
| Auth | Header `Authorization: Bearer <accessToken>`. Only register, login and the car catalog are public. |
| JSON | camelCase. Dates are `YYYY-MM-DD`. Times are `"09:00:00"`. Timestamps are ISO 8601. |
| IDs | Integers, except user ids, which are GUIDs. |
| Currency | `EGP` only. |
| Roles | **Owner** can read and write. **Accepted share** can read only. Anyone else gets **404**. There is no 403. |
| 400 | Validation errors use `{type,title,status,errors:{Field:[msgs]}}`. Some keys are PascalCase (`CarModelId`). Binding errors and two maintenance routes may return a bare or non-JSON 400. |
| 401 | Empty body. Clear the token and go to Login. |
| 404 | Empty body. The resource is missing, or you have no access. |
| 409 | `{ "message": "..." }` |
| 204 | No body. |
| Token | JWT, 60 minutes. No refresh token. Logout is client-side only. |

Legend: 🔓 public · 🔐 any logged-in user · 👑 owner only · 👁 owner or accepted share. `V` = `/api/vehicles/{vehicleId}`.

---

## 2. Authentication

| # | Method & route | Access | Body / params | Success | Errors |
|---|---|---|---|---|---|
| 1 | `POST /api/auth/register` | 🔓 | `{name (1–100), email (≤256), password}` | 201 `{id}` — **no token** | 400 `Name`/`Email`/`Password`; 409 duplicate email |
| 2 | `POST /api/auth/login` | 🔓 | `{email, password}` | 200 `{accessToken}` | 400 `Credentials`; 401 wrong or locked |
| 3 | `GET /api/auth/me` | 🔐 | — | 200 `{id, name?, email?}` | 401 |

## 3. Car catalog

| # | Method & route | Access | Params | Success | Errors |
|---|---|---|---|---|---|
| 4 | `GET /api/car-catalog/makes` | 🔓 | `search?` | `[{id, name}]` | — |
| 5 | `GET /api/car-catalog/models` | 🔓 | `makeId` (required), `search?` | `[{id, carMakeId, name, yearStart?, yearEnd?}]` | 400 `makeId` |
| 6 | `GET /api/car-catalog/models/{modelId}/years` | 🔓 | — | `[2026, 2025, …]` (descending) | 400 |
| 7 | `GET /api/car-catalog/car-image` | 🔓 | `modelId`, `year` | `CarImage` (see below) | 400; 404 unknown model |

**`CarImage`:** `{status, imageUrl?, photographerName?, photographerUrl?, photoUrl?, unsplashUrl?, isExactVehicle, message}`.
`status` is `found`, `noImage`, `rateLimited`, `notConfigured` or `unavailable`.
Always HTTP 200. If the status is not `found`, show a local placeholder. If it is `found`, show the photographer credit and links. The photo is illustrative, not the exact car.

> Picker flow: make → model → year. Vehicle creation uses the **model id**.

## 4. Vehicles (garage)

`Vehicle` = `{id, ownerId, carModelId, year, currentMileageKm, nickname?, imageUrl?, createdAt}`.
It has no make or model name, so look those up from the catalog.
Owned or shared: compare `ownerId` with `/auth/me`, or use the two list endpoints.

| # | Method & route | Access | Body | Success | Errors |
|---|---|---|---|---|---|
| 8 | `POST /api/vehicles` | 🔐 | `VehicleInput` = `{carModelId, year (1886..next yr), currentMileageKm ≥0, nickname? ≤100, imageUrl? ≤2048}` | 201 `Vehicle` | 400 |
| 9 | `GET /api/vehicles` | 🔐 | — | `Vehicle[]` owned, newest first | — |
| 10 | `GET /api/vehicles/{id}` | 👁 | — | `Vehicle` | 404 |
| 11 | `PUT /api/vehicles/{id}` | 👑 | full `VehicleInput` | `Vehicle` | 400 (mileage below the highest service mileage); 404 |
| 12 | `DELETE /api/vehicles/{id}` | 👑 | — | 204 | 404; 409 "Delete maintenance records first" |
| 13 | `GET /api/vehicles/shared` | 🔐 | — | `Vehicle[]` accepted shares | — |

## 5. Odometer

| # | Method & route | Access | Body / params | Success | Errors |
|---|---|---|---|---|---|
| 20 | `POST V/odometer` | 👑 | `{mileageKm}` (≥ current mileage) | `{readingId, vehicleId, currentMileageKm, recordedAt}` | 400 `mileageKm`; 404 |
| 21 | `GET V/odometer/history` | 👁 | `page?=1`, `pageSize?=20` (1–100) | `{items:[{id, vehicleId, mileageKm, recordedAt, recordedByUserId}], page, pageSize, totalCount}` | 400; 404 |

The server sets the time, so there are no backdated readings. After a check-in, refetch the vehicle, status, alerts and statistics.

## 6. Maintenance records (service history)

`Maintenance` = `{id, vehicleId, itemId, category, itemName, maintenanceDate, mileageKm, costEgp, notes?, createdAt}`.
`MaintenanceInput` = `{category (1–100), itemName (1–100), maintenanceDate (1886..today), mileageKm ≥0, costEgp ≥0 (2 decimals), notes? ≤2000}`.
Category and item name are **free text**. There is no catalog endpoint, so any suggestions must be built locally.

| # | Method & route | Access | Params | Success | Errors |
|---|---|---|---|---|---|
| 22 | `POST V/maintenance` | 👑 | `MaintenanceInput` | 201 `Maintenance` | 400; 404 |
| 23 | `GET V/maintenance` | 👁 | `page?`, `pageSize?` | `{page, pageSize, totalCount, items:Maintenance[]}` | 400; 404 |
| 24 | `GET V/maintenance/{id}` | 👁 | — | `Maintenance` | bare 400; 404 |
| 25 | `PUT V/maintenance/{id}` | 👑 | full `MaintenanceInput` | `Maintenance` | 400; 404 |
| 26 | `DELETE V/maintenance/{id}` | 👑 | — | 204 | 404; 409 "Delete the warranty first" |

A record raises the vehicle's mileage to `max(current, record mileage)` but does not add an odometer reading.

## 7. Periodic maintenance (schedules)

`ScheduleInput` = `{intervalKm?, intervalMonths? (1–1200), warningKm? ≥0, warningDays? ≥0}`. The default warnings are 1000 km and 30 days.

`MaintenanceStatus` = `{itemId, category, itemName, intervalKm?, intervalMonths?, warningKm, warningDays, lastMaintenanceDate?, lastMaintenanceMileage?, nextDueDate?, nextDueMileageKm?, remainingDays?, remainingKm?, status}`.
`status` is `OnTrack`, `DueSoon` or `Overdue`.

| # | Method & route | Access | Success |
|---|---|---|---|
| 27 | `PUT V/maintenance-items/{itemId}/schedule` | 👑 | `MaintenanceStatus` (the item needs a record or schedule first) |
| 28 | `GET V/maintenance-status` | 👁 | `MaintenanceStatus[]` |
| 29 | `GET V/upcoming-maintenance` | 👁 | `MaintenanceStatus[]` (DueSoon and Overdue only, overdue first) |

The backend calculates all due values, so the app only displays them. If there is no schedule or no last service, the due fields are null. Show "No next service set", not "OK".
Save order: record → schedule (using the returned `itemId`) → warranty. If a later step fails, retry only that step.

## 8. Warranties

`WarrantyInput` = `{durationMonths (1–1200), startDate? (default: service date), warningDays? (default 30), provider? ≤150, brand? ≤150, notes? ≤2000}`.
`Warranty` = `{maintenanceRecordId, vehicleId, itemId, itemName, durationMonths, startDate, expirationDate, warningDays, remainingDays, status, provider?, brand?, notes?, createdAt}`.
`status` is `Active`, `ExpiringSoon` or `Expired`.

| # | Method & route | Access | Success |
|---|---|---|---|
| 30 | `PUT V/maintenance/{recordId}/warranty` | 👑 | 201 (new) or 200 (update) `Warranty` |
| 31 | `GET V/warranties` | 👁 | `Warranty[]` sorted by expiration |
| 32 | `GET V/maintenance/{recordId}/warranty` | 👁 | `Warranty` (404 if none) |
| 33 | `DELETE V/maintenance/{recordId}/warranty` | 👑 | 204 |

## 9. Statistics

| # | Method & route | Access | Params | Success |
|---|---|---|---|---|
| 37 | `GET V/statistics/overview` | 👁 | — | `{vehicleId, currentMileageKm, thisMonthDistanceKm?, thisMonthDistanceStatus, thisMonthIsPartial, thisYearDistanceKm?, thisYearDistanceStatus, thisYearIsPartial, averageMonthlyDistanceKm?, lifetimeMaintenanceCost, thisMonthMaintenanceCost, thisYearMaintenanceCost, maintenanceOperationsCount, currency}` |
| 38 | `GET V/statistics/mileage` | 👁 | `year?` | `{vehicleId, year, currentMileageKm, totalYearDistanceKm?, totalYearDistanceStatus, isPartial, averageMonthlyDistanceKm?, monthlyDistanceKm:[{month, distanceKm?, status, isPartial}] ×12}` |
| 39 | `GET V/statistics/expenses` | 👁 | `year?` | `{vehicleId, year, totalExpenses, maintenanceOperationsCount, currency, monthlyExpenses:[{month, amountEgp, operationsCount}] ×12, expensesByCategory:[{category, amountEgp, operationsCount}], topExpensiveMaintenanceRecords:[{id, maintenanceDate, category, itemName, costEgp}] ≤5}` |

- Distance `status` is `Exact`, `Estimated` or `Unavailable`. **A null distance means no data, not 0.** Label estimated and partial values.
- Mileage stats use odometer readings only. Expenses are grouped by maintenance date.

## 10. Notifications and alerts

| # | Method & route | Access | Body | Success |
|---|---|---|---|---|
| 34 | `GET V/notification-settings` | 👁 | — | `NotificationSettings` (defaults: `id:0`, weekly off, Monday `1`, `09:00:00`, `UTC`, both alerts on) |
| 35 | `PUT V/notification-settings` | 👑 | `{weeklyReminderEnabled, reminderDayOfWeek 0–6, reminderTime, timeZoneId, maintenanceAlertsEnabled, warrantyAlertsEnabled}` | `NotificationSettings` (+ `id`, `vehicleId`, `userId`) |
| 36 | `GET V/alerts` | 👁 | — | `{vehicleId, maintenance:MaintenanceStatus[], warranties:Warranty[]}` |

Alerts are calculated on request. There is no push, no scheduled reminders, no read/unread state and no global alerts endpoint, so the app combines the per-vehicle alerts itself.

## 11. Sharing (read-only access)

`VehicleShare` = `{id, vehicleId, invitedUserId, invitedUserEmail, invitedByUserId, status (Pending|Accepted|Rejected), createdAt, respondedAt?}`.

| # | Method & route | Access | Body | Success | Errors |
|---|---|---|---|---|---|
| 14 | `POST V/shares` | 👑 | `{email}` (registered user, not yourself) | 201 `VehicleShare` | 400 `email`; 409 already invited |
| 15 | `GET V/shares` | 👑 | — | `VehicleShare[]` (pending and accepted) | 404 |
| 16 | `DELETE V/shares/{shareId}` | 👑 | — | 204 | 404 |
| 17 | `GET /api/vehicle-invitations` | 🔐 | — | `VehicleShare[]` (pending, addressed to me) | — |
| 18 | `POST /api/vehicle-invitations/{shareId}/accept` | 🔐 | — | `VehicleShare` | 404; 409 no longer pending |
| 19 | `POST /api/vehicle-invitations/{shareId}/reject` | 🔐 | — | `VehicleShare` | 404; 409 |

No invitation email is sent. The invitee sees the invitation in the app. Shared users must see a read-only badge, and the app must handle a 404 if access is revoked mid-session.

---

## 12. Not available in the backend
Forgot or reset password · refresh token and server logout · profile edit and account delete · image upload (URL only) · saved photo credit · push or scheduled reminders · alert read/dismiss state · backdated odometer readings · maintenance item catalog.

## 13. User journeys
1. **New owner:** Register → Login (store token) → pick make/model/year → create vehicle → record service → optional schedule and warranty → odometer and stats.
2. **Invitee:** Login → invitations → accept → shared vehicles (read-only).

---

## 14. Flutter stack and architecture (proposed, for your approval)

**Already in `pubspec.yaml`:** `flutter_bloc`, `dio`, `flutter_svg`, `google_fonts`.

| Need | Proposed package |
|---|---|
| State management | `flutter_bloc` (Cubits for simple screens) |
| HTTP | `dio` with an auth interceptor that adds the token and handles 401 |
| Navigation | `go_router` (auth redirect, nested vehicle routes) |
| Token storage | `flutter_secure_storage` |
| Models | Plain Dart classes or `json_serializable`, plus `equatable` |
| Dependency injection | `get_it` |
| Charts | `fl_chart` |
| Localization (EN/AR, RTL) | `flutter_localizations` + `intl` (ARB files) |
| Images | `cached_network_image` |
| Links (Unsplash credit) | `url_launcher` |
| Dates and numbers | `intl` |
| Tests | `bloc_test`, `mocktail` |

**Folder layout (feature-first):**
```
lib/
  app/        router, theme, app widget
  core/       network (dio, interceptors), storage, errors, shared widgets, di
  features/
    auth/ garage/ maintenance/ warranties/ odometer/
    statistics/ alerts/ sharing/ profile/
      data/          models, remote data source, repository
      presentation/  cubit/bloc, pages, widgets
```
Data flows `UI → Cubit → Repository → Dio`. Each screen handles loading, error, empty and success states.

**Build order:** Foundation (theme from Figma, Dio, storage, router) → Auth → Garage and add vehicle → Maintenance, schedules, warranties → Odometer and statistics → Alerts and sharing → Arabic/RTL and polish.
</Content>
</invoke>
