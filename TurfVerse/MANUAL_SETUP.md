# Manual Setup

## Requirements

- Flutter 3.41 or later
- Dart 3.11 or later
- A configured Android, iOS, web, Windows, macOS, or Linux target
- A Supabase project for integration testing

## Setup

From the TurfVerse project directory:

```bash
flutter pub get
flutter run
```

Copy `.env.example` to `.env` and replace both placeholder values:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

The Supabase URL and anon key are public client configuration, but real values
must not be committed. Never add a service-role key to the Flutter app.

Confirm `.env` remains ignored before every release:

```bash
git check-ignore .env
```

## Supabase Database Setup

Step 2 adds SQL and documentation only. It does not connect the Flutter app to
Supabase.

1. Create a Supabase project.
2. Run `database/schema.sql` in the Supabase SQL Editor.
3. Run `database/seed.sql` in the Supabase SQL Editor.
4. Follow `docs/SUPABASE_SETUP.md` for the complete setup and verification
   process.
5. Create an admin Auth user, link its `profiles.user_id`, and set its profile
   role to `admin` manually from the protected Supabase dashboard or SQL editor.

For a Supabase project that was configured before Step 5, also run
`database/step5_booking_functions.sql`. It adds the secure atomic booking and
cancellation functions used by the Flutter app.

For a Supabase project that was configured before Step 6, also run
`database/step6_open_match_functions.sql`. It adds the secure atomic join
operation that prevents duplicate and over-capacity match joins.

For a Supabase project that was configured before Step 7, also run
`database/step7_team_functions.sql`. It adds atomic team creation with captain
membership and captain-only member addition.

For a Supabase project that was configured before Step 8, also run
`database/step8_owner_functions.sql`. It adds secure owner booking status
updates and atomically reopens cancelled slots.

For a Supabase project that was configured before Step 9, also run
`database/step9_admin_policies.sql`. It adds role-gated admin read access and
report resolution policies.

The seed file does not create records directly in `auth.users`. Its sample
profiles have a `NULL` `user_id`. To test authenticated access later, create
users through Supabase Auth and manually link each profile to the matching Auth
user ID.

## Authentication Setup

Step 3 connects the Flutter app to Supabase Auth.

For the current MVP signup flow, disable **Confirm email** in the Supabase Auth
provider settings. This gives the newly created user an authenticated session,
allowing the client to insert its protected `profiles` row and continue to the
placeholder dashboard.

Before enabling email confirmation in production, move profile creation to a
secure database trigger or server-side function so profiles are created safely
when a user confirms their email.

Password reset emails require the correct redirect URLs and email templates in
Supabase Auth settings.

Before production, review all RLS policies with separate player, turf owner,
admin, and anonymous test accounts. Confirm clients cannot update roles, read
other users' private data, or manage another owner's resources.

## Account Deletion Operations

The app only inserts a pending row into `deletion_requests`; it does not delete
Supabase Auth users from the client.

- An admin must manually review and process deletion requests in Supabase.
- A later step should add a secure Supabase Edge Function for direct deletion.
- Google Play requires a public web deletion request URL. Use this placeholder
  until the production page exists: https://turfverse.in/delete-account

Replace the placeholder with a working public form before store submission.

## Verification

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

## Manual Release Setup

- Replace Android mipmap and iOS AppIcon placeholder artwork.
- Prepare phone screenshots for player and turf owner flows.
- Configure Android release signing outside source control.
- Configure a Google Play Console app and complete internal testing.
- Configure an Apple Developer account, then configure iOS signing and
  capabilities in Xcode on macOS.
- Confirm the final application ID and bundle ID before store registration.
- Publish a real privacy policy web page.
- Publish a real account deletion page at
  https://turfverse.in/delete-account.
- Publish real terms and support pages.
- Configure production Supabase redirect URLs and email templates.
- Review and test Supabase RLS, backups, rate limits, and database indexes.
- Create player, turf owner, and admin store-review test accounts.
- Complete Play Console and App Store privacy questionnaires.

## External Integrations Not Configured

- Booking payment status is manual for the MVP.
- Razorpay/UPI payment integration will be added later.
- Turf image upload and Supabase Storage integration will be added later.
- WhatsApp booking confirmations will be added later.
- Online payment settlement will be added later.
- Push notifications will be added later.

## Current Boundaries

Online payments, photo uploads, WhatsApp confirmations, invitations, auctions,
tournaments, and advanced admin features are not configured yet.

See `DEPLOYMENT_GUIDE.md` for signing and store build instructions.
