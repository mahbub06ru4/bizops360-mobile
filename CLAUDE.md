# BizOps 360 — mobile

**One** multi-tenant Flutter app for the BizOps 360 field-operations platform.
Internal staff and managers of the tenant companies. The first commercial release
is focused on **Travel Agency Management**; the common platform (HR, tasks, CRM,
finance, documents) rides alongside it, surfaced by role and permission.

There is **one login and one application**. It adapts — never forks — by
`tenant → industry → role → permissions → enabled features`. Do not build
separate apps or duplicate feature trees for Admin / Manager / Employee / HR /
Finance / Sales / Operations.

Talks only to the versioned REST API at `bizops360-api` (`/api/v1`). Backend
authorization is always the security authority; the app uses permissions only to
decide what to *show*.

Design reference: the approved mockup (hangar-green / terminal-grey / wayfinding
amber; Bricolage Grotesque · Public Sans · IBM Plex Mono · Hind Siliguri).

## Stack

- Flutter 3.38, Dart 3.10 · **GetX** for state, routing and DI · Dio for HTTP
- `flutter_secure_storage` for the API token, `get_storage` for prefs/caches
- `flutter_screenutil` for responsive sizing (design frame **375 × 812**)
- `google_fonts`, `intl`, `equatable`
- Auth: email + password → per-device Sanctum token. No OTP, no social. First
  password is set from an emailed activation link.

## Architecture (layers)

Business logic never lives in a widget, a GetX controller, or serialization
code. Every interface routes through the same path:

```
Presentation (screens, widgets)            presentation/ · modules/travel/
  → Application (GetX controllers + bindings — coordination only, no rules)
  → Domain (use cases, entities, repository interfaces)   ← no Flutter, no Dio, no GetX
  → Data (datasources, models, mappers, repository impls)
  → Core (config, network, error, permissions, routing, storage, theme, l10n, widgets)
```

Preferred flow: **View → GetX Controller → Use Case → Repository → Data Source / API**.

```
lib/
├── bootstrap.dart              shared startup (flavor → storage → DI → runApp)
├── main.dart / main_prod.dart  flavor entrypoints
├── app/
│   └── app.dart                GetMaterialApp — wiring only, no logic
├── core/
│   ├── config/                 Flavor + Env (API base url per flavor)
│   ├── constants/              non-localized constants, keys
│   ├── extensions/             context.colors, num → BDT, DateTime helpers
│   ├── network/                ApiClient (Dio), AuthInterceptor, dio_failure_mapper
│   ├── error/                  sealed Failure, Result<T>
│   ├── permissions/            Permissions catalogue + PermissionResolver (pure) + `Can` widget
│   ├── routing/                route names, GetPages, RouteGuard
│   ├── storage/                SecureStore (token), KvStore (prefs/cache)
│   ├── theme/                  design tokens (AppColors, AppTypography, AppSpacing,
│   │                           AppRadius, AppElevation, status colours) + ThemeData
│   ├── localization/           GetX translations (en, bn) + Tr keys
│   ├── utils/                  logger, formatters
│   └── widgets/                App* common widget library (see Rules §11)
├── domain/
│   ├── entities/               pure Dart, Equatable
│   ├── repositories/           interfaces → Result<T>
│   └── usecases/               one class per business use case (call → Result<T>)
├── data/
│   ├── datasources/            thin wrappers over ApiClient endpoints
│   ├── models/                 JSON DTOs
│   ├── mappers/                JSON ↔ entity
│   └── repositories/           repository implementations
├── application/                cross-cutting GetX controllers + bindings (coordination only)
│   ├── auth/                   AuthController — session lifecycle
│   ├── session/                token / resume handling
│   ├── tenant/                 tenant + industry context
│   ├── permissions/            PermissionsController — exposes the resolver to the UI
│   └── navigation/             ShellController — permission-driven nav model
├── presentation/               common-platform feature UIs
│   ├── auth/  home/  shell/  notifications/  tasks/  attendance/
│   ├── leave/  documents/  crm/  expenses/  profile/  settings/
│   └── …                       each: {controllers, bindings, screens, widgets}
└── modules/
    └── travel/                 travel-only business features (gated on industry)
        ├── dashboard/          dashboard-section widgets fed into presentation/home
        ├── customers/  passengers/  passport/  visa/  applications/
        ├── documents/  operations/
        └── …                   each: {controllers, bindings, screens, widgets}
```

`presentation/home/` owns the dashboard **shell** and section registry; the
travel dashboard **sections** live in `modules/travel/dashboard/` and register
into that composition — travel rules stay in the travel module.

## Navigation

Bottom nav is **travel-focused and permission-driven** — not one tab per module.
Baseline for a travel tenant:

```
Home | Customers | Visa | Tasks | More
```

Exact items are derived from permissions + enabled features. Everything else
(My Profile, Attendance, Leave, Expenses, Documents, Employees/Team, CRM if not
primary, Reports, Approvals, Settings, Help) lives under **More / Workspace**,
itself role-aware. Never dump every common module into the bottom bar.

The Home screen is an **operational travel dashboard** built from reusable
sections (visa summary, pending visa documents, customer follow-ups, upcoming
ticket tasks, my tasks, notifications, quick actions, KPIs) — not a generic ERP
grid. Compose it from small section widgets, not one giant `HomeScreen`.

## Rules

1. **No business logic in widgets or controllers.** Screens are
   `GetView<Controller>`; controllers coordinate and call **use cases**; use
   cases and repositories hold the rules and stay free of GetX/Flutter/Dio.
2. **Repositories return `Result<T>`** (`Ok` | `Err(Failure)`). Controllers
   `fold` — they never see a `DioException`. The only place that knows HTTP
   status codes is `core/network/dio_failure_mapper.dart`.
