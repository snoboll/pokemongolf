-- Rename legacy identifiers to bogeybeast/golfer.
-- The app code was updated but the DB schema was never migrated.

-- 1. Rename legacy catch table → caught_bogeybeast
do $$ begin
  if exists (
    select 1 from information_schema.tables
    where table_schema = 'public' and table_name = 'caught_pokemon'
  ) then
    alter table public.caught_pokemon rename to caught_bogeybeast;
  end if;
end $$;

-- 2. Rename hole_results legacy dex column → bogeybeast_dex
do $$ begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'hole_results' and column_name = 'pokemon_dex'
  ) then
    alter table public.hole_results rename column pokemon_dex to bogeybeast_dex;
  end if;
end $$;

-- 3. Rename profiles columns
do $$ begin
  if exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'profiles' and column_name = 'trainer_name') then
    alter table public.profiles rename column trainer_name to golfer_name;
  end if;
  if exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'profiles' and column_name = 'trainer_sprite') then
    alter table public.profiles rename column trainer_sprite to golfer_sprite;
  end if;
  if exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'profiles' and column_name = 'trainer_team') then
    alter table public.profiles rename column trainer_team to golfer_team;
  end if;
end $$;

-- 4. Rename course_leaders columns
do $$ begin
  if exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'course_leaders' and column_name = 'trainer_sprite') then
    alter table public.course_leaders rename column trainer_sprite to golfer_sprite;
  end if;
  if exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'course_leaders' and column_name = 'trainer_team') then
    alter table public.course_leaders rename column trainer_team to golfer_team;
  end if;
end $$;

-- 5. Create get_golfer_catch_counts RPC (used by leaderboard screen)
create or replace function get_golfer_catch_counts()
returns table(user_id uuid, catch_count bigint)
language sql
security definer
as $$
  select user_id, count(*) as catch_count
  from public.caught_bogeybeast
  group by user_id;
$$;
