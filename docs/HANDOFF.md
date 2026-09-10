# Handoff — BizOps 360 mobile roadmap

State of the repo and the queued work. Read [`CLAUDE.md`](../CLAUDE.md) first for
architecture and conventions; this doc is the where-we-are / what-next.

**Product decision (2026): one multi-tenant Flutter app, Travel Agency first,
GetX.** One login, one application. It adapts by
`tenant → industry → role → permissions → enabled features`. The primary
dashboard and bottom nav are travel-focused; the common platform (HR, tasks,
CRM, finance, documents) is reached through role-aware **More / Workspace**
navigation. No separate apps per role.

---

## 1. What exists now

The **scaffold + email sign-in flow**, nothing feature-specific yet.

| Area | Status |
|---|---|
| Project | Flutter 3.38 / Dart 3.10, GetX + Dio. Platforms: **android, ios, web**. |
| Architecture | Layered: View → Controller → (Use Case) → Repository (`Result<T>`) → DataSource → `ApiClient` (Dio). Pure-Dart `domain/`. |
| Theme | `AppColors` `ThemeExtension` (light + dark, from the mockup). Light/Dark/System via `SettingsController`. Bricolage Grotesque / Public Sans / IBM Plex Mono / Hind Siliguri via `google_fonts`. |
| i18n | GetX translations `en_US` + `bn_BD`, `Tr.*` keys. Toggle persists. |
| Auth | `POST auth/login` → per-device Sanctum token in the keychain; splash validates a stored token against `GET auth/me`; `AuthController` holds the session; a 401 (outside login) ends the session once, centrally. |
| Shell | `NavigationBar` currently assembled from `user.roles` + `user.tenant.industry` (Home / Tasks / Desk\|CRM / Insights / More). **To be reworked** to the permission-driven travel nav — see §3 M2. |
| Home | Scaffold-stage: greets the user, lists roles + permissions, language / theme / sign-out. Real travel dashboard comes in M2/M4. |
| Tests | `flutter test` — 10 passing (auth mappers, `DioException`→`Failure`, `StatusPill` light/dark). `test/flutter_test_config.dart` disables google_fonts network fetch. |
| CI | `.github/workflows/ci.yaml` — `dart format --set-exit-if-changed` → `flutter analyze --fatal-infos` → `flutter test`. Green on `main`. |

### Structure migration (do this as its own PR, early in M0)

The repo still uses the old `lib/app/` + `lib/features/` layout. Move to the
layout in [`CLAUDE.md`](../CLAUDE.md):

- `lib/app/routes/` → `lib/core/routing/`
- `lib/app/bindings/initial_binding.dart` → `lib/application/` (rename `AppBinding`)
- `lib/features/auth|settings` cross-cutting controllers → `lib/application/{auth,session,tenant,permissions,navigation}/`
- `lib/features/<common>/` → `lib/presentation/<common>/`
- travel features (none yet) → `lib/modules/travel/<area>/`
- add `lib/domain/usecases/`, `lib/core/permissions/`, `lib/core/extensions/`,
  `lib/core/constants/`, `lib/core/utils/`

Keep it mechanical — imports + paths only, no behaviour change, tests stay green.

**Design source of truth:** the approved mockup artifact (hangar-green ink,
terminal-grey ground, wayfinding amber; the 14 key screens).

---

## 2. Running it on Windows

### One-time
1. Install Flutter 3.38.x, Android Studio + SDK + an emulator (Pixel, API 34+).
2. `git clone https://github.com/mahbub06ru4/bizops360-mobile.git`
3. `flutter pub get`
4. `flutter doctor` — clear the Android toolchain / licence items.
   > A Java 21 / Gradle 8.x mismatch surfaced on macOS. If Windows shows it,
   > install JDK 17 and point Android Studio at it, or bump
   > `android/gradle/wrapper/gradle-wrapper.properties`. The web build is
   > unaffected.

### Day to day
```bash
flutter run                                                   # Android emulator → host localhost (http://10.0.2.2)
flutter run --dart-define=API_BASE_URL=http://192.168.0.x      # physical Android device → PC LAN IP
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost
```
`API_BASE_URL` is **origin only** — `Env` appends `/api/v1`.

### The backend
`bizops360-api` is a separate repo (Laravel + Sail). Demo logins after
`php artisan migrate:fresh --seed`: `owner@wanderlust.test` /
`manager@wanderlust.test` / `staff@wanderlust.test`, password `password`
(`wanderlust` = travel tenant; `skyline` = real estate). Live endpoints today:
login / me / logout. Activation, password-reset, `/me/bootstrap`, `/devices` are
**7a backend work, not built yet**.

---

## 3. Work queue

### Working style: UI-first, API last

Screens and controllers are built now, on Windows, without the backend. Each
feature defines its **domain entities + repository interface + a
`FakeXRepository`** (canned data shaped like the documented API envelope, seeded
from the mockup). `Env.useFakeData` (default **on** for non-prod;
`--dart-define=USE_FAKE_DATA=false` to disable) makes the feature binding pick
the fake or the real `XRepositoryImpl`.

