-- Allow authenticated users to view all trainers' caught pokemon (for trainer pokedex feature)
create policy "Users can view all catches"
  on public.caught_pokemon
  for select
  to authenticated
  using (true);
