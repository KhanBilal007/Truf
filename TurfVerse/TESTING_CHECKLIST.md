# Testing Checklist

Use a non-production Supabase project with `database/schema.sql` applied and a
valid local `.env`.

## Automated Quality Gate

- [ ] `dart format --output=none --set-exit-if-changed lib test` passes.
- [ ] `flutter analyze` reports no issues.
- [ ] `flutter test` passes.
- [ ] `flutter build apk --debug` succeeds.
- [ ] No real secrets are found in source or generated release artifacts.

## Device And UX Smoke Test

- [ ] Test on a small Android phone and a modern large Android phone.
- [ ] Test on at least one physical Android device.
- [ ] Test on iPhone and iPad before iOS submission.
- [ ] Confirm keyboard, scrolling, safe areas, rotation, and back navigation.
- [ ] Confirm loading, empty, error, retry, and offline states are readable.
- [ ] Confirm text remains usable with larger accessibility font settings.
- [ ] Confirm all destructive actions have clear language and expected results.

## Signup Test

- [ ] Open `/signup`.
- [ ] Confirm required fields, email format, password length, matching
      passwords, and Terms acceptance are validated.
- [ ] Create a Player account and confirm a matching `profiles` row exists.
- [ ] Create a Turf Owner account and confirm its profile role is
      `turf_owner`.
- [ ] Confirm player signup opens `/player-dashboard`.
- [ ] Confirm turf owner signup opens `/owner-dashboard`.

## Login Test

- [ ] Open `/login` and sign in as a Player.
- [ ] Confirm the app fetches the user's profile and opens the placeholder
      dashboard.
- [ ] Repeat with a Turf Owner account.
- [ ] Confirm turf owner login opens `/owner-dashboard`.
- [ ] Confirm admin login opens `/admin-dashboard`.

## Forgot Password Test

- [ ] Open `/forgot-password`.
- [ ] Submit a registered email.
- [ ] Confirm the success message appears.
- [ ] Confirm the reset email arrives.

## Logout Test

- [ ] Open `/account-settings`.
- [ ] Tap Logout.
- [ ] Confirm the Supabase session ends and onboarding opens.

## Delete Account Request Test

- [ ] Log in and open `/delete-account`.
- [ ] Submit a request with and without an optional reason.
- [ ] Confirm the success message appears.
- [ ] Confirm a pending row exists in `deletion_requests`.
- [ ] Confirm the Auth user was not directly deleted.

## Invalid Email/Password Test

- [ ] Try invalid email formats on login, signup, and forgot password.
- [ ] Try an incorrect password on login.
- [ ] Confirm clear validation or Supabase error messages appear.

## Player Dashboard Test

- [ ] Log in with a profile whose role is `player`.
- [ ] Confirm `/player-dashboard` opens after login.
- [ ] Confirm Find Matches opens `/open-matches`.
- [ ] Confirm Book Turf opens `/turfs`.
- [ ] Confirm My Bookings opens `/my-bookings`.
- [ ] Confirm My Teams opens `/teams`.

## Edit Player Profile Test

- [ ] Open `/edit-player-profile`.
- [ ] Update the name, optional phone, city, area, player role, skill level, and
      availability.
- [ ] Confirm invalid phone numbers are rejected.
- [ ] Save and confirm `Profile updated successfully.` appears.
- [ ] Confirm the corresponding `profiles` row contains the saved values.

## Player Profile Display Test

- [ ] Open `/player-profile`.
- [ ] Confirm the screen displays the saved name, email, phone, city, area,
      player role, skill level, and availability.
- [ ] Confirm loading and retry error states behave correctly.

## Player Profile Empty State Test

- [ ] Clear one or more cricket profile values in Supabase.
- [ ] Open `/player-profile`.
- [ ] Confirm `Your cricket profile is incomplete.` appears.
- [ ] Confirm Complete Profile opens `/edit-player-profile`.

## Turf List Test

- [ ] Open `/turfs` and confirm active turfs load.
- [ ] Search by city, area, and both fields.
- [ ] Confirm Clear resets filters.
- [ ] Confirm an unmatched search shows the empty state.

## Turf Detail and Slot Test

- [ ] Open a turf from the turf list.
- [ ] Confirm turf details, amenities, and image placeholder load.
- [ ] Confirm available and booked slot statuses display correctly.

## Booking Creation Test

- [ ] Book an available slot.
- [ ] Confirm a pending booking is created with manual payment mode.
- [ ] Confirm the slot becomes unavailable.
- [ ] Confirm the success message appears and `/my-bookings` opens.

## My Bookings and Cancellation Test

- [ ] Confirm `/my-bookings` displays the new booking and turf name.
- [ ] Confirm pending, paid, and cancelled badges display correctly.
- [ ] Cancel a pending booking.
- [ ] Confirm its status becomes cancelled and its slot becomes available.
- [ ] Confirm `Booking cancelled successfully.` appears.

