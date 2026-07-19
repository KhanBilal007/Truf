-- TurfVerse Step 2 database schema for Supabase.
-- Run this file in the Supabase SQL Editor before running seed.sql.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  user_id uuid,
  full_name text not null,
  email text not null,
  phone text,
  role text not null check (role in ('player', 'turf_owner', 'admin')),
  city text,
  area text,
  player_role text check (
    player_role in ('batsman', 'bowler', 'all_rounder', 'wicketkeeper')
  ),
  skill_level text check (
    skill_level in ('beginner', 'intermediate', 'advanced')
  ),
  availability text check (
    availability in ('morning', 'afternoon ', 'evening', 'night')
  ),
  avatar_url text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.turfs (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid references public.profiles(id) on delete cascade,
  name text not null,
  city text not null,
  area text not null,
  address text,
  price_per_hour numeric not null check (price_per_hour >= 0),
  description text,
  amenities text[] default '{}',
  image_url text,
  is_active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.turf_slots (
  id uuid primary key default gen_random_uuid(),
  turf_id uuid references public.turfs(id) on delete cascade,
  slot_date date not null,
  start_time time not null,
  end_time time not null,
  price numeric not null check (price >= 0),
  is_available boolean default true,
  created_at timestamptz default now(),
  check (end_time > start_time)
);

create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  turf_id uuid references public.turfs(id) on delete cascade,
  slot_id uuid references public.turf_slots(id) on delete set null,
  player_id uuid references public.profiles(id) on delete cascade,
  booking_date date not null,
  start_time time not null,
  end_time time not null,
  amount numeric not null check (amount >= 0),
  status text not null default 'pending' check (
    status in ('pending', 'paid', 'cancelled')
  ),
  payment_mode text default 'manual',
  created_at timestamptz default now(),
  check (end_time > start_time)
);

create table if not exists public.teams (
  id uuid primary key default gen_random_uuid(),
  captain_id uuid references public.profiles(id) on delete cascade,
  team_name text not null,
  city text,
  logo_url text,
  description text,
  created_at timestamptz default now()
);

create table if not exists public.team_members (
  id uuid primary key default gen_random_uuid(),
  team_id uuid references public.teams(id) on delete cascade,
  player_id uuid references public.profiles(id) on delete cascade,
  role text default 'member',
  created_at timestamptz default now(),
  unique (team_id, player_id)
);

create table if not exists public.open_matches (
  id uuid primary key default gen_random_uuid(),
  created_by uuid references public.profiles(id) on delete cascade,
  turf_id uuid references public.turfs(id) on delete cascade,
  match_date date not null,
  start_time time not null,
  required_players int not null check (required_players > 0),
  joined_players int default 0 check (joined_players >= 0),
  skill_preference text check (
    skill_preference in ('any', 'beginner', 'intermediate', 'advanced')
  ),
  price_per_player numeric not null check (price_per_player >= 0),
  status text default 'open' check (status in ('open', 'full', 'cancelled')),
  created_at timestamptz default now()
);

create table if not exists public.open_match_players (
  id uuid primary key default gen_random_uuid(),
  open_match_id uuid references public.open_matches(id) on delete cascade,
  player_id uuid references public.profiles(id) on delete cascade,
  status text default 'joined' check (status in ('joined', 'cancelled')),
  created_at timestamptz default now(),
  unique (open_match_id, player_id)
);

create table if not exists public.match_comments (
  id uuid primary key default gen_random_uuid(),
  open_match_id uuid references public.open_matches(id) on delete cascade,
  player_id uuid references public.profiles(id) on delete cascade,
  comment text not null,
  created_at timestamptz default now()
);

create table if not exists public.deletion_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  email text not null,
  reason text,
  status text default 'pending' check (
    status in ('pending', 'completed', 'rejected')
  ),
  created_at timestamptz default now()
);

create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  report_type text not null,
  message text not null,
  status text default 'open' check (status in ('open', 'resolved')),
  created_at timestamptz default now()
);

