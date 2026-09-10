# Firebase setup (FCM + Crashlytics)

The app already has the **seam** for this (`core/observability/CrashReporter`,
and a `PushService` interface will slot in the same way). Firebase packages are
**not** added yet because `firebase_core` fails the Android build without a real
`google-services.json`.

## What you do

1. In the Firebase console, add two apps to the project:
   - **Android** — package name `com.bizops360.app`
   - **iOS** — bundle id `com.bizops360.app`
2. Download and place the config files (both are git-ignored — see below):
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist` (add it to the Runner target in Xcode)
3. Tell me they're in place.

## What I do once the files land

- add `firebase_core`, `firebase_messaging`, `firebase_crashlytics` to `pubspec.yaml`
- uncomment the two Gradle plugin lines in `android/app/build.gradle.kts`
  (`com.google.gms.google-services`, `com.google.firebase.crashlytics`) and add
  the classpath to `android/settings.gradle.kts`
- `bootstrap.dart`: `await Firebase.initializeApp(...)`, then
  `CrashReporter.instance = FirebaseCrashReporter()` (implements the existing
  interface — records errors, sets the user/tenant keys `AuthController` already
  emits, forwards `FlutterError` / zone errors)
- add `PushService` (interface + `FirebaseMessagingPushService`): request
  permission, get the FCM token, register it via
  `AuthRepository.registerDevice(token)` → `POST /api/v1/devices` (backend 7a),
  `DELETE` on sign-out; foreground + background message handlers route
  `data.route` through the existing `NotificationsController.open` deep-link path
- iOS: add the Push Notifications + Background Modes (remote notification)
  capabilities to the Runner target; APNs key uploaded to Firebase

## Git hygiene

Add to `.gitignore` (do this now, before the files exist):
```
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```
These contain project keys — keep them out of the public repo. They're not
secret-secret (they ship in the app binary) but there's no reason to publish
them, and Crashlytics/FCM API keys are best kept private.
