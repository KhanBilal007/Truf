-- Run this migration on Supabase projects created before TurfVerse Step 5.
-- It adds atomic booking and cancellation operations without weakening RLS.

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

  update public.turf_slots set is_available = false
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
  where id = booking_uuid and public.owns_profile(player_id)
  for update;

  if selected_booking.id is null then
    raise exception 'Booking not found.';
  end if;
  if selected_booking.status <> 'pending' then
    raise exception 'Only pending bookings can be cancelled.';
  end if;

  update public.bookings set status = 'cancelled'
  where id = selected_booking.id;

  if selected_booking.slot_id is not null then
    update public.turf_slots set is_available = true
    where id = selected_booking.slot_id;
  end if;
end;
$$;

revoke all on function public.book_turf_slot(uuid) from public;
revoke all on function public.cancel_pending_booking(uuid) from public;
grant execute on function public.book_turf_slot(uuid) to authenticated;
grant execute on function public.cancel_pending_booking(uuid) to authenticated;