So the flow per feature is: entities → repo interface → **fake impl + UI +
controller + all states + tests** (reviewable on device immediately) → real
`XRepositoryImpl` + datasource + mappers (verified on the Mac against a running
`bizops360-api`). Flipping `USE_FAKE_DATA` changes only the binding — never a
controller, screen, or test. This does not change the milestone order below; it
just means the "real impl" half of each slice can trail the UI half.

Build in milestone order. Every PR: `dart format` clean, `flutter analyze
--fatal-infos` clean, `flutter test` green, new strings `en` + `bn`, new screens
in light + dark with loading / empty / error / refresh (+ pagination) states,
permission-gated where the backend gates it.

### 7a — Backend first (in `bizops360-api`, Laravel — not mobile work)
In `app/Modules/Identity`:
- **Account activation**: admin creates `status = invited`; email a signed link;
  `POST /api/v1/auth/activate` (token + password) → active + token.
- **Password reset** (`auth/forgot-password`, `auth/reset-password`).
- **`GET /api/v1/me/bootstrap`** — one payload: user, tenant, roles, permissions,
  `industry`, **enabled features**, unread notification count, feature flags.
  The app calls this after login and on resume instead of `auth/me`.
- **`POST /api/v1/devices`** — register an FCM token; `DELETE` on sign-out.
- **Sessions**: `GET /auth/sessions`, `DELETE /auth/sessions/{id}`.
- Attendance endpoint: accept a client timestamp + lat/long + idempotency key
  (offline-queued check-ins).

---

### M0 — Flutter foundation
Bring the scaffold up to the target architecture.

1. **Structure migration** (see §1) — mechanical move, one PR. ✅ done
2. **Responsive sizing** — `flutter_screenutil` wired via `ScreenUtilInit` in
   `app/app.dart` (design frame 375 × 812). ✅ done. Remaining: express the
   design tokens in `.w` / `.r` / `.sp` so widgets read tokens, not raw units.
3. **Fake-data switch** — `Env.useFakeData` added. ✅ done. Remaining: a
   `FakeRepository` convention + example, and per-feature bindings that branch
   on it.
4. **Design tokens** — `AppSpacing` / `Gap`, `AppRadius` / `AppElevation` in
   `core/theme/` (screenutil units). ✅ done. `AppColors` already carries the
   status pairs. Replace remaining magic numbers as screens are touched.
5. **Common widget library** (`core/widgets/`, barrel `widgets.dart`) —
   ✅ `AppButton`, `AppTextField`, `AppCard` / `AppSectionLabel`,
   `AppStatusChip`, `AppLoader`, `AppEmptyState`, `AppErrorState`,
   `AppNetworkError`, `AppAvatar`, `AppBadge`, `AppShimmer`, and the
   `AppSnackbar` / `AppDialog` / `AppBottomSheet` helpers. Tests in
   `test/widgets/common_widgets_test.dart` via `test/support/test_host.dart`
   (`pumpInHost` = theme + `ScreenUtilInit` + translations).
   Still to add when first needed: `AppDropdown`, `AppSearchField`,
   `AppPagination` (infinite-scroll list footer).
6. **Permissions layer** — `core/permissions/`: a permission-name catalogue, a
   pure `PermissionResolver`, and a `Can(permission, child, fallback)` widget.
   `application/permissions/PermissionsController` exposes it.
7. **Use-case layer** — introduce `domain/usecases/`; migrate the auth flow
   (`SignIn`, `LoadSession`, `SignOut`) to call use cases from the controller.
8. **Routing + guard** — `core/routing/`: named routes, `GetPages`,
   `RouteGuard` (redirect to sign-in when no session).
9. **Logger + BDT formatter** — `core/utils/`, `core/extensions/` (`৳`, 2-2-3,
   lakh/crore).

### M1 — Auth & context
1. **Bootstrap** — `AuthRepository.bootstrap()` → `GET /me/bootstrap`; add a
   `Bootstrap` entity (user, tenant, roles, permissions, industry, enabled
   features, unread count). Call it after login and on resume; keep `auth/me`
   as the token-validity probe.
2. **Tenant/industry context** — `application/tenant/TenantContext`
   (`isTravel`, `industry`, `enabledFeatures`).
3. **Activation & password reset** screens (once 7a ships): activation-link
   landing (`auth/activate`), forgot / reset password.
4. **Sessions** — list active devices, revoke (`/auth/sessions`).

### M2 — Core workspace
1. **Permission-driven shell** — rebuild `application/navigation/ShellController`
   to emit `Home | Customers | Visa | Tasks | More` for a travel tenant,
   filtered by permissions + enabled features; **More / Workspace** hosts the
   role-aware common capabilities. Retire the fixed Desk/CRM/Insights tabs.
   New `Tr` keys: `nav.customers`, `nav.visa`, `nav.workspace`; deprecate
   `nav.desk` / `nav.crm` / `nav.insights` / `nav.team` from the bar.
