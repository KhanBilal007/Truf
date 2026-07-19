-- Run this migration on Supabase projects created before TurfVerse Step 6.
-- It adds atomic open-match joining without weakening RLS.

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

  insert into public.open_match_players (open_match_id, player_id, status)
  values (match_uuid, current_profile_id, 'joined');

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
