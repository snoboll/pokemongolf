-- Player inventory. One row per (player, item type) holding a quantity.
-- First item type is 'evo_hotdog', awarded on PvP wins and consumed to evolve.
create table items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) default auth.uid() not null,
  item_type text not null,
  quantity integer not null default 0,
  created_at timestamptz default now() not null,
  unique (user_id, item_type)
);

alter table items enable row level security;

create policy "Users can manage their own items"
  on items for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
