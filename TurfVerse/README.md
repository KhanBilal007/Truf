# TurfVerse

TurfVerse is a premium cricket community and turf management app built with
Flutter.

> **Security:** Never commit real API keys. Keep `.env` local and use
> `.env.example` only as a template.

## Current Modules

- Premium Flutter UI foundation with Riverpod and GoRouter
- Supabase database schema and seed files
- Supabase email/password authentication and account deletion requests
- Player dashboard and Supabase-backed player profile
- Player profile editing for role, skill, location, and availability
- Player stats placeholder
- Turf discovery with city and area search
- Turf details and available slot browsing
- Manual-payment pending bookings and cancellation
- Open match discovery with city and skill filters
- Open match creation, atomic joining, participants, and simple match chat
- Team creation with automatic captain membership
- Team details, captain-only member addition, and placeholder team stats
- Turf owner dashboard with business summary cards
- Owner turf and slot management
- Owner booking status management and revenue summaries
- Role-gated admin dashboard and platform overview lists
- Admin report resolution
- Privacy, terms, support, issue reporting, and app information screens

Online payments, photo uploads, WhatsApp confirmations, invitations, auctions,
tournaments, and advanced admin features are intentionally not included yet.

## Routes

| Route | Screen |
| --- | --- |
| `/` | Splash |
| `/onboarding` | Onboarding |
| `/role-selection` | Role selection |
| `/placeholder-login` | Login placeholder |
| `/placeholder-dashboard` | Dashboard placeholder |
| `/login` | Login |
| `/signup` | Signup |
| `/forgot-password` | Forgot password |
| `/account-settings` | Account settings |
| `/delete-account` | Account deletion request |
| `/player-dashboard` | Player dashboard |
| `/player-profile` | Player profile |
| `/edit-player-profile` | Edit player profile |
| `/player-stats` | Player stats placeholder |
| `/turfs` | Turf discovery |
| `/turf-detail/:id` | Turf details and slots |
| `/my-bookings` | Player bookings |
| `/open-matches` | Open match discovery |
| `/create-open-match` | Create open match |
| `/open-match-detail/:id` | Open match details, participants, and chat |
| `/teams` | Current player's teams |
| `/create-team` | Create a team |
| `/team-detail/:id` | Team details, members, and stats |
| `/owner-dashboard` | Turf owner business dashboard |
| `/owner-turfs` | Owner turf management |
| `/add-turf` | Add turf |
| `/edit-turf/:id` | Edit owned turf |
| `/owner-turf-slots/:turfId` | Manage owned turf slots |
| `/add-slot/:turfId` | Add owned turf slot |
| `/edit-slot/:id` | Edit owned turf slot |
| `/owner-bookings` | Bookings for owned turfs |
| `/owner-revenue` | Owner revenue summary |
| `/admin-dashboard` | Role-gated admin dashboard |
| `/admin-users` | Admin user list |
| `/admin-turfs` | Admin turf list |
| `/admin-bookings` | Admin booking list |
| `/admin-open-matches` | Admin open-match list |
| `/admin-reports` | Admin report management |
| `/privacy-policy` | Privacy policy |
| `/terms` | Terms and conditions |
| `/contact-support` | Contact support |
| `/report-issue` | Report an issue |
| `/about-app` | About TurfVerse |

## Run Locally

```bash
flutter pub get
flutter run
```

See `MANUAL_SETUP.md` for environment and verification details.

## Release Readiness

- App display name: TurfVerse
- Android application ID: `com.turfverse.app`
- iOS bundle identifier placeholder: `com.turfverse.app`
- Current version: `1.0.0+1`
- Android and iOS still use placeholder launcher artwork.
- Production signing, store listings, screenshots, public policy URLs, and a
  final production Supabase security review must be completed manually.

See `DEPLOYMENT_GUIDE.md`, `STORE_COMPLIANCE_CHECKLIST.md`, and
`TESTING_CHECKLIST.md` before publishing.
