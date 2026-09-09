---
name: bizops-mobile
description: >-
  BizOps 360 Flutter app conventions — GetX for state/routing/DI, the layered path
  (Screen/GetView → Controller → Repository → DataSource → Dio), pure-Dart domain,
  Result<T>/sealed Failure error handling, the AppColors ThemeExtension with light
  and dark, GetX en/bn translations, email+password Sanctum auth against
  bizops360-api /api/v1, and the dart format / flutter analyze --fatal-infos /
  flutter test gate. Use whenever writing, reviewing or debugging Dart/Flutter
  code in this repo.
---

# BizOps 360 — mobile engineering skill

Read `CLAUDE.md` first. This is the how-to behind its rules. The visual target is
the approved design mockup (hangar-green ink, terminal-grey ground, wayfinding
amber; Bricolage Grotesque / Public Sans / IBM Plex Mono / Hind Siliguri).

## The layered path

```
Screen (GetView<Controller>)        ← no logic, no direct Dio/Get.find of repos
  → Controller (GetxController)     ← owns Rx state, calls repositories
  → Repository (interface, domain)  ← returns Result<T>
  → RepositoryImpl (data)           ← maps JSON↔entities, DioException→Failure
  → DataSource (data)               ← thin wrapper over ApiClient endpoints
  → ApiClient (core)               ← the one configured Dio
```

- **Domain is pure Dart.** `lib/domain/**` must not import `package:flutter` or
  `package:dio`. Entities are `Equatable`. Mapping lives in `lib/data/models/`.
- **Controllers never see a `DioException`.** Repos catch and return
  `Result.err(Failure)`; controllers `fold(onOk, onErr)`. Status-code knowledge
  is confined to `core/network/dio_failure_mapper.dart`.
- A `ValidationFailure` carries `errors` (field → messages); surface with
  `forField('email')` into `InputDecoration.errorText`.

## GetX

- Routing: named routes in `app/routes/`. Each `GetPage` has a `Binding`.
- DI: `InitialBinding` puts permanent services (stores, `ApiClient`,
  repositories, `AuthController`, `SettingsController`). Feature bindings
  `lazyPut` their controller.
- The auth interceptor's `onUnauthorized` resolves `AuthController` lazily to
  avoid a construction cycle; a 401 (outside `/auth/login`) ends the session
  once, centrally.
- Reactivity: `.obs` fields + `Obx(() => …)`. Don't `setState`.

## Theme & localization

- Colours: `context.colors.<token>` (the `AppColors` `ThemeExtension`). Never a
  literal `Color(0x…)` in a widget. Define new tokens in **both** `AppColors.light`
  and `.dark` and in `copyWith` / `lerp`.
- Type: `Theme.of(context).textTheme` for prose; `AppTypography.mono(color)` for
  PNRs, flight numbers, references and money (`৳`, 2-2-3 grouping).
- Every string is a `Tr.*` key with `en` **and** `bn` entries in
  `app_translations.dart`. New feature → new key group.
- New screens must be checked in light and dark.

## Testing (flutter_test)

- Domain/data: pure unit tests (mappers, failure mapping, entity helpers).
- Widgets: pump inside `MaterialApp(theme: AppTheme.light()/dark())`.
  `test/flutter_test_config.dart` already disables google_fonts network fetch.
- Controllers: construct with fake repositories returning `Result`.
- Every bug fix adds a regression test.

## Verification gate (before "done")

```
dart format .
flutter analyze --fatal-infos
flutter test
```

All clean, strings bilingual, screens dark-safe. Then summarise changed files +
output.

## Do not

Put logic in widgets · import Flutter/Dio from `domain/` · expose `DioException`
above the data layer · hard-code colours or English strings · construct `Dio()`
outside `ApiClient` · add a package without a clear need · skip the `bn`
translation.
