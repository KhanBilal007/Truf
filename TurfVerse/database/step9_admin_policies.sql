-- Run this migration on Supabase projects created before TurfVerse Step 9.
-- It grants admin profiles read access to admin datasets and report updates.

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
