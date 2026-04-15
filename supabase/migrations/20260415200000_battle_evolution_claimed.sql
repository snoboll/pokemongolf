-- Track whether the winner has used their evolution reward for a given battle.
alter table public.battles
  add column if not exists evolution_claimed boolean default false;