-- Frequently filtered foreign keys and discovery fields.
create index if not exists profiles_city_idx on public.profiles(city);
create index if not exists profiles_area_idx on public.profiles(area);
create index if not exists turfs_owner_id_idx on public.turfs(owner_id);
create index if not exists turfs_city_idx on public.turfs(city);
create index if not exists turfs_area_idx on public.turfs(area);
create index if not exists turf_slots_turf_id_idx on public.turf_slots(turf_id);
create index if not exists bookings_turf_id_idx on public.bookings(turf_id);
create index if not exists bookings_player_id_idx on public.bookings(player_id);
create index if not exists bookings_status_idx on public.bookings(status);
create index if not exists teams_city_idx on public.teams(city);
create index if not exists team_members_player_id_idx on public.team_members(player_id);
create index if not exists open_matches_turf_id_idx on public.open_matches(turf_id);
create index if not exists open_matches_status_idx on public.open_matches(status);
create index if not exists open_match_players_player_id_idx
  on public.open_match_players(player_id);
create index if not exists open_match_players_status_idx
  on public.open_match_players(status);
create index if not exists match_comments_player_id_idx
  on public.match_comments(player_id);
create index if not exists deletion_requests_user_id_idx
  on public.deletion_requests(user_id);
create index if not exists deletion_requests_status_idx
  on public.deletion_requests(status);
create index if not exists reports_user_id_idx on public.reports(user_id);
create index if not exists reports_status_idx on public.reports(status);

-- Keep updated_at current on rows that expose that field.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists turfs_set_updated_at on public.turfs;
create trigger turfs_set_updated_at
before update on public.turfs
for each row execute function public.set_updated_at();

-- Security-definer helpers avoid recursive RLS checks in ownership policies.
create or replace function public.owns_profile(profile_uuid uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles
    where id = profile_uuid
      and id = (select auth.uid())
  );
$$;

create or replace function public.owns_turf(turf_uuid uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.turfs
    where id = turf_uuid
      and public.owns_profile(owner_id)
  );
$$;

create or replace function public.captains_team(team_uuid uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.teams
    where id = team_uuid
      and public.owns_profile(captain_id)
  );
$$;

-- Enable RLS for every application table.
alter table public.profiles enable row level security;
alter table public.turfs enable row level security;
alter table public.turf_slots enable row level security;
alter table public.bookings enable row level security;
alter table public.teams enable row level security;
alter table public.team_members enable row level security;
alter table public.open_matches enable row level security;
alter table public.open_match_players enable row level security;
alter table public.match_comments enable row level security;
alter table public.deletion_requests enable row level security;
alter table public.reports enable row level security;

-- Profiles: users can only access the profile linked to their Auth account.
create policy "profiles_select_own" on public.profiles
for select to authenticated using ((select auth.uid()) = id);
create policy "profiles_insert_own" on public.profiles
for insert to authenticated
with check (
  (select auth.uid()) = id
  and role in ('player', 'turf_owner')
);
create policy "profiles_update_own" on public.profiles
for update to authenticated
using ((select auth.uid()) = id)
with check (
  (select auth.uid()) = id
  and role in ('player', 'turf_owner')
);
create policy "profiles_delete_own" on public.profiles
for delete to authenticated using ((select auth.uid()) = id);

-- Turfs and slots: authenticated users can browse; turf owners manage theirs.
create policy "turfs_select_authenticated" on public.turfs
for select to authenticated using (true);
create policy "turfs_insert_owner" on public.turfs
for insert to authenticated with check (public.owns_profile(owner_id));
create policy "turfs_update_owner" on public.turfs
for update to authenticated
using (public.owns_profile(owner_id))
with check (public.owns_profile(owner_id));
create policy "turfs_delete_owner" on public.turfs
for delete to authenticated using (public.owns_profile(owner_id));

