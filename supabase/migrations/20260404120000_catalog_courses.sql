-- Catalog courses: [layout] jsonb describes holes and green centers.
-- Apply in Supabase SQL editor or `supabase db push`.
--
-- Preferred shape (v2):
--   { "loops": [ { "name": "Yellow", "holes": [ { "par": 4, "green": { "lat": 0, "lng": 0 }, "meta": {} } ] } ] }
-- Legacy (still supported): flat { "pars": [...] } or { "parts": [ { "name", "pars", "greens" } ] }
-- User-created rows in [user_courses] store pars[] only; the app builds [CourseHole] without greens until added.

create table if not exists public.catalog_courses (
  id text primary key,
  name text not null,
  sort_order int not null default 0,
  layout jsonb not null
);

alter table public.catalog_courses enable row level security;

drop policy if exists "catalog_courses_select_all" on public.catalog_courses;
create policy "catalog_courses_select_all"
  on public.catalog_courses for select
  to anon, authenticated
  using (true);

insert into public.catalog_courses (id, name, sort_order, layout) values
  ('orestad', 'Örestad', 0, '{"parts":[{"name":"Yellow","pars":[4,3,4,3,4,5,4,4,4],"greens":[[55.69121,13.069258],[55.691678,13.070934],[55.694409,13.070982],[55.695727,13.073491],[55.699582,13.076975],[55.696577,13.072639],[55.693877,13.068456],[55.691476,13.06999],[55.693798,13.065204]]},{"name":"Red","pars":[4,3,4,5,4,3,4,5,4],"greens":[[55.696913,13.060952],[55.697892,13.059323],[55.700234,13.061782],[55.701203,13.068148],[55.697836,13.0706],[55.697246,13.068633],[55.700329,13.068304],[55.697581,13.063821],[55.695155,13.06607]]},{"name":"Blue","pars":[5,3,4,4,4,3,5,4,4],"greens":[[55.697336,13.072029],[55.698217,13.071827],[55.700161,13.076234],[55.698009,13.079743],[55.696133,13.075653],[55.695267,13.074012],[55.698768,13.078589],[55.696419,13.074334],[55.694345,13.066531]]}]}'::jsonb),
  ('falsterbo', 'Falsterbo GK', 1, '{"pars":[4,3,5,4,4,3,4,3,4,4,3,4,5,3,5,4,4,5]}'::jsonb),
  ('barseback-masters', 'Barsebäck Masters', 2, '{"pars":[4,4,4,3,5,4,4,3,5,4,4,5,4,4,3,5,4,4]}'::jsonb),
  ('barseback-ocean', 'Barsebäck Ocean', 3, '{"pars":[4,4,4,3,5,4,4,3,5,4,4,5,4,4,3,5,4,4]}'::jsonb),
  ('pga-national-links', 'PGA National Links', 4, '{"pars":[4,5,4,4,3,4,3,5,4,4,5,4,3,4,5,4,3,4]}'::jsonb),
  ('pga-national-lakes', 'PGA National Lakes', 5, '{"pars":[5,4,4,3,4,3,4,5,4,4,5,4,4,4,3,4,3,5]}'::jsonb),
  ('ljunghusen', 'Ljunghusen GK', 6, '{"pars":[4,4,4,3,4,5,4,4,3,4,3,5,4,5,4,3,4,5]}'::jsonb),
  ('flommen', 'Flommen GK', 7, '{"pars":[3,4,5,4,5,4,3,4,4,3,4,5,4,3,5,5,3,4]}'::jsonb),
  ('malmo-burlov', 'Malmö Burlöv GK', 8, '{"pars":[4,5,4,3,4,3,4,4,4,4,4,4,3,5,4,4,3,5]}'::jsonb),
  ('abbekas', 'Abbekås GK', 9, '{"pars":[4,4,3,4,5,3,5,4,3,4,4,5,4,3,4,4,5,4]}'::jsonb),
  ('lilla-vik', 'Lilla Vik', 10, '{"pars":[4,5,3,5,4,4,3,4,4,5,4,4,4,3,4,3,5,4]}'::jsonb),
  ('djupadal', 'Djupadal', 11, '{"pars":[5,4,3,4,3,4,3,4,5,4,3,5,4,4,3,4,4,5]}'::jsonb),
  ('romeleasen', 'Romeleåsen GK', 12, '{"pars":[4,3,4,5,4,4,5,4,3,4,5,3,4,4,4,4,3,5]}'::jsonb),
  ('bokskogen', 'Bokskogen GK', 13, '{"pars":[4,5,4,3,4,4,3,4,3,5,4,3,4,4,3,5,4,5]}'::jsonb),
  ('landskrona', 'Landskrona GK', 14, '{"pars":[4,3,5,3,5,3,4,5,5,4,4,3,5,3,5,4,4,3]}'::jsonb),
  ('tegelberga', 'Tegelberga GK', 15, '{"pars":[4,5,3,5,3,5,4,5,4,3,4,3,4,3,4,4,3,5]}'::jsonb),
  ('vasatorp', 'Vasatorp Classic', 16, '{"pars":[5,4,4,3,5,4,3,4,4,4,5,4,4,3,4,4,3,5]}'::jsonb),
  ('eslov', 'Eslöv GK', 17, '{"pars":[5,3,5,3,4,4,3,4,4,3,5,4,3,4,4,4,4,4]}'::jsonb),
  ('lund-akademiska', 'Lunds Akademiska GK', 18, '{"pars":[4,3,4,5,4,3,4,4,5,5,4,5,3,4,4,3,4,4]}'::jsonb),
  ('soderasen', 'Söderåsen GK', 19, '{"pars":[4,4,3,4,5,3,4,5,3,4,4,5,3,5,3,4,4,4]}'::jsonb),
  ('bedinge', 'Bedinge GK', 20, '{"pars":[4,4,4,3,4,5,3,4,5,3,4,4,3,5,4,4,3,4]}'::jsonb),
  ('tomelilla', 'Tomelilla GK', 21, '{"pars":[5,4,3,5,4,4,4,3,5,5,4,4,4,3,4,5,3,4]}'::jsonb),
  ('helsingborg', 'Helsingborg GK', 22, '{"pars":[4,3,5,3,4,4,4,3,4,4,3,5,3,4,4,4,3,4]}'::jsonb)
on conflict (id) do update set
  name = excluded.name,
  sort_order = excluded.sort_order,
  layout = excluded.layout;