## Open Matches List Test

- [ ] Open `/open-matches` and confirm open matches load.
- [ ] Filter by city and skill level.
- [ ] Confirm Refresh reloads the current filters.
- [ ] Confirm an unmatched filter shows the empty state.

## Create Open Match Test

- [ ] Open `/create-open-match`.
- [ ] Confirm available turfs load in the dropdown.
- [ ] Confirm required players must be greater than 0.
- [ ] Confirm price per player must be 0 or more.
- [ ] Create a match and confirm `Open match created successfully.` appears.

## Open Match Detail and Join Test

- [ ] Open a match detail screen.
- [ ] Confirm turf, schedule, player counts, skill, price, and status display.
- [ ] Join the match and confirm `You joined the match successfully.` appears.
- [ ] Confirm the participant appears under Joined Players.
- [ ] Attempt a duplicate join and confirm it is prevented.
- [ ] Fill the final available place and confirm the match becomes full.

## Match Comments Test

- [ ] Add a non-empty message in Match Chat.
- [ ] Confirm the latest comment displays with player name, text, and time.
- [ ] Refresh the detail screen and confirm comments still display correctly.

## Teams Screen Test

- [ ] Open `/teams` and confirm created or joined teams load.
- [ ] Confirm Refresh reloads the team list.
- [ ] Confirm the empty state links to `/create-team`.

## Create Team Test

- [ ] Open `/create-team`.
- [ ] Confirm team name is required.
- [ ] Create a team and confirm `Team created successfully.` appears.
- [ ] Confirm the current player is inserted as a captain in `team_members`.

## Team Detail and Members Test

- [ ] Open a team detail screen.
- [ ] Confirm team, captain, member count, description, and stats display.
- [ ] As captain, add a player by email and by phone.
- [ ] Confirm `Player added to team.` appears and the member list refreshes.
- [ ] Attempt to add the same player again and confirm it is prevented.
- [ ] Search for an unknown player and confirm the not-found message appears.
- [ ] Open the team as a non-captain and confirm the Add Member form is hidden.

## Turf Owner Dashboard Test

- [ ] Log in as a turf owner and confirm `/owner-dashboard` opens.
- [ ] Confirm total turfs, today's bookings, pending payments, and monthly
      revenue calculate from owned turf data only.

## Owner Turf and Slot Management Test

- [ ] Add a turf and confirm `Turf saved successfully.` appears.
- [ ] Edit the turf and confirm changes persist.
- [ ] Add a slot and confirm `Slot saved successfully.` appears.
- [ ] Edit the slot and confirm validation rejects end time before start time.
- [ ] Confirm the owner cannot open or edit another owner's turf or slot.

## Owner Bookings Test

- [ ] Open `/owner-bookings` and confirm bookings for owned turfs load.
- [ ] Mark a pending booking as paid and confirm its status changes.
- [ ] Cancel a pending booking and confirm its related slot becomes available.
- [ ] Confirm bookings for another owner's turfs never appear.

## Owner Revenue Test

- [ ] Open `/owner-revenue`.
- [ ] Confirm today's and this month's revenue use paid bookings only.
- [ ] Confirm pending amount and paid/pending booking totals calculate
      correctly.
- [ ] Confirm recent paid bookings display.

## Admin Dashboard Test

- [ ] Log in as an admin and confirm `/admin-dashboard` opens.
- [ ] Confirm admin can view users, turfs, bookings, open matches, and reports.
- [ ] Confirm dashboard totals and open report count calculate correctly.
- [ ] Mark an open report resolved and confirm its status updates.
- [ ] Open an admin route as a non-admin and confirm Access Denied appears.

## Compliance and Support Test

- [ ] Open Privacy Policy and Terms from Account Settings.
- [ ] Open About App and confirm version and tagline display.
- [ ] Submit Contact Support and confirm a `support` report is created.
- [ ] Submit Report Issue and confirm the selected report type is stored.

## Production Security Regression

- [ ] Anonymous users cannot read protected profile or operational data.
- [ ] Players cannot access owner-only or admin-only data.
- [ ] Owners cannot manage another owner's turf, slots, or bookings.
- [ ] Non-admin users cannot access admin data or resolve reports.
- [ ] Clients cannot promote their own profile role to admin.
- [ ] Duplicate bookings, joins, and team members are prevented.
- [ ] Concurrent booking and match-join tests do not exceed capacity.
- [ ] Deletion requests do not directly delete Auth users from the client.

## Release Candidate Sign-Off

- [ ] Test data and debug accounts are removed from production.
- [ ] Production URLs, email templates, and support channels are verified.
- [ ] Signed release build is tested through internal store distribution.
- [ ] Known limitations match `RELEASE_NOTES.md`.
- [ ] Product owner approves the release candidate.
