-- Run this migration on Supabase projects created before TurfVerse Step 7.
-- It adds atomic captain-only team creation and member addition.

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