create policy "turf_slots_select_authenticated" on public.turf_slots
for select to authenticated using (true);
create policy "turf_slots_insert_owner" on public.turf_slots
for insert to authenticated with check (public.owns_turf(turf_id));
create policy "turf_slots_update_owner" on public.turf_slots
for update to authenticated
using (public.owns_turf(turf_id))
with check (public.owns_turf(turf_id));
create policy "turf_slots_delete_owner" on public.turf_slots
for delete to authenticated using (public.owns_turf(turf_id));

-- Bookings: players manage their bookings; turf owners can view bookings.
create policy "bookings_select_participant" on public.bookings
for select to authenticated
using (public.owns_profile(player_id) or public.owns_turf(turf_id));
create policy "bookings_insert_player" on public.bookings
for insert to authenticated with check (public.owns_profile(player_id));
create policy "bookings_update_participant" on public.bookings
for update to authenticated
using (public.owns_profile(player_id) or public.owns_turf(turf_id))
with check (public.owns_profile(player_id) or public.owns_turf(turf_id));
create policy "bookings_delete_player" on public.bookings
for delete to authenticated using (public.owns_profile(player_id));

-- Teams: authenticated users can browse; captains manage their teams.
create policy "teams_select_authenticated" on public.teams
for select to authenticated using (true);
create policy "teams_insert_captain" on public.teams
for insert to authenticated with check (public.owns_profile(captain_id));
create policy "teams_update_captain" on public.teams
for update to authenticated
using (public.owns_profile(captain_id))
with check (public.owns_profile(captain_id));
create policy "teams_delete_captain" on public.teams
for delete to authenticated using (public.owns_profile(captain_id));

create policy "team_members_select_authenticated" on public.team_members
for select to authenticated using (true);
create policy "team_members_insert_member_or_captain" on public.team_members
for insert to authenticated
with check (public.owns_profile(player_id) or public.captains_team(team_id));
create policy "team_members_update_member_or_captain" on public.team_members
for update to authenticated
using (public.owns_profile(player_id) or public.captains_team(team_id))
with check (public.owns_profile(player_id) or public.captains_team(team_id));
create policy "team_members_delete_member_or_captain" on public.team_members
for delete to authenticated
using (public.owns_profile(player_id) or public.captains_team(team_id));

-- Open matches and participation.
create policy "open_matches_select_authenticated" on public.open_matches
for select to authenticated using (true);
create policy "open_matches_insert_creator" on public.open_matches
for insert to authenticated with check (public.owns_profile(created_by));
create policy "open_matches_update_creator" on public.open_matches
for update to authenticated
using (public.owns_profile(created_by))
with check (public.owns_profile(created_by));
create policy "open_matches_delete_creator" on public.open_matches
for delete to authenticated using (public.owns_profile(created_by));

create policy "open_match_players_select_authenticated"
on public.open_match_players
for select to authenticated using (true);
create policy "open_match_players_insert_self" on public.open_match_players
for insert to authenticated with check (public.owns_profile(player_id));
create policy "open_match_players_update_self" on public.open_match_players
for update to authenticated
using (public.owns_profile(player_id))
with check (public.owns_profile(player_id));
create policy "open_match_players_delete_self" on public.open_match_players
for delete to authenticated using (public.owns_profile(player_id));

create policy "match_comments_select_authenticated" on public.match_comments
for select to authenticated using (true);
create policy "match_comments_insert_self" on public.match_comments
for insert to authenticated with check (public.owns_profile(player_id));
create policy "match_comments_update_self" on public.match_comments
for update to authenticated
using (public.owns_profile(player_id))
with check (public.owns_profile(player_id));
create policy "match_comments_delete_self" on public.match_comments
for delete to authenticated using (public.owns_profile(player_id));

