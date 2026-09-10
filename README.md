# BizOps 360 — mobile

Flutter (GetX) client for the [BizOps 360](../bizops360-api) field operations
platform. **One** multi-tenant, role- and permission-aware app — sign in with a
company email and the app builds itself around the tenant industry, roles and
permissions returned by the API. The first commercial release is focused on
**Travel Agency Management**; the common platform (HR, tasks, CRM, finance,
documents) is reached through role-aware **More / Workspace** navigation.

## Status

Scaffold: architecture, theme (Light/Dark/System), EN/বাংলা, networking, and the
**email sign-in → session → shell** flow. The permission-driven travel navigation
(`Home | Customers | Visa | Tasks | More`), the travel Home dashboard, and the
feature slices land in milestones M0–M6 — see [`docs/HANDOFF.md`](docs/HANDOFF.md),
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
