# Handoff — continuing on Windows

State of the repo as of commit `e32cee2` (branch `main`), and the work queued
next. Read `CLAUDE.md` first for architecture and conventions; this doc is the
where-we-are / what-next.

---

## 1. What exists now

The **scaffold + email sign-in flow**, nothing feature-specific yet.

| Area | Status |
|---|---|
| Project | Flutter 3.38 / Dart 3.10, GetX + Dio. Platforms: **android, ios, web**. |
| Architecture | Layered (spec §8): Screen `GetView` → Controller → Repository (`Result<T>`) → DataSource → `ApiClient` (Dio). Pure-Dart `domain/`. See `CLAUDE.md`. |
| Theme | `AppColors` `ThemeExtension` (light + dark, from the approved mockup). Bricolage Grotesque / Public Sans / IBM Plex Mono / Hind Siliguri via `google_fonts`. |
| i18n | GetX translations `en_US` + `bn_BD`, `Tr.*` keys. Toggle persists. |
| Auth | `POST auth/login` → per-device Sanctum token in the keychain; splash validates a stored token against `GET auth/me`; `AuthController` holds the session; a 401 (outside login) ends the session once, centrally. |
| Shell | `NavigationBar` assembled from `user.roles` + `user.tenant.industry` — tab 3 is **Desk** (travel tenant) or **CRM** (other), managers get a 5th **Insights** tab. Only **Home** is built; other tabs are `_Placeholder`. |
| Home | Scaffold-stage: greets the user, lists roles + permissions, language / theme / sign-out. Real decks come in the feature slices. |
| Tests | `flutter test` — 10 passing (auth mappers, `DioException`→`Failure` mapping, `StatusPill` light/dark). `test/flutter_test_config.dart` disables google_fonts network fetch in CI. |
| CI | `.github/workflows/ci.yaml` — `dart format --set-exit-if-changed` → `flutter analyze --fatal-infos` → `flutter test`. Green on `main`. |

**Design source of truth:** the approved mockup artifact (hangar-green ink,
terminal-grey ground, wayfinding amber; the 14 key screens). Build features to
match it.

---

## 2. Running it on Windows

### One-time
1. Install Flutter 3.38.x (`flutter --version` should show `3.38`), Android
   Studio with an SDK + an emulator (Pixel, API 34+), and enable
   `flutter config --enable-web` (already on by default).
2. `git clone https://github.com/mahbub06ru4/bizops360-mobile.git`
3. `flutter pub get`
4. `flutter doctor` — clear the Android toolchain / licences items.
   > On this Mac, `flutter create` flagged a Java 21 / Gradle 8.x mismatch for
   > the Android build. If Windows shows the same, either install JDK 17 and
   > point Android Studio at it, or bump
   > `android/gradle/wrapper/gradle-wrapper.properties` to a Gradle version
   > compatible with your JDK. The web build is unaffected.

### Day to day
```bash
# Android emulator — API base defaults to http://10.0.2.2 (the emulator's alias
# for the host machine's localhost, where a local bizops360-api would run)
flutter run

# Physical Android device — point at the PC's LAN IP
flutter run --dart-define=API_BASE_URL=http://192.168.0.x

# Chrome (web) — localhost reaches a local API directly
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost

# Android Studio: open the folder, pick a device, Run. Add
# --dart-define=API_BASE_URL=... under Run > Edit Configurations > Additional args.
```
`API_BASE_URL` is **origin only** — `Env` appends `/api/v1`.

### The backend
`bizops360-api` is a separate repo (Laravel + Sail). Run it wherever you like and
set `API_BASE_URL` to its origin. Demo logins after `php artisan migrate:fresh
--seed` (or `db:seed --class=DemoSeeder`): `owner@wanderlust.test` /
`manager@wanderlust.test` / `staff@wanderlust.test`, password `password`
(`wanderlust` = travel tenant; `skyline` = real estate).

> The live auth endpoints are login / me / logout. The activation-link,
> password-reset, `GET /me/bootstrap` and `POST /devices` endpoints are
> **Phase 7a backend work, not built yet** — see §3.

---

## 3. Work queue (each item = one PR)

Build in this order. Every PR: `dart format` clean, `flutter analyze
--fatal-infos` clean, `flutter test` green, new strings have `en` + `bn`, new
screens checked in light + dark.

### 7a — Backend first (in `bizops360-api`, Laravel)
Not mobile work, but the mobile side needs it. In `app/Modules/Identity`:
- **Account activation**: admin creates a user with `status = invited`; email a
  signed activation link; `POST /api/v1/auth/activate` (token + password) sets
  the password, flips to `active`, returns a token.
