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

### Structure migration ✅ done (commit `c1f58ee`)

The layered layout from [`CLAUDE.md`](../CLAUDE.md) is in place: `lib/app/app.dart`
(wiring), `lib/core/routing/`, `lib/application/{auth,settings,navigation,permissions}/`,
`lib/presentation/{auth,home,shell,splash}/`, `lib/domain/usecases/`,
`lib/core/{permissions,extensions,utils}/`. `lib/modules/travel/` and
`lib/application/{session,tenant}/` are created as features land.

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
   ✅ **(2026-09-11)** `AppSearchField` (debounced, clear button — now used by
   Customers + Travellers search), `AppDropdown<T>` (labeled
   `DropdownButtonFormField`, available for the next form that needs a picker;
   the CRM stage control stays a bare inline `DropdownButton` — it's a compact
   trailing control in a row, not a form field), `AppPagination` (footer:
   spinner / retry / hidden-when-exhausted) + `core/paging/PagingController<T>`
   (page-merge state machine — not wired into a screen yet since every list
   repo still returns one full `Result<List<T>>`; adopt it the day a real
   endpoint starts paginating). Tests: `test/widgets/app_form_widgets_test.dart`,
   `test/core/paging_controller_test.dart`.
6. **Permissions layer** — ✅ `core/permissions/`: `Perm.*` + `Feature.*`
   catalogue, pure `PermissionResolver`, `Can(...)` / `Can.anyOf(...)` widget.
   `application/permissions/PermissionsController` derives the resolver from the
   live session (permanent in `AppBinding`). Wire `enabledFeatures` in M1 once
   `/me/bootstrap` lands.
7. **Use-case layer** — ✅ `domain/usecases/auth/`: `SignInUseCase`,
   `LoadSessionUseCase`, `SignOutUseCase`. `AuthController` / `SignInController`
   depend on use cases, not the repo. `FakeAuthRepository` added as the
   fake-repo convention example; `AppBinding` branches on `Env.useFakeData`.
8. **Routing + guard** — ✅ `core/routing/route_guard.dart` (`AuthGuard`
   middleware on `signIn` + `shell`). Splash still does first-launch routing.
9. **Logger + BDT formatter** — ✅ `core/utils/logger.dart` (`AppLog`, silent in
   prod), `core/extensions/money_format.dart` (`num.toBdt()` → `৳ 12,34,567.50`).

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
1. **Permission-driven shell** — ✅ `shellTabsFor(PermissionResolver)` (pure,
   tested) emits `Home | Customers | Visa | Tasks | More`, gated by
   permission + enabled feature; `ShellScreen` maps `ShellTabId` → screen.
   Old Desk/CRM/Insights/Team tabs retired. `nav.*` keys updated (en + bn).
2. **Travel Home dashboard** — ✅ `presentation/home/`: greeting app bar +
   notification badge, composed `DashboardSection`s — `QuickActionsSection`
   (self-gating), `VisaSummarySection`, `PendingVisaDocsSection`,
   `TicketTasksSection` (`modules/travel/dashboard/`, travel-gated), and the
   Follow-ups / My Tasks previews. **(2026-09-11) all live**, not sample data —
   every section reads the same permanent controller/repository its full
   screen uses (`VisaQueueController`, `TasksController`, `FollowUpsController`,
   `BookingRepository` via `ensureBookingRepo()`), registered once by
   `ShellBinding` so Home never duplicates a fetch. "View all" either routes
   (`/follow-ups`, `/departures`) or jumps tabs (`ShellController.selectTab`).
   Pull-to-refresh re-loads the Tasks/Follow-ups controllers.
3. **Workspace ("More") + Settings** — ✅ `presentation/workspace/`:
   role-aware grouped list (`Can`-gated rows) → Profile, Attendance, Leave,
   Expenses, Documents, Team, CRM, Reports, Approvals, Settings, Help. Routes:
   `/settings` (real: theme mode + language + sign-out), `/profile` (identity +
   roles), `/coming-soon` (generic placeholder, title via `Get.arguments`).
   `AuthGuard` now covers every route.
