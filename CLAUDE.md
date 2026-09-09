# BizOps 360 — mobile

Flutter client for the BizOps 360 field operations platform. Internal staff and
managers of the tenant companies (travel agencies, consultancies, real estate).
Talks only to the versioned REST API at `bizops360-api` (`/api/v1`).

Design reference: the approved mockup (hangar-green / terminal-grey / wayfinding
amber; Bricolage Grotesque · Public Sans · IBM Plex Mono · Hind Siliguri).

## Stack

- Flutter 3.38, Dart 3.10 · **GetX** for state, routing and DI · Dio for HTTP
- `flutter_secure_storage` for the API token, `get_storage` for prefs/caches
- `google_fonts`, `intl`, `equatable`
- Auth: email + password → per-device Sanctum token. No OTP, no social. First
  password is set from an emailed activation link.

## Architecture (layers, per spec §8)

```
Presentation (screens, widgets)
  → Application / State (GetX controllers + bindings)
  → Domain (entities, repository interfaces)   ← no Flutter, no Dio
  → Data (datasources, mappers, repository impls)
  → Core (config, network, error, storage, theme, localization, widgets)
```

```
lib/
├── bootstrap.dart              shared startup (flavor → storage → DI → runApp)
├── main.dart / main_prod.dart  flavor entrypoints
├── app/                        GetMaterialApp, routes, initial binding
├── core/
│   ├── config/                 Flavor + Env (API base url per flavor)
│   ├── network/                ApiClient (Dio), AuthInterceptor, failure mapper
│   ├── error/                  sealed Failure, Result<T>
│   ├── storage/                SecureStore (token), KvStore (prefs)
│   ├── theme/                  AppColors (ThemeExtension), typography, ThemeData
│   ├── localization/           GetX translations (en_US, bn_BD) + Tr keys
│   └── widgets/                shared: AppLogo, StatusPill, SectionCard …
├── domain/{entities,repositories}
├── data/{datasources,models,repositories}
└── features/<name>/{controllers,bindings,screens}
```

## Rules

1. **No business logic in widgets.** Screens are `GetView<Controller>`; controllers
   own state and call repositories.
2. **Repositories return `Result<T>`** (`Ok` | `Err(Failure)`). Controllers
   `fold` — they never see a `DioException`. The only place that knows HTTP
   status codes is `core/network/dio_failure_mapper.dart`.
3. **Domain is pure Dart** — no `package:flutter`, no `package:dio`. Data-layer
   mappers convert JSON ↔ entities.
4. **Every user-facing string is a `Tr.*` key**, resolved with `.tr`. Add both
   `en` and `bn` in `app_translations.dart`.
5. **Colours come from `context.colors`** (the `AppColors` extension), never a
   literal `Color(0x…)` in a widget. Both themes must stay legible.
6. **One `ApiClient`**, injected. Data sources depend on it, never on `Dio()`.
7. **DI in bindings.** Permanent services in `InitialBinding`; per-feature
   controllers lazy in the feature binding.
8. Money/codes render in `AppTypography.mono(...)`. BDT: `৳`, 2-2-3 grouping.
9. Add a test with every bug fix.

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
- New screens render in light and dark
- Summary of changed files + command output

## Backend endpoints in play

`POST /api/v1/auth/login` `{email,password,device_name?}` → `{data:{…user}, token}` ·
`GET /api/v1/auth/me` → `{data:{…user}}` · `POST /api/v1/auth/logout`.
The `user` object carries `roles`, `permissions` and `tenant.industry` — the app
builds its navigation and gating from that. A `GET /me/bootstrap` and
`POST /devices` (FCM) are planned server-side and will slot into `AuthRepository`.