- **Password reset** API (`auth/forgot-password`, `auth/reset-password`).
- **`GET /api/v1/me/bootstrap`** — one payload: user, tenant, roles,
  permissions, `industry`, unread notification count, feature flags. The app
  should call this instead of `auth/me` after login and on resume.
- **`POST /api/v1/devices`** — register an FCM token; `DELETE` on sign-out.
- **Sessions**: `GET /auth/sessions`, `DELETE /auth/sessions/{id}`.
- Attendance endpoint: accept a client timestamp + lat/long + an idempotency key
  (for offline-queued check-ins).

Then on the mobile side: extend `AuthRepository` with `activate()` /
`bootstrap()`, add a `Bootstrap` entity, swap `currentUser()` to hit
`/me/bootstrap`.

### 7b — Mobile feature slices
Each slice adds `features/<name>/{controllers,bindings,screens}`, a
`domain/repositories/<x>_repository.dart`, `data/` impl + mappers, a nav tab or
a "More" entry, and tests.

1. **Home decks + Notifications**
   - Replace the scaffold Home with the real *My day* / *My team* layout from
     the mockup (attendance card, "Today", follow-ups, leave balance;
     manager: in/out counts, approvals, overdue).
   - `features/notifications` — list (`GET /api/v1/notifications`), mark read,
     grouped Today / Earlier, unread badge on the app bar. Deep-link routing
     stub (real push lands after 7a `/devices`).

2. **Attendance + Leave** (`features/hr`)
   - Attendance: check-in / check-out with geolocation (`geolocator` pkg),
     optional selfie (`image_picker`), today's status, week bars, history.
     **Offline queue**: persist unsent check-ins in `KvStore`/Hive, flush on
     connectivity (`connectivity_plus`). Idempotency key per queued item.
   - Leave: request form (type, date range, reason, attachment), my balance
     (recalculated inline), my requests + status, holiday calendar.
   - Manager: approve / reject leave with a note.
   - Backend: `app/Modules/HR` — Attendance, Leave already exist; check the
     routes.

3. **Tasks** (`features/tasks`)
   - My tasks (Today / Overdue / Upcoming tabs), detail (status one-tap,
     subtasks with progress, comments thread + input, attachments).
   - Manager: assign / reassign / create.
   - Backend: `app/Modules/Operations`.

4. **CRM** (`features/crm`)
   - Pipeline (stage chips → filtered lead cards), lead / customer detail +
     history, follow-ups (Today / Overdue / Upcoming) with the outcome sheet,
     quick-add.
   - Backend: `app/Modules/CRM`.

5. **Travel desk** (`features/travel`, travel tenants only — gate on
   `user.tenant.isTravel`)
   - Travellers (search, passport), visa applications (queue by stage,
     checklist tick-off that gates "submit", stage moves, decision), bookings
     (list, quick create, PNR / segments / hotel / itinerary, issue / cancel),
     departures board.
   - Backend: `app/Modules/Industry/Travel` (routes are `industry:travel`
     gated — a non-travel token gets 403, matching the app-side gate).

6. **Expenses** (`features/expenses`)
   - Submit with a receipt photo (category chips, amount in mono, date, note);
     my submitted expenses + status.
   - Backend: `app/Modules/Finance` — Expense.

7. **Manager dashboards** (`features/insights`, the 5th tab)
   - Read-only KPI tiles + a small themed chart from the report endpoints:
     `crm/overview`, `crm/sales-performance`, `finance/overview`,
     `finance/outstanding-invoices`, `finance/customer-dues`,
     `travel/overview`.
   - Manager money actions: create invoice from a booking, record an invoice
     payment.

### Cross-cutting (fold in as you go)
- `flavor.dart` staging config + a `--flavor` story for Android/iOS if needed.
- `intl` number formatting helper for BDT (`৳`, 2-2-3 grouping, lakh/crore).
- App-lock (biometric) option in Profile (`local_auth`).
- Force-update / maintenance banner from a bootstrap flag.
- Firebase (FCM + Crashlytics) — after 7a `/devices`.

---

## 4. Gotchas

- **`~/Developer/bizops360/` is itself a git repo.** This mobile repo is a
  separate, independent one. On the Mac, always `cd` into `bizops360-mobile`
  and check `git rev-parse --show-toplevel` before any git command.
- **`google_fonts` fetches fonts at runtime** in the real app (fine), but tests
  must not — `test/flutter_test_config.dart` already disables that. Keep it.
- **`flutter_secure_storage` on web** falls back to an unencrypted store — fine
  for dev, not a production concern for web since web isn't a shipping target.
- The app `title:` shows the raw key `app_name` on the very first frame (before
  GetX translations initialise), then corrects itself. Cosmetic; leave it or
  hardcode `'BizOps 360'` in `app.dart`.
- CI pins `flutter-version: 3.38.5` in `ci.yaml` — bump it together with your
  local SDK.