4. **Notifications** (`presentation/notifications/`) — ✅ grouped Today / Earlier
   list, unread emphasis + dot, mark-all-read, tap → markRead + optional route,
   pull-to-refresh. `FakeNotificationRepository` seeded. Home bell navigates
   here (badge count still static — wire to a real unread count later).
5. **Profile edit / app-lock** — profile is read-only for now; edit + biometric
   app-lock (`local_auth`) land with M6 hardening.
6. **Tasks** (`presentation/tasks/`) — ✅ list (Today / Overdue / Upcoming tabs
   with counts, `TaskTile`), ✅ detail (status chips, subtask progress bar +
   checklist, comments thread + input, mark done / reopen). Subtasks + comments
   are **static sample** (`// TODO(api)`). Still ahead: manager assign / reassign
   / create, real attachments. Backend: `app/Modules/Operations`.
7. **Attendance + Leave** (`presentation/hr/`) — ✅ Attendance punch card
   (in/out, worked time) + history list; ✅ Leave (balance cards, my requests,
   request form with type chips + range picker + reason); ✅ Approvals screen
   (approve / reject). Routes wired into Workspace. Fakes seeded.
   **Still ahead** (real-data concerns): geolocation (`geolocator`) + optional
   selfie (`image_picker`) on check-in, **offline queue** (persist unsent
   check-ins in `KvStore`/Hive, flush on `connectivity_plus`, idempotency key),
   holiday calendar. Backend: `app/Modules/HR`.
8. **Documents** — ✅ `DocumentsScreen` (filter chips: Expiring + categories;
   rows with owner / date / size, expiry chip). Upload / signed-URL download
   still ahead. `FakeDocumentRepository` seeded.

### M3 — Common business features ✅ (static)
1. **CRM / customers** — ✅ `CustomersScreen` (stage chips + search),
   `CustomerDetailScreen` (call/message, stage dropdown, activity timeline).
   Ahead: quick-add customer, contacts. Backend: `app/Modules/CRM`.
2. **Follow-ups** — ✅ `FollowUpsScreen` (Today/Overdue/Upcoming/Done tabs,
   `AppBottomSheet` outcome logger). Feeds the Home follow-ups section.
   Ahead: quick-add.
3. **Expenses** — ✅ `ExpensesScreen` (list + pending total) + `ExpenseNewScreen`
   (category chips, amount, date, receipt toggle — real photo picker later).
   ✅ manager approve / reject (Approvals screen, Expenses tab).
   Backend: `app/Modules/Finance`.
3b. **Manager task actions** — ✅ `TasksScreen` FAB (`Can(task.create)`) →
   task_create_sheet (title, priority, assignee, due). Reassign still ahead.

### M4 — Travel agency (`modules/travel/`, gated on `TenantContext.isTravel`) — UI ✅, API wired for travellers + visa
1. **Travellers & passenger info** — ✅ `TravellersScreen` (search by name /
   passport, expiry warnings), `TravellerDetailScreen` (passport card + expiry
   chip, travel-history timeline). **API wired:** `TravellerRepositoryImpl`
   (`GET /travellers`, `/travellers/{id}`) via `TravellerRemoteDataSource` +
   `travel_mappers.dart`; `travellers_bindings.dart` picks real vs
   `FakeTravellerRepository` on `Env.useFakeData`. History endpoint not built
   server-side yet → impl returns an empty timeline.
2. **Passport** — ✅ folded into the traveller detail (number, expiry, DOB,
   expired / expiring-soon chip). Deadline reminders still ahead.
3. **Visa applications** — ✅ `VisaQueueScreen` (stage filter chips, doc-progress
   cards), `VisaDetailScreen` (doc checklist gates **submit**, stage-aware
   action bar: submit → processing → approve/reject, terminal decision state).
   **API wired:** `VisaRepositoryImpl` (`GET /visa-applications`, `/{id}`,
   `PUT /visa-requirements/{id}`, `POST .../submit|processing|decision`).
   Backend `stage` maps to `VisaStage`; `cancelled` collapses onto `rejected`.
   `toggleDoc` resolves the requirement id by name (re-fetch → PUT → re-fetch).