3. **Domain is pure Dart** — no `package:flutter`, no `package:dio`, no
   `package:get`. Data-layer mappers convert JSON ↔ entities.
4. **Every user-facing string is a `Tr.*` key**, resolved with `.tr`, with both
   `en` and `bn` in `app_translations.dart` — buttons, labels, validation,
   errors, empty states, notifications. Design layouts to tolerate EN/BN length
   differences.
5. **Colours and metrics come from design tokens** (`context.colors`,
   `AppSpacing`, `AppRadius`, `AppElevation`, `AppTypography`), never a literal
   `Color(0x…)` / magic padding in a widget. Both themes must stay legible.
   Layouts are **responsive**: size with `flutter_screenutil` (`.w` `.h` `.r`
   for spacing/dimensions/radius, `.sp` for any raw font size) against the
   375 × 812 frame; the design tokens are defined in those units so widgets
   mostly just read tokens. Verify on a phone and a tablet width.
6. **One `ApiClient`**, injected. Data sources depend on it, never on `Dio()`.
   **UI-first is fine, but build against the repository interface, never fake
   widgets.** Each feature ships a `FakeXRepository` (canned `Result.ok`, data
   shaped exactly like the documented API envelope) alongside the real
   `XRepositoryImpl`. Bindings pick one via `Env.useFakeData`
   (`--dart-define=USE_FAKE_DATA=true`, the default until the API is reachable).
   Controllers, screens and tests never change when the switch flips — only the
   binding and the mappers.
7. **DI in bindings.** Permanent services (stores, `ApiClient`, repositories,
   `AuthController`, `SettingsController`, `TenantContext`, `PermissionsController`)
   in the app-wide binding; per-feature controllers + use cases `lazyPut` in the
   feature `Binding`, registered at route level. No `Get.put`/`Get.find` inside
   widgets, and no `Get.find` deep inside domain/data classes.
8. **Permission-driven UX, backend-enforced.** Gate nav items, screens, actions
   and buttons with `Can(permission)` / the resolver — never scatter raw role
   string checks. The backend still authorizes every call; the app must handle a
   403 gracefully.
9. **Support Light / Dark / System** via the central theme. Every new screen is
   checked in light and dark.
10. **Every screen handles its states**: loading, success, empty, error, refresh
    (pull-to-refresh) and pagination where the list can grow.
11. **Reuse the common widgets** (`AppButton`, `AppTextField`, `AppDropdown`,
    `AppSearchField`, `AppCard`, `AppDialog`, `AppBottomSheet`, `AppSnackbar`,
    `AppLoader`, `AppEmptyState`, `AppErrorState`, `AppNetworkError`,
    `AppPagination`, `AppAvatar`, `AppBadge`, `AppStatusChip`, `AppShimmer`).
    Do not create abstractions for purely theoretical reuse.
12. **Keep travel-specific rules in `modules/travel/`.** The common platform must
    not import from `modules/travel/`.
13. Money/codes render in `AppTypography.mono(...)`. BDT: `৳`, 2-2-3 grouping,
    lakh/crore.
14. **No hardcoded tenant IDs, role assumptions, or production URLs.** Config
    comes from `Env` / `--dart-define`.
15. Add a test with every bug fix; write/update tests for non-trivial behaviour.
16. Inspect existing conventions before changing code; avoid unrelated
    refactoring. Do not introduce another state-management framework.

## Commands

```
flutter pub get
flutter run                       # dev flavor, API at http://10.0.2.2 (Android emulator)
flutter run -d ios --dart-define=API_BASE_URL=http://localhost
dart format .
flutter analyze --fatal-infos
flutter test
```

`API_BASE_URL` is origin only — the `/api/v1` prefix is added by `Env`.

## Definition of done

- `dart format` leaves no diff · `flutter analyze --fatal-infos` clean · `flutter test` green
- New/changed strings have `en` + `bn`
- New screens render in light and dark, and handle loading / empty / error / refresh (+ pagination if a list)
- Permission-gated where the backend gates it; a 403 degrades gracefully
- Summary of changed files + command output

## Development sub-phases

See [`docs/HANDOFF.md`](docs/HANDOFF.md) for the current state and the PR-sized
work queue. Milestones:

| Phase | Scope |
|---|---|
| **M0 — Flutter foundation** | GetX, project structure, DI, routing, networking, localization, theme + design tokens, common widgets, config, logging |
| **M1 — Auth & context** | Login, logout, token/session, tenant + user + role + permission + industry context, `/me/bootstrap` |
| **M2 — Core workspace** | Home shell (travel nav), tasks, notifications, profile, settings, attendance, leave, documents |
| **M3 — Common business** | CRM/customers, contacts, activities, follow-ups, finance/expenses for the first release |
| **M4 — Travel agency** | Travel dashboard, customers, passengers, passport, visa, applications, documents, deadlines, operations |
| **M5 — Role/permission UX** | Validate travel roles; verify navigation, actions, visibility against API authorization |
| **M6 — Production mobile** | Crash reporting, performance, secure-storage review, pagination, caching, push, deep links, CI/CD, store readiness |

## Backend endpoints in play

`POST /api/v1/auth/login` `{email,password,device_name?}` → `{data:{…user}, token}` ·
`GET /api/v1/auth/me` → `{data:{…user}}` · `POST /api/v1/auth/logout`.
The `user` object carries `roles`, `permissions` and `tenant.industry` — the app
builds its navigation and gating from that. A `GET /me/bootstrap` (user, tenant,
roles, permissions, industry, enabled features, unread count) and `POST /devices`
(FCM) are planned server-side and slot into `AuthRepository` — see
[`docs/HANDOFF.md`](docs/HANDOFF.md) §7a.
