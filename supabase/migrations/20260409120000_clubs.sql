create table clubs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) default auth.uid() not null,
  name text not null,
  carry_distance integer,
  total_distance integer,
  sort_order integer not null default 0,
  created_at timestamptz default now() not null
);

alter table clubs enable row level security;

create policy "Users can manage their own clubs"
  on clubs for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
