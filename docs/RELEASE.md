# Release build & store setup

Identifiers (both platforms): **`com.bizops360.app`**
App display name: **BizOps 360**

## Versioning

Bump `version:` in `pubspec.yaml` — `x.y.z+build`. The `+build` integer must
increase on every store upload; `x.y.z` is the user-facing version.
`versionCode` / `versionName` (Android) and `CFBundleVersion` /
`CFBundleShortVersionString` (iOS) are derived from it by Flutter.

## Android — signing

1. Generate an upload keystore (once, keep it safe and backed up):
   ```
   keytool -genkey -v -keystore ~/bizops-upload.jks -keyalg RSA -keysize 2048 \
     -validity 10000 -alias upload
   ```
2. Create `android/key.properties` (git-ignored):
   ```
   storePassword=…
   keyPassword=…
   keyAlias=upload
   storeFile=/absolute/path/to/bizops-upload.jks
   ```
3. `android/app/build.gradle.kts` already reads that file — when it's present the
   `release` build type signs with it; when absent it falls back to debug keys.

Build:
```
flutter build appbundle -t lib/main_prod.dart --dart-define=API_BASE_URL=https://api.bizops360.app
```
Upload `build/app/outputs/bundle/prodRelease/app-prod-release.aab` (or
`releaseRelease` depending on flavor) to Play Console → internal testing track.

> Note: `flutter build apk --debug` uses `compileSdk 36` (pinned in
> `build.gradle.kts` because the toolchain default 37 is an uninstallable
> preview). Bump both together when 37 is released.

## iOS — signing

Set the Team + a distribution provisioning profile in Xcode (`Runner` target →
Signing & Capabilities), then:
```
flutter build ipa -t lib/main_prod.dart --dart-define=API_BASE_URL=https://api.bizops360.app
```
Upload via Xcode Organizer or `xcrun altool` to App Store Connect → TestFlight.

## Store assets (still to produce)

- App icon: replace `android/app/src/main/res/mipmap-*` and
  `ios/Runner/Assets.xcassets/AppIcon.appiconset` (use `flutter_launcher_icons`
  or a designed set from the mockup mark).
- Adaptive icon (Android), 1024² marketing icon (iOS).
- Splash: `flutter_native_splash` from the hangar-green ground + `AppLogo`.
- Screenshots per device class, short + full description, privacy policy URL,
  data-safety form (the app stores an auth token + prefs locally, talks only to
  the tenant API).

## Pre-submission checklist

- `flutter build appbundle` / `flutter build ipa` succeed against the **prod**
  entrypoint and real `API_BASE_URL`
- `USE_FAKE_DATA` is **not** passed (prod build ignores it anyway — see `Env`)
- crash reporting attached (see `docs/FIREBASE.md`)
- version bumped, release notes written
- test the signed build on a real device: sign in, core flows, bn + dark