2. **Travel Home dashboard shell** — `presentation/home/`: a section registry
   over reusable `DashboardSection` widgets. Ships with generic sections
   (my tasks, notifications, quick actions); travel sections land in M4.
3. **Notifications** (`presentation/notifications/`) — list
   (`GET /api/v1/notifications`), mark read, grouped Today / Earlier, unread
   badge on the app bar, deep-link routing stub.
4. **Profile & Settings** (`presentation/profile`, `presentation/settings`) —
   profile view/edit, theme mode (Light/Dark/System), language, sign-out,
   app-lock placeholder.
5. **Tasks** (`presentation/tasks/`) — My tasks (Today / Overdue / Upcoming),
   detail (one-tap status, subtasks + progress, comments thread, attachments).
   Manager: assign / reassign / create. Backend: `app/Modules/Operations`.
6. **Attendance + Leave** (`presentation/attendance`, `presentation/leave`) —
   check-in / check-out with geolocation (`geolocator`), optional selfie
   (`image_picker`), today's status, week bars, history. **Offline queue**:
   persist unsent check-ins in `KvStore`/Hive, flush on connectivity
   (`connectivity_plus`), idempotency key per item. Leave: request form, balance,
   my requests + status, holiday calendar; manager approve / reject with a note.
   Backend: `app/Modules/HR`.
7. **Documents** (`presentation/documents/`) — list per employee/customer,
   categories, expiry flags, upload / download via signed URLs.

### M3 — Common business features
1. **CRM / customers** (`presentation/crm/`) — pipeline (stage chips → filtered
   lead cards), lead / customer detail + history, contacts, activities, notes.
   In **More** unless a travel tenant promotes it. Backend: `app/Modules/CRM`.
2. **Follow-ups** — Today / Overdue / Upcoming with an outcome sheet, quick-add.
   Also feeds a Home dashboard section.
3. **Expenses** (`presentation/expenses/`) — submit with a receipt photo
   (category chips, amount in mono, date, note); my submitted expenses + status;
   manager approve / reject. Backend: `app/Modules/Finance` — Expense.

### M4 — Travel agency (`modules/travel/`, gated on `TenantContext.isTravel`)
1. **Travel customers & passengers** — search, profile, passenger info, travel
   history.
2. **Passport** — passport records, expiry tracking.
3. **Visa** — visa types; **applications** queued by stage
   (`Case → Docs Required → Docs Collected → Submitted → Processing → Approved/Rejected`);
   a document checklist whose completion gates "submit"; stage moves; decision.
4. **Visa documents & deadlines** — pending-documents list, deadline reminders;
   feeds Home sections "visa application summary" + "pending visa documents".
5. **Travel operations** — bookings (list, quick create, PNR / segments / hotel /
   itinerary, issue / cancel), departures board, ticket tasks. Payments /
   commissions where in MVP scope.
6. **Travel dashboard sections** (`modules/travel/dashboard/`) — register the
   visa / follow-up / ticket-task / KPI sections into `presentation/home`.
   Backend: `app/Modules/Industry/Travel` (routes are `industry:travel` gated —
   a non-travel token gets 403, matching the app-side gate).

### M5 — Role / permission UX
- Validate the real Travel Agency roles (owner / manager / agent / visa officer /
  ticketing / accounts …) against nav, action visibility, dashboard sections.
- Verify every gated action also fails closed on the backend (403 handling).
- Cross-check `enabledFeatures` toggles hide whole nav branches cleanly.

### M6 — Production mobile
- Crash reporting + APM (Sentry / Firebase Crashlytics), after 7a `/devices`.
- Performance pass, secure-storage review, list pagination + response caching.
- Push notifications (FCM) + deep links from notification payloads.
- Force-update / maintenance banner from a bootstrap flag.
- App-lock (biometric) in Profile (`local_auth`).
- CI/CD to store tracks; store listing readiness.

### Cross-cutting (fold in as you go)
- `flavor.dart` staging config + `--flavor` story for Android/iOS if needed.
- Firebase (FCM + Crashlytics) wiring — after 7a `/devices`.
- Keep `intl` BDT helper (`৳`, 2-2-3, lakh/crore) in one place.

---

## 4. Gotchas

- **`google_fonts` fetches fonts at runtime** in the real app (fine), but tests
  must not — `test/flutter_test_config.dart` disables that. Keep it.
- **`flutter_secure_storage` on web** falls back to an unencrypted store — fine
  for dev; web is not a shipping target.
- The app `title:` shows the raw key `app_name` on the very first frame before
  GetX translations initialise, then corrects. Cosmetic.
- CI pins `flutter-version: 3.38.5` in `ci.yaml` — bump it with your local SDK.
- This mobile repo is independent of `bizops360-api`; check
  `git rev-parse --show-toplevel` before any git command.
