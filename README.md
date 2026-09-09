# BizOps 360 — mobile

Flutter (GetX) client for the [BizOps 360](../bizops360-api) field operations
platform. One role-adaptive app for agency staff and managers — sign in with a
company email, and the app builds itself around the roles, permissions and
tenant industry returned by the API.

## Status

Scaffold: architecture, theme (light/dark), EN/বাংলা, networking, and the
**email sign-in → session → shell** flow. Feature decks (attendance, tasks,
CRM, travel desk, expenses, manager dashboards) land in subsequent slices,
following the approved design mockup.

## Running

```bash
flutter pub get

# Android emulator → host machine's localhost
flutter run

# iOS simulator / device — point at your API origin (no /api/v1)
flutter run -d ios --dart-define=API_BASE_URL=http://localhost

# Production
flutter run --release -t lib/main_prod.dart --dart-define=API_BASE_URL=https://api.bizops360.app
```

## Checks

```bash
dart format .
flutter analyze --fatal-infos
flutter test
```

CI runs all three on every push and PR.

## Layout

See [`CLAUDE.md`](CLAUDE.md) for the layered architecture and conventions.
