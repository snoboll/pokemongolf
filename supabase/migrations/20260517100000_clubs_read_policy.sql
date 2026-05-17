-- Allow authenticated users to read any player's clubs (bag inspection).
create policy "Authenticated users can read all clubs"
  on clubs for select
  to authenticated
  using (true);
