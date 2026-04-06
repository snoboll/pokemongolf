-- Allow authenticated users to view all trainers' caught pokemon (for trainer pokedex feature)
drop policy if exists "Users can view all catches" on public.caught_pokemon;
create policy "Users can view all catches"
  on public.caught_pokemon
  for select
  to authenticated
  using (true);
