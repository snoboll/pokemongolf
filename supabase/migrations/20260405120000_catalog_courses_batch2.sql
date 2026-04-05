-- Batch 2: 10 more Skåne golf courses

insert into public.catalog_courses (id, name, sort_order, layout) values
  ('trelleborg',     'Trelleborgs GK',          23, '{"pars":[5,3,4,4,4,3,4,3,5,3,5,3,4,5,3,4,4,5]}'::jsonb),
  ('ystad',          'Ystad GK',                 24, '{"pars":[3,4,4,4,5,4,5,3,4,5,3,4,4,4,3,4,4,4]}'::jsonb),
  ('kristianstad',   'Kristianstads GK Åhus',    25, '{"pars":[5,4,3,4,4,3,4,5,4,5,3,4,4,3,4,4,4,5]}'::jsonb),
  ('bastad',         'Båstads GK',               26, '{"pars":[5,4,4,3,4,4,4,4,4,4,3,5,5,3,4,4,3,5]}'::jsonb),
  ('angelholm',      'Ängelholms GK',            27, '{"pars":[4,4,3,5,3,4,4,3,5,4,4,5,3,4,4,5,3,4]}'::jsonb),
  ('molle',          'Mölle GK',                 28, '{"pars":[4,3,4,3,4,5,3,4,4,4,3,4,4,5,4,4,5,3]}'::jsonb),
  ('sjobo',          'Sjöbo GK',                 29, '{"pars":[4,4,4,4,3,5,5,3,4,5,4,4,3,4,3,4,4,5]}'::jsonb),
  ('rya',            'Rya GK',                   30, '{"pars":[5,3,4,3,4,3,4,5,4,4,5,4,4,3,5,3,4,4]}'::jsonb),
  ('torekov',        'Torekovs GK',              31, '{"pars":[5,4,3,4,4,5,3,4,4,3,3,5,4,4,4,4,4,3]}'::jsonb),
  ('sturup-park',    'Sturup Park GK',           32, '{"pars":[5,3,4,5,4,4,3,5,4,4,4,3,4,5,3,4,3,5]}'::jsonb)
on conflict (id) do update set
  name       = excluded.name,
  sort_order = excluded.sort_order,
  layout     = excluded.layout;
