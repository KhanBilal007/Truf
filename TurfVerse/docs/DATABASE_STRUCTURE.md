# Database Structure

The TurfVerse database uses Supabase Postgres. Application tables live in the
`public` schema, while login users will live in Supabase's managed `auth.users`
table.

## Tables

### profiles

Stores each TurfVerse user's public app profile. A profile can belong to a
player, turf owner, or admin. Player profiles can also store cricket role,
skill level, and availability. `profiles.id` is the matching `auth.users.id`.
The legacy `user_id` column is not used by the app.

### turfs

Stores turf listings created by turf owners. Each turf has a Pune-style
location, hourly price, amenities, description, and active status.

### turf_slots

Stores bookable time windows for each turf. A slot includes its date, start and
end time, price, and availability.

### bookings

Stores a player's turf reservation. It records the turf, optional slot,
booking time, amount, payment mode, and payment or cancellation status.

### teams

Stores cricket teams. Each team has a captain profile and can include a city,
logo, and description.

### team_members

Connects player profiles to teams. The same player can only appear once in a
team.

### open_matches

Stores matches that are looking for players. Each record identifies the
creator, turf, date, player count, preferred skill level, price, and status.

### open_match_players

Connects players to open matches and records whether they are currently joined
or cancelled. A player can only join the same open match once.

### match_comments

Stores player comments on open matches.

### deletion_requests

Stores account deletion requests linked directly to Supabase Auth users.

### reports

Stores support or safety reports submitted by Supabase Auth users.

## Relationships

- An Auth user can have one profile with the same primary-key ID.
- A turf owner profile can own many turfs.
- A turf can have many slots, bookings, and open matches.
- A player profile can create bookings, captain teams, join teams, create or
  join open matches, and write match comments.
- Deleting parent records automatically removes dependent records where the
  schema uses `on delete cascade`.

## Security

Row level security is enabled on every application table.

- Users can only read and manage their own profile.
- Authenticated users can browse discovery data such as turfs, teams, slots,
  open matches, participants, and comments.
- Turf owners can manage their own turfs and slots and view related bookings.
- Team captains can manage their team's membership.
- Deletion requests and reports are private to the Auth user who created them.

An admin-facing directory of other users' profiles requires a protected
server-side function or a separate reviewed RLS policy. It is not available
through the self-only profile policy.

The policies use `auth.uid()` and helper functions to determine ownership.
Every app profile must use its matching Supabase Auth user ID as `profiles.id`.

## Automation and Indexes

The `profiles` and `turfs` tables automatically refresh `updated_at` whenever a
row changes.

Indexes cover frequently filtered ownership, location, relationship, and
status columns such as `owner_id`, `turf_id`, `player_id`, `city`, `area`, and
`status`.
