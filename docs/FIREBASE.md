# Firebase (FCM + Crashlytics)

Project: **`bizops360mobile`**. `CrashReporter` swaps to a Firebase-backed impl
at runtime from `bootstrap.dart`; `PushService` is registered the same way.

## Status

| | State |
|---|---|
| **Android** | ✅ `android/app/google-services.json` in place (registers `com.bizops360.bizops360_mobile`). `firebase_core` / `firebase_crashlytics` / `firebase_messaging` added; Gradle plugins (`com.google.gms.google-services`, `com.google.firebase.crashlytics`) applied. `FirebaseCrashReporter` active — crashes + non-fatals go to Crashlytics, tagged with `user_id` / `tenant` / `industry`. |
| **iOS** | ⏳ Add an iOS app in the console, bundle id **`com.bizops360.bizops360Mobile`** (camelCase — `_` is invalid in a CFBundleIdentifier). Download `GoogleService-Info.plist`, add it to the Runner target in Xcode. `Firebase.initializeApp()` is guarded — the app runs on iOS without it, just using the logging reporter. Podfile / deployment target at iOS 13. |
| **iOS push capabilities** | ✅ done in the repo — `ios/Runner/Runner.entitlements` (`aps-environment = development`), `CODE_SIGN_ENTITLEMENTS` set on all 3 Runner build configs, `Info.plist` `UIBackgroundModes = [remote-notification]` + `FirebaseAppDelegateProxyEnabled`. Open the project in Xcode once and confirm **Signing & Capabilities** shows *Push Notifications* + *Background Modes → Remote notifications* (add via `+ Capability` if not). For an App Store build, flip `aps-environment` to `production` (or let Xcode automatic signing manage it). |
| **APNs auth key** | ⏳ **only you can do this** — needs the Apple Developer account. 1) developer.apple.com → Certificates, Identifiers & Profiles → **Keys** → `+` → enable *Apple Push Notifications service (APNs)* → download the `.p8` (once only) and note the **Key ID** + your **Team ID**. 2) Firebase console → Project Settings → **Cloud Messaging** → *Apple app configuration* → upload the `.p8` with Key ID + Team ID. 3) In *Identifiers* → your App ID → make sure **Push Notifications** is enabled. |
| **Device registration** | ⏳ `PushService` fetches the FCM token but does **not** send it anywhere — `POST /api/v1/devices` is 7a backend work. The `// TODO(7a)` in `push_service.dart` marks where `AuthRepository.registerDevice(token)` slots in (register on login, `DELETE` on sign-out). |

## How it's wired

- `bootstrap.dart` → `_initFirebase()` (try/catch) → on success
  `CrashReporter.instance = FirebaseCrashReporter()` **before**
  `installCrashHandlers()`, then `PushService().init()` (non-blocking).
- `FirebaseCrashReporter` implements the same `CrashReporter` interface as the
  default `LoggingCrashReporter` — no call sites change.
- `PushService._route()` sends a notification tap's `data['route']` through
  `Get.toNamed`, the same path `AppNotification.route` uses in-app.

## Testing Crashlytics

Debug builds have collection **disabled** (`!kDebugMode`). To see a test crash:
build release, then `FirebaseCrashlytics.instance.crash()` from a throwaway
button, reopen the app so the report uploads, check the console (~5 min).

## Git hygiene (already in `.gitignore`)

`android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`,
`android/key.properties`, `*.jks` — kept out of the public repo.
