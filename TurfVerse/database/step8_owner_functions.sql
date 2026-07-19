-- Run this migration on Supabase projects created before TurfVerse Step 8.
-- It lets turf owners update their booking status and atomically reopen slots.

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

  update public.bookings set status = new_status
  where id = selected_booking.id;

  if new_status = 'cancelled' and selected_booking.slot_id is not null then
    update public.turf_slots set is_available = true
    where id = selected_booking.slot_id;
  end if;
end;
$$;

revoke all on function public.owner_update_booking_status(uuid, text)
  from public;
grant execute on function public.owner_update_booking_status(uuid, text)
  to authenticated;