**API-integration pattern:** `core/network/api_envelope.dart` unwraps
`{data:[…]}` / `{data:{…}}`; `data/repositories/remote_guard.dart`
`guardRequest()` maps `DioException` → `Failure`; `data/repositories/
repo_registry.dart` `registerRepo<T>(real, fake)` picks impl vs fake on
`Env.useFakeData` (fed the permanent `ApiClient`). Live checks:
`flutter test --tags integration --run-skipped test/data/*_live_test.dart`
(needs `bizops360-api` up; logs in as `manager@wanderlust.test`).

**Module API status (2026-09-10):**

| Module | Endpoints | State |
|---|---|---|
| Auth | login (+ `auth/me` hydrate), logout | ✅ live, verified on device |
| Travellers | `GET/POST /travellers`, `/{id}` | ✅ live + create |
| Visa | `GET /visa-applications` (+/{id}), `PUT /visa-requirements/{id}`, submit/processing/decision | ✅ live, mutations verified |
| Notifications | `GET /notifications`, `PATCH …/read`, `POST …/read-all` | ✅ live |
| Tasks | `GET/POST /tasks`, `PUT /tasks/{id}/status` | ✅ live, create+status verified |
| CRM | `GET /customers` (+/{id}, +/history), `GET /follow-ups`, `POST …/complete` | ✅ live; customer stage is read-only (`moveStage` fails closed — pipeline lives on the lead) |
| Bookings | `GET/POST /bookings`, `POST …/issue|cancel` | ✅ live; `departures` filtered client-side; `type` folds 8→3 kinds |
| Reports | composes crm/finance/travel overview + finance/monthly + customer-dues | ✅ live; travel part optional for non-travel tenants |
| Attendance | `GET /attendance`, `POST /attendance/check-in|check-out` | ⚠️ wired — needs the account linked to an employee (owner/manager demo users aren't) |
| Leave | `GET /leave-balances`, `/leave-requests`, `POST` + approve/reject | ⚠️ wired — needs employee link; `submit` resolves `leave_type_id` by code, 422s until leave types are seeded |
| Expenses | `GET/POST /expenses` | ⚠️ list+submit live; **no server-side approval** → `pendingApprovals` empty, `decide` unavailable |
| Documents | `GET /employee-documents` | ⚠️ wired (empty seed); signed `download_url` not surfaced in UI |

Backend follow-ups that would close the ⚠️ items: seed leave types + link
`manager`/`owner` demo users to employee records; add an expense
approval state + endpoints; seed a few tasks / notifications.

**Auth hydration (2026-09-10):** `POST auth/login` returns `roles` but **not
`permissions`** — `AuthRepositoryImpl.signIn` now chains `auth/me` after storing
the token so the permission-gated nav/actions are correct on first frame
(falls back to the login user if `me` fails). The `Perm.*` catalogue was
reconciled against the live `/auth/me` payload (`visa.view` →
`visa_application.view`, `attendance.self` → `attendance.check_in`,
`document.view` → `employee_document.view`, `*.manage` → `*.update`,
`reports.view` → `finance.view_reports`, …). `Feature.*` flags still all-on
until `/me/bootstrap` (7a) ships.

**Verified on iOS simulator (2026-09-10):** login → Home (travel nav: Home ·
Customers · Visa · Tasks · More) → Visa queue + detail render live
`visa-applications` data; toggling a requirement round-trips through
`PUT /visa-requirements/{id}` and the backend advances
`documents_pending → documents_collected`.

**Toolchain (Mac, 2026-09-10):** iOS needs CocoaPods (`brew install cocoapods`)
+ deployment target **15.0** (bumped in `ios/Podfile`, `project.pbxproj`,
`AppFrameworkInfo.plist` — firebase_core 4.x requires it). host JDK is 26 →
`flutter build apk` fails
(needs JDK 17); web build fails (`firebase_core_web` 3.11 vs current Dart
`isA`); iOS needs CocoaPods (not installed). None block `flutter analyze` /
`flutter test`. Fix the JDK before an Android run.
4. **Visa documents & deadlines** — ✅ `PendingVisaDocsSection` on Home (live —
   `VisaQueueController`, cases short on docs, soonest-to-submit first, tap
   through to the case). No separate deadline-reminder (push/local notification)
   yet — the app has no scheduled-notification path for a due date today.
5. **Travel operations** — ✅ `BookingsScreen` (status filter, quick-create
   sheet), `BookingDetailScreen` (PNR mono, flight segments, hotel, itinerary,
   issue / cancel), `DeparturesScreen` (board grouped by day). Live via
   `BookingRepositoryImpl` (see the module status table above).
6. **Travel dashboard sections** — ✅ all three registered and live:
   `VisaSummarySection`, `PendingVisaDocsSection`, `TicketTasksSection`
   (soonest departures, `BookingRepository.departures()`).
   Backend: `app/Modules/Industry/Travel` (routes `industry:travel` gated).

### M7 — Manager dashboards ✅ (static)
- ✅ `ReportsScreen` (`presentation/reports/`) — KPI tile grid (revenue,
  pipeline, outstanding, dues, converted, visa counts) + a hand-rolled bar
  chart (no chart package). `FakeReportRepository`. Reached from Workspace →
  Reports (`Can(reports.view, feature: reports)`).
- Ahead: money actions (create invoice from a booking, record a payment),
  drill-through from a tile.

### M5 — Role / permission UX
- Validate the real Travel Agency roles (owner / manager / agent / visa officer /
  ticketing / accounts …) against nav, action visibility, dashboard sections.
- Verify every gated action also fails closed on the backend (403 handling).
- Cross-check `enabledFeatures` toggles hide whole nav branches cleanly.

### M6 — Production mobile
- ✅ **Crash-reporting seam** — `core/observability/CrashReporter` (abstract;
  Noop + Logging defaults). `bootstrap.dart` runs inside `runZonedGuarded` and
  installs `FlutterError.onError` + `PlatformDispatcher.onError` handlers.
  `AuthController` tags reports with `user_id` / `tenant` / `industry`.
- ✅ **Identifiers + names** — `com.bizops360.bizops360_mobile` on both platforms; display
  name "BizOps 360". Android release signing reads `android/key.properties`
  (git-ignored), falls back to debug keys. See `docs/RELEASE.md`.
- ✅ **Firebase — Android** — `google-services.json` in place;
  `firebase_core` / `_crashlytics` / `_messaging` + Gradle plugins wired.
  `bootstrap` brings Firebase up (guarded), swaps in `FirebaseCrashReporter`.
- ✅ **Push notifications, full** — `PushService` (permission, APNs+FCM token,
  `DeviceRepository` register/unregister on login/logout), foreground display +
  data-only background handler via `flutter_local_notifications`, tap→route
  deep-link. Native wiring done both platforms.
  **Left:** iOS `GoogleService-Info.plist` + APNs auth key (Apple account);
  backend `POST /devices` is 7a (impl swallows the 404 until then).
  See `docs/FIREBASE.md`.
- ✅ **Launcher icon** — generated from `assets/logo.png` via
  `tool/crop_icon.dart` → `flutter_launcher_icons` (Android legacy + adaptive,
  iOS, web). Re-run: `dart run tool/crop_icon.dart && dart run flutter_launcher_icons`.
- **Deep links from payloads** — the in-app path works already
  (`AppNotification.route` → `NotificationsController.open` → `Get.toNamed`).
  OS-level links (`app_links` + manifest intent-filters / associated domains)
  are a follow-up once the URL scheme / domain is decided.
- **App-lock (biometric)** — dropped as optional polish; `local_auth` 3.x is
  native-heavy and hard to verify without a device. Revisit if needed.
- ✅ **Pagination building blocks** — `AppPagination` widget +
  `core/paging/PagingController<T>` (page-merge, retry, exhaustion). Not
  adopted by a screen yet — every list repo still returns one full page; wire
  it into the first list whose real endpoint starts truncating.
- Still ahead: response caching (a `KvStore` TTL cache) once a real endpoint
  is worth caching; force-update / maintenance banner from a `/me/bootstrap`
  flag; store assets (icon, splash, screenshots); CI publish to store tracks.

### Cross-cutting (fold in as you go)
- `flavor.dart` staging config + a `--flavor` story for Android/iOS if needed.
- Keep the `intl` BDT helper (`৳`, 2-2-3, lakh/crore) in one place
  (`core/extensions/money_format.dart`).

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

---

## 5. Backend-spec module audit (2026-09-11)

Checked mobile coverage against the platform spec's Phase 1–5 modules
(Organization / HR / Operations / CRM / Finance). New this pass, all
UI-first against a fake (`registerRepo` picks a guarded, best-effort live impl
too — endpoint shapes are a guess following the app's REST convention, **not
confirmed against a running backend**):

| Phase | Spec item | Status |
|---|---|---|
| 1 Organization | Company / Branch / Department / Designation, Roles / Permissions | **Deliberately out of scope for this app** — company setup and role/permission grants are Filament (web admin) work; the spec's own "planned employee/manager mobile features" list never includes them. The app only *consumes* permissions (`Perm.*`) to gate the UI. |
| 1 Organization | Employee, Users | ✅ **new** — `presentation/team/` (`TeamScreen`): read-only directory, search by name/designation/department, status chip. Reached from Workspace → Team. No create/edit (that's admin work too). |
| 2 HR | Attendance, Leave | ✅ already live (see §M2/M4 above) |
| 2 HR | Holidays | ✅ **new** — `presentation/hr/` (`HolidaysScreen`): Upcoming / Past, `FakeHolidayRepository` seeded. Workspace → Holidays. |
| 2 HR | Employee documents | ✅ already covered by the general `DocumentsScreen` (owner-type `employee`) |
| 3 Operations | Tasks, assignments, notifications | ✅ already live |
| 3 Operations | Comments | ✅ **new, live** — `TaskRepository.comments()` / `.addComment()`; `TaskDetailScreen`'s comment thread is no longer static sample data. `TaskItem.subtasksTotal/Done` stay backend-driven; the subtask *checklist* UI is still a placeholder shape (`// TODO(api)`) since the backend doesn't expose individual subtask records yet. |
| 3 Operations | Attachments | ❌ **deferred** — needs a file/camera package (`image_picker` or `file_picker`) plus native permission wiring; same "hard to verify without a device" call as the dropped biometric app-lock. Revisit with a device in hand. |
| 3 Operations | Projects, Teams (as an org hierarchy) | ❌ **deferred** — not in the spec's mobile feature list; "Team" here means the read-only directory above, not project/team management. |
| 4 CRM | Leads, customers, pipeline, follow-ups, activities | ✅ already live |
| 4 CRM | Contacts (distinct multi-contact-per-customer) | ❌ **deferred** — `Customer` already carries one phone/email, which covers the mobile MVP; a separate contacts sub-list is low value until a real workflow needs it |
| 5 Finance | Expenses, reports | ✅ already live |
| 5 Finance | Invoices, Payments, Receivables | ✅ **new** — `presentation/finance/`: `InvoicesScreen` (status filter, outstanding-total banner), `InvoiceDetailScreen` (amount/paid/due, payment history, record-payment sheet). `BookingDetailScreen` gained a **Create invoice** action (`Can(Perm.invoiceManage)`, ticketed bookings only) — the mobile side of spec §6 `Actions/Invoices/{CreateInvoice,RecordPayment}`. Reached from Workspace → Invoices (`Can(Perm.invoiceView)`). |
| 5 Finance | Income (other, non-customer) | ❌ **deferred** — "customer payments" income is covered by invoice payments above; a separate "other income" entry screen wasn't built (low value without a confirmed backend line-item shape) |

**Endpoints guessed, unverified:** `/employees`, `/holidays`, `/invoices`
(+`/{id}`, `POST`, `POST /{id}/payments`), `/tasks/{id}/comments` (`GET`+`POST`).
Same pattern as every other module here — fold in the real field names in the
matching `*_mappers.dart` once confirmed on the Mac; nothing above the data
layer changes. Tests: `finance_controller_test.dart`, `team_holidays_test.dart`,
`task_comments_test.dart` — 88 green total (`--exclude-tags integration`).