-- Account requests and reports are private to the authenticated user.
create policy "deletion_requests_select_own" on public.deletion_requests
for select to authenticated using ((select auth.uid()) = user_id);
create policy "deletion_requests_insert_own" on public.deletion_requests
for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "deletion_requests_update_own" on public.deletion_requests
for update to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);
create policy "deletion_requests_delete_own" on public.deletion_requests
for delete to authenticated using ((select auth.uid()) = user_id);

create policy "reports_select_own" on public.reports
for select to authenticated using ((select auth.uid()) = user_id);
create policy "reports_insert_own" on public.reports
for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "reports_update_own" on public.reports
for update to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);
create policy "reports_delete_own" on public.reports
for delete to authenticated using ((select auth.uid()) = user_id);

-- Step 5 booking operations are atomic and keep slot updates behind RLS.
create or replace function public.book_turf_slot(slot_uuid uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  selected_slot public.turf_slots%rowtype;
  current_profile_id uuid;
  new_booking_id uuid;
begin
  select id into current_profile_id
  from public.profiles
  where id = (select auth.uid()) and role = 'player';

  if current_profile_id is null then
    raise exception 'A player profile is required to book a turf.';
  end if;

  select * into selected_slot
  from public.turf_slots
  where id = slot_uuid
  for update;

  if selected_slot.id is null or selected_slot.is_available is not true then
    raise exception 'This slot is no longer available.';
  end if;

  insert into public.bookings (
    turf_id, slot_id, player_id, booking_date, start_time, end_time,
    amount, status, payment_mode
  ) values (
    selected_slot.turf_id, selected_slot.id, current_profile_id,
    selected_slot.slot_date, selected_slot.start_time, selected_slot.end_time,
    selected_slot.price, 'pending', 'manual'
  )
  returning id into new_booking_id;

  update public.turf_slots
  set is_available = false
  where id = selected_slot.id;

  return new_booking_id;
end;
$$;

create or replace function public.cancel_pending_booking(booking_uuid uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  selected_booking public.bookings%rowtype;
begin
  select * into selected_booking
  from public.bookings
  where id = booking_uuid
    and public.owns_profile(player_id)
  for update;

  if selected_booking.id is null then
    raise exception 'Booking not found.';
  end if;

  if selected_booking.status <> 'pending' then
    raise exception 'Only pending bookings can be cancelled.';
  end if;

  update public.bookings
  set status = 'cancelled'
  where id = selected_booking.id;

  if selected_booking.slot_id is not null then
    update public.turf_slots
    set is_available = true
    where id = selected_booking.slot_id;
  end if;
end;
$$;

revoke all on function public.book_turf_slot(uuid) from public;
revoke all on function public.cancel_pending_booking(uuid) from public;
grant execute on function public.book_turf_slot(uuid) to authenticated;
grant execute on function public.cancel_pending_booking(uuid) to authenticated;

-- Step 6 match joining is atomic and prevents duplicate or over-capacity joins.
create or replace function public.join_open_match(match_uuid uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  selected_match public.open_matches%rowtype;
  current_profile_id uuid;
  next_joined_players int;
begin
  select id into current_profile_id
  from public.profiles
  where id = (select auth.uid()) and role = 'player';

  if current_profile_id is null then
    raise exception 'A player profile is required to join a match.';
  end if;

  select * into selected_match
  from public.open_matches
  where id = match_uuid
  for update;

  if selected_match.id is null then
    raise exception 'Match not found.';
  end if;

  if exists (
    select 1 from public.open_match_players
    where open_match_id = match_uuid
      and player_id = current_profile_id
      and status = 'joined'
  ) then
    raise exception 'You have already joined this match.';
  end if;

  if selected_match.status = 'full'
    or selected_match.joined_players >= selected_match.required_players then
    raise exception 'This match is already full.';
  end if;

  if selected_match.status <> 'open' then
    raise exception 'This match is not open for joining.';
  end if;

  insert into public.open_match_players (
    open_match_id, player_id, status
  ) values (
    match_uuid, current_profile_id, 'joined'
  );

  next_joined_players := selected_match.joined_players + 1;

  update public.open_matches
  set joined_players = next_joined_players,
      status = case
        when next_joined_players >= required_players then 'full'
        else 'open'
      end
  where id = match_uuid;
end;
$$;

revoke all on function public.join_open_match(uuid) from public;
grant execute on function public.join_open_match(uuid) to authenticated;

-- Step 7 team operations keep captain creation and member addition atomic.
create or replace function public.create_team_with_captain(
  team_name_value text,
  city_value text default null,
  description_value text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  current_profile_id uuid;
  new_team_id uuid;
begin
  select id into current_profile_id
  from public.profiles
  where id = (select auth.uid()) and role = 'player';

  if current_profile_id is null then
    raise exception 'A player profile is required to create a team.';
  end if;

  if nullif(trim(team_name_value), '') is null then
    raise exception 'Team name is required.';
  end if;

  insert into public.teams (captain_id, team_name, city, description)
  values (
    current_profile_id,
    trim(team_name_value),
    nullif(trim(city_value), ''),
    nullif(trim(description_value), '')
  )
  returning id into new_team_id;

  insert into public.team_members (team_id, player_id, role)
  values (new_team_id, current_profile_id, 'captain');

  return new_team_id;
end;
$$;

create or replace function public.add_team_member(
  team_uuid uuid,
  player_contact text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  target_player_id uuid;
begin
  if not public.captains_team(team_uuid) then
    raise exception 'Only the team captain can add members.';
  end if;

  select id into target_player_id
  from public.profiles
  where role = 'player'
    and (
      lower(email) = lower(trim(player_contact))
      or phone = trim(player_contact)
    )
  limit 1;

  if target_player_id is null then
    raise exception 'No player found with this email or phone.';
  end if;

  if exists (
    select 1 from public.team_members
    where team_id = team_uuid and player_id = target_player_id
  ) then
    raise exception 'This player is already a team member.';
  end if;

  insert into public.team_members (team_id, player_id, role)
  values (team_uuid, target_player_id, 'member');
end;
$$;

revoke all on function public.create_team_with_captain(text, text, text)
  from public;
revoke all on function public.add_team_member(uuid, text) from public;
grant execute on function public.create_team_with_captain(text, text, text)
  to authenticated;
grant execute on function public.add_team_member(uuid, text) to authenticated;

-- Step 8 lets turf owners safely update booking status for their own turfs.
create or replace function public.owner_update_booking_status(
  booking_uuid uuid,
  new_status text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  selected_booking public.bookings%rowtype;
begin
  if new_status not in ('paid', 'cancelled') then
    raise exception 'Unsupported booking status.';
  end if;

  select * into selected_booking
  from public.bookings
  where id = booking_uuid
    and public.owns_turf(turf_id)
  for update;

  if selected_booking.id is null then
    raise exception 'Booking not found for this turf owner.';
  end if;

  update public.bookings
  set status = new_status
  where id = selected_booking.id;

  if new_status = 'cancelled' and selected_booking.slot_id is not null then
    update public.turf_slots
    set is_available = true
    where id = selected_booking.slot_id;
  end if;
end;
$$;

revoke all on function public.owner_update_booking_status(uuid, text)
  from public;
grant execute on function public.owner_update_booking_status(uuid, text)
  to authenticated;

-- Step 9 admin authorization is enforced by RLS, not only by Flutter routes.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = (select auth.uid()) and role = 'admin'
  );
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

create policy "turfs_select_admin" on public.turfs
for select to authenticated using ((select public.is_admin()));
create policy "bookings_select_admin" on public.bookings
for select to authenticated using ((select public.is_admin()));
create policy "open_matches_select_admin" on public.open_matches
for select to authenticated using ((select public.is_admin()));
create policy "reports_select_admin" on public.reports
for select to authenticated using ((select public.is_admin()));
create policy "reports_update_admin" on public.reports
for update to authenticated
using ((select public.is_admin()))
with check ((select public.is_admin()));
