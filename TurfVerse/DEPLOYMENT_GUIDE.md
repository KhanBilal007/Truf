# Deployment Guide

## Release Prerequisites

- Complete every blocking item in `TESTING_CHECKLIST.md` and
  `STORE_COMPLIANCE_CHECKLIST.md`.
- Use a production Supabase project with reviewed RLS policies.
- Copy `.env.example` to `.env` and add production client values locally.
- Never put a Supabase service-role key in the app.
- Replace placeholder launcher icons and prepare store screenshots.
- Confirm `com.turfverse.app` is available and final before store registration.

## Versioning

The initial release is `1.0.0+1` in `pubspec.yaml`:

- Android version name: `1.0.0`
- Android version code: `1`
- iOS short version: `1.0.0`
- iOS build number: `1`

Increase the build number for every uploaded build.

## Local Verification

```bash
flutter clean
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release
flutter build appbundle --release
flutter build ios --release
```

The iOS command requires macOS, Xcode, an Apple Developer account, a registered
bundle ID, and manually configured signing.

## Supabase Deployment

1. Create the production Supabase project.
2. Run `database/schema.sql`, then required step migration SQL files.
3. Run `database/seed.sql` only if production-safe seed data is needed.
4. Configure email Auth, redirect URLs, and email templates.
5. Add the production project URL and anon key to the local `.env`.
6. Test connection, authentication, RLS, and role routing.

## Android Release

1. Create a private upload keystore and store it outside source control.
2. Add a private `key.properties` file and configure release signing in
   `android/app/build.gradle.kts`.
3. Replace all launcher icon mipmap assets.
4. Build the Play Store bundle:

```bash
flutter build appbundle --release
```

5. Test the signed bundle through Play Console internal testing.
6. Complete Data safety, content rating, app access, ads, target audience,
   privacy policy, and account deletion declarations.

The current release Gradle configuration intentionally uses debug signing and
must not be uploaded as a production release.

## iOS Release

1. Open `ios/Runner.xcworkspace` on macOS with Xcode.
2. Use an Apple Developer account, register the Bundle ID, select the correct
   team, and confirm the bundle identifier.
3. Replace AppIcon assets and verify launch artwork.
4. Confirm the iOS 13.0 deployment target supports the intended audience.
5. Configure signing, archive the app, and upload through Xcode.
6. Complete App Privacy, age rating, review notes, support URL, privacy URL,
   and account deletion information in App Store Connect.

An iOS production build cannot be produced from this Windows workspace.

## Post-Deployment Checks

- Test signup, login, password reset, logout, and deletion requests.
- Verify player, turf owner, and admin role routing.
- Confirm RLS blocks cross-owner and non-admin access.
- Monitor Supabase Auth, database logs, reports, and deletion requests.
- Process deletion requests manually until a secure server-side workflow exists.
