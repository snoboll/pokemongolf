-- Allow authenticated users to delete their own progress (app "Reset all progress").
-- Without these policies, DELETE succeeds with 0 rows under RLS and the Pokedex never clears.
--
-- Apply in Supabase SQL editor or: supabase db push

-- caught_pokemon: rows are scoped by user_id
drop policy if exists "Users can delete own catches" on public.caught_pokemon;
create policy "Users can delete own catches"
  on public.caught_pokemon
  for delete
  to authenticated
  using (user_id = auth.uid());

-- rounds: rows are scoped by user_id
drop policy if exists "Users can delete own rounds" on public.rounds;
create policy "Users can delete own rounds"
  on public.rounds
  for delete
  to authenticated
  using (user_id = auth.uid());

-- hole_results: linked to rounds; only allow delete when the round belongs to the caller
drop policy if exists "Users can delete hole results for own rounds" on public.hole_results;
create policy "Users can delete hole results for own rounds"
  on public.hole_results
  for delete
  to authenticated
  using (
    exists (
      select 1
      from public.rounds r
      where r.id = hole_results.round_id
        and r.user_id = auth.uid()
    )
  );
