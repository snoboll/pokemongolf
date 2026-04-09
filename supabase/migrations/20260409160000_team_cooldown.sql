alter table public.profiles
  add column if not exists team_changed_at timestamptz;
