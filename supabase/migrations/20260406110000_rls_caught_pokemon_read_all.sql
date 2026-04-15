-- Allow authenticated users to view all golfers' caught bogeybeast (for golfer bogeydex feature)
drop policy if exists "Users can view all catches" on public.caught_bogeybeast;
create policy "Users can view all catches"
  on public.caught_bogeybeast
  for select
  to authenticated
  using (true);
