-- Batch 3: 52 Swedish golf courses from the Sweden golf par/index report (2026-05-16).
-- Source providers: Golf i Sverige, Golfify. Par-only layouts (no green coordinates).
-- Excludes 5 report records that already exist in the catalog (same course, identical pars):
--   PGA Sweden National Links, Rya GK, Söderåsen GK, Araslöv Norra, Araslöv Södra.

insert into public.catalog_courses (id, name, sort_order, layout) values
  ('a6-golfklubb-18-halsslingkombination', 'A6 Golfklubb - 18-hålsslingkombination', 43, '{"pars":[4,3,5,4,4,4,4,3,5,4,3,4,4,4,3,5,5,4]}'::jsonb),
  ('a6-golfklubb-9-halsbana-och-pay-play', 'A6 Golfklubb - 9-hålsbana och Pay & Play', 44, '{"pars":[3,4,4,3,4,5,4,3,5,3,4,4,3,4,5,4,3,5]}'::jsonb),
  ('arlandastad-golfklubb-masters', 'Arlandastad Golfklubb - Masters', 45, '{"pars":[4,3,4,3,3,4,4,4,5,4,4,4,4,4,5,3,5,3]}'::jsonb),
  ('arninge-golfklubb', 'Arninge Golfklubb', 46, '{"pars":[5,5,3,4,4,4,4,3,4,5,3,4,3,4,5,4,3,5]}'::jsonb),
  ('botkyrka-golfklubb-18-hals', 'Botkyrka Golfklubb - 18-håls', 47, '{"pars":[5,4,5,4,3,4,5,4,3,4,3,4,5,3,4,5,4,4]}'::jsonb),
  ('bredareds-golfklubb', 'Bredareds Golfklubb', 48, '{"pars":[4,5,3,4,4,3,4,4,3,3,4,3,4,4,3,5,4,5]}'::jsonb),
  ('bro-hof-slott-golf-club-the-stadium', 'Bro Hof Slott Golf Club - The Stadium', 49, '{"pars":[5,4,4,3,4,4,3,4,5,4,3,5,5,4,5,3,3,4]}'::jsonb),
  ('gagnef-golf', 'Gagnef Golf', 50, '{"pars":[4,4,5,3,4,4,5,3,4,4,4,5,4,3,5,4,3,4]}'::jsonb),
  ('haninge-golfklubb-rod-gul', 'Haninge Golfklubb - Röd/Gul', 51, '{"pars":[5,3,4,4,5,4,4,3,4,4,5,3,5,4,4,3,4,5]}'::jsonb),
  ('haningestrand-golfklubb', 'HaningeStrand Golfklubb', 52, '{"pars":[4,5,5,4,4,3,4,3,4,4,3,5,4,3,5,4,3,5]}'::jsonb),
  ('haverdals-golfklubb-korthals', 'Haverdals Golfklubb - Korthåls', 53, '{"pars":[3,3,3,3,3,3,3,3,3]}'::jsonb),
  ('huvudstadens-golfklubb-lindo-golf-ang', 'Huvudstadens Golfklubb - Lindö Golf - Äng', 54, '{"pars":[5,4,4,5,3,4,4,3,4,5,4,3,4,4,3,4,4,5]}'::jsonb),
  ('huvudstadens-golfklubb-riksten-golf', 'Huvudstadens Golfklubb - Riksten Golf', 55, '{"pars":[5,4,3,4,5,4,4,3,4,4,4,5,3,4,5,3,4,4]}'::jsonb),
  ('hylliekrokens-golfcenter-oxie-golfklubb', 'Hylliekrokens Golfcenter / Oxie Golfklubb', 56, '{"pars":[3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3]}'::jsonb),
  ('halla-golfklubb', 'Hälla Golfklubb', 57, '{"pars":[3,5,3,4,4,4,3,4,3,3,5,3,4,4,4,3,4,3]}'::jsonb),
  ('ingaro-golfklubb-angs', 'Ingarö Golfklubb - Ängs', 58, '{"pars":[4,4,3,5,3,5,5,3,4,4,4,3,4,3,4,5,3,4]}'::jsonb),
  ('international-golf-club', 'International Golf Club', 59, '{"pars":[4,5,3,4,5,3,4,4,4,4,4,3,4,5,5,4,3,4]}'::jsonb),
  ('johannesberg-golfklubb-18-halsbanan', 'Johannesberg Golfklubb - 18-Hålsbanan', 60, '{"pars":[4,4,5,4,4,3,5,4,3,4,4,4,3,4,4,5,3,5]}'::jsonb),
  ('johannesberg-golfklubb-9-halsbanan', 'Johannesberg Golfklubb - 9-Hålsbanan', 61, '{"pars":[4,4,4,3,4,4,3,5,3,4,4,4,3,4,4,3,5,3]}'::jsonb),
  ('jonakers-golfklubb', 'Jönåkers Golfklubb', 62, '{"pars":[4,3,4,4,4,5,3,5,4,5,4,4,3,5,4,3,4,4]}'::jsonb),
  ('knistad-golf-country-club', 'Knistad Golf & Country Club', 63, '{"pars":[5,4,4,3,4,4,5,4,3,4,4,5,3,4,4,4,3,5]}'::jsonb),
  ('kungl-drottningholms-golfklubb-par-3-banan', 'Kungl. Drottningholms Golfklubb - Par 3-banan', 64, '{"pars":[3,3,3,3,3,3,3,3,3,3,3]}'::jsonb),
  ('kungalv-kode-golfklubb', 'Kungälv-Kode Golfklubb', 65, '{"pars":[4,5,3,6,3,5,4,3,4,3,4,3,5,3,4,4,4,4]}'::jsonb),
  ('karsta-golfklubb', 'Kårsta Golfklubb', 66, '{"pars":[5,4,3,4,4,3,5,3,4,5,4,3,4,3,4,3,5,4]}'::jsonb),
  ('lidkopings-golfklubb', 'Lidköpings Golfklubb', 67, '{"pars":[4,3,4,4,5,4,4,4,3,5,4,3,4,4,4,4,5,3]}'::jsonb),
  ('lycke-golf-country-club-marstrand', 'Lycke Golf & Country Club Marstrand', 68, '{"pars":[4,3,5,4,4,3,5,4,3,4,4,3,4,3,5,4,5,4]}'::jsonb),
  ('nacka-golfklubb', 'Nacka Golfklubb', 69, '{"pars":[4,4,5,4,5,3,4,4,3,4,5,4,3,4,4,3,5,4]}'::jsonb),
  ('nykopings-golfklubb-vastra-banan', 'Nyköpings Golfklubb - Västra banan', 70, '{"pars":[3,5,4,3,5,4,3,4,5,4,4,4,3,4,5,4,4,4]}'::jsonb),
  ('nykopings-golfklubb-ostra-banan', 'Nyköpings Golfklubb - Östra banan', 71, '{"pars":[4,5,3,5,4,3,4,4,4,3,4,4,4,5,4,5,4,3]}'::jsonb),
  ('rotebro-golf-6-hals', 'Rotebro Golf - 6-håls', 72, '{"pars":[3,4,3,4,3,4]}'::jsonb),
  ('salems-golfklubb-salem', 'Salems Golfklubb - Salem', 73, '{"pars":[5,4,4,3,4,5,3,4,4,3,5,4,4,3,4,4,4,4]}'::jsonb),
  ('sollentuna-golfklubb', 'Sollentuna Golfklubb', 74, '{"pars":[4,3,4,4,3,5,4,4,5,5,4,5,4,3,4,4,3,4]}'::jsonb),
  ('stockholms-golfklubb', 'Stockholms Golfklubb', 75, '{"pars":[4,4,4,3,4,3,4,4,3,5,4,3,5,3,4,3,5,4]}'::jsonb),
  ('sodertalje-park-golfklubb-bla-bana', 'Södertälje Park Golfklubb - Blå Bana', 76, '{"pars":[3,4,3,5,5,3,4,4,4,3,4,3,5,5,3,4,4,4]}'::jsonb),
  ('sodertalje-park-golfklubb-blagul-bana', 'Södertälje Park Golfklubb - Blågul Bana', 77, '{"pars":[3,4,3,5,5,3,4,4,4,3,3,3,3,3,3,3,3,3]}'::jsonb),
  ('sodertalje-park-golfklubb-gul-bana', 'Södertälje Park Golfklubb - Gul Bana', 78, '{"pars":[3,3,3,3,3,3,3,3,3]}'::jsonb),
  ('tjusta-golfklubb', 'Tjusta Golfklubb', 79, '{"pars":[4,4,3,4,5,3,5,4,4,4,5,3,4,4,4,4,3,4]}'::jsonb),
  ('troxhammar-golfklubb-18-hals', 'Troxhammar Golfklubb - 18-håls', 80, '{"pars":[4,5,4,3,5,4,3,5,4,4,3,4,3,5,5,4,3,4]}'::jsonb),
  ('ullna-golf-club', 'Ullna Golf Club', 81, '{"pars":[5,4,3,5,3,4,4,4,4,4,3,5,5,4,4,3,4,4]}'::jsonb),
  ('vallentuna-golfklubb', 'Vallentuna Golfklubb', 82, '{"pars":[4,5,3,4,4,3,5,4,4,4,4,3,5,4,3,4,5,4]}'::jsonb),
  ('vasatorps-golfklubb-tournament', 'Vasatorps Golfklubb - Tournament', 83, '{"pars":[4,3,5,3,4,5,4,4,4,5,4,5,4,3,4,4,3,4]}'::jsonb),
  ('vetlanda-golfklubb', 'Vetlanda Golfklubb', 84, '{"pars":[5,4,4,3,5,4,4,3,4,4,4,4,4,5,3,4,4,3]}'::jsonb),
  ('visby-golfklubb-18-hals', 'Visby Golfklubb - 18-håls', 85, '{"pars":[3,4,4,5,3,5,3,4,4,5,4,4,4,3,4,5,3,5]}'::jsonb),
  ('wermdo-golf-country-club', 'Wermdö Golf & Country Club', 86, '{"pars":[4,4,5,5,3,4,4,3,4,3,4,3,5,3,4,5,4,4]}'::jsonb),
  ('wasby-golfklubb-john-deerebanan', 'Wäsby Golfklubb - John Deerebanan', 87, '{"pars":[4,3,4,4,3,5,4,5,4,4,5,3,4,4,5,3,4,4]}'::jsonb),
  ('wasby-golfklubb-nibblebanan', 'Wäsby Golfklubb - Nibblebanan', 88, '{"pars":[4,3,4,3,4,4,5,5,4,4,3,4,3,4,4,5,5,4]}'::jsonb),
  ('agesta-golfklubb-18-hals', 'Ågesta Golfklubb - 18-håls', 89, '{"pars":[4,3,4,3,4,4,5,4,4,3,4,5,3,5,4,5,3,4]}'::jsonb),
  ('akersberga-golfklubb', 'Åkersberga Golfklubb', 90, '{"pars":[5,5,3,5,3,4,3,4,4,4,3,4,3,4,5,4,3,5]}'::jsonb),
  ('orebro-city-golf-country-club-elon-ljud-bildbanan-pay-play', 'Örebro City Golf & Country Club - ELON Ljud & Bildbanan Pay&Play', 91, '{"pars":[3,3,3,3,3,3,4,4,3,3,3,3,3,3,3,4,4,3]}'::jsonb),
  ('orebro-city-golf-country-club-gustavsviksbanan', 'Örebro City Golf & Country Club - Gustavsviksbanan', 92, '{"pars":[5,3,4,3,4,4,4,3,4,5,4,5,4,3,4,4,3,4]}'::jsonb),
  ('orebro-city-golf-country-club-mosjobanan', 'Örebro City Golf & Country Club - Mosjöbanan', 93, '{"pars":[4,4,3,5,3,4,4,5,4,4,4,4,3,5,4,3,4,4]}'::jsonb),
  ('oresunds-golfklubb', 'Öresunds Golfklubb', 94, '{"pars":[4,4,5,4,3,4,3,4,3,4,3,5,3,4,4,5,5,4]}'::jsonb)
on conflict (id) do update set
  name       = excluded.name,
  sort_order = excluded.sort_order,
  layout     = excluded.layout;

-- Club coordinates (looked up; layouts of the same club share a location).
update public.catalog_courses set lat = 57.7723, lng = 14.2075 where id = 'a6-golfklubb-18-halsslingkombination';
update public.catalog_courses set lat = 57.7723, lng = 14.2075 where id = 'a6-golfklubb-9-halsbana-och-pay-play';
update public.catalog_courses set lat = 59.6046, lng = 17.8826 where id = 'arlandastad-golfklubb-masters';
update public.catalog_courses set lat = 59.4862, lng = 18.1245 where id = 'arninge-golfklubb';
update public.catalog_courses set lat = 59.1570, lng = 17.8210 where id = 'botkyrka-golfklubb-18-hals';
update public.catalog_courses set lat = 57.8157, lng = 12.9089 where id = 'bredareds-golfklubb';
update public.catalog_courses set lat = 59.4956, lng = 17.6258 where id = 'bro-hof-slott-golf-club-the-stadium';
update public.catalog_courses set lat = 60.5306, lng = 15.0429 where id = 'gagnef-golf';
update public.catalog_courses set lat = 59.1103, lng = 18.1961 where id = 'haninge-golfklubb-rod-gul';
update public.catalog_courses set lat = 59.1196, lng = 18.1605 where id = 'haningestrand-golfklubb';
update public.catalog_courses set lat = 56.7156, lng = 12.7058 where id = 'haverdals-golfklubb-korthals';
update public.catalog_courses set lat = 59.5546, lng = 18.0312 where id = 'huvudstadens-golfklubb-lindo-golf-ang';
update public.catalog_courses set lat = 59.1690, lng = 17.9289 where id = 'huvudstadens-golfklubb-riksten-golf';
update public.catalog_courses set lat = 55.5929, lng = 12.9464 where id = 'hylliekrokens-golfcenter-oxie-golfklubb';
update public.catalog_courses set lat = 59.6107, lng = 16.6262 where id = 'halla-golfklubb';
update public.catalog_courses set lat = 59.2860, lng = 18.4520 where id = 'ingaro-golfklubb-angs';
update public.catalog_courses set lat = 59.6900, lng = 18.0213 where id = 'international-golf-club';
update public.catalog_courses set lat = 59.7303, lng = 18.1921 where id = 'johannesberg-golfklubb-18-halsbanan';
update public.catalog_courses set lat = 59.7303, lng = 18.1921 where id = 'johannesberg-golfklubb-9-halsbanan';
update public.catalog_courses set lat = 58.7473, lng = 16.7164 where id = 'jonakers-golfklubb';
update public.catalog_courses set lat = 58.4213, lng = 13.9461 where id = 'knistad-golf-country-club';
update public.catalog_courses set lat = 59.3192, lng = 17.8580 where id = 'kungl-drottningholms-golfklubb-par-3-banan';
update public.catalog_courses set lat = 57.9575, lng = 11.7998 where id = 'kungalv-kode-golfklubb';
update public.catalog_courses set lat = 59.3503, lng = 15.2034 where id = 'karsta-golfklubb';
update public.catalog_courses set lat = 58.4926, lng = 13.2614 where id = 'lidkopings-golfklubb';
update public.catalog_courses set lat = 57.8668, lng = 11.7161 where id = 'lycke-golf-country-club-marstrand';
update public.catalog_courses set lat = 59.3379, lng = 18.3550 where id = 'nacka-golfklubb';
update public.catalog_courses set lat = 58.7314, lng = 16.9768 where id = 'nykopings-golfklubb-vastra-banan';
update public.catalog_courses set lat = 58.7314, lng = 16.9768 where id = 'nykopings-golfklubb-ostra-banan';
update public.catalog_courses set lat = 59.4938, lng = 17.8806 where id = 'rotebro-golf-6-hals';
update public.catalog_courses set lat = 59.2581, lng = 17.6076 where id = 'salems-golfklubb-salem';
update public.catalog_courses set lat = 59.4674, lng = 17.9074 where id = 'sollentuna-golfklubb';
update public.catalog_courses set lat = 59.3942, lng = 18.0304 where id = 'stockholms-golfklubb';
update public.catalog_courses set lat = 59.1899, lng = 17.5643 where id = 'sodertalje-park-golfklubb-bla-bana';
update public.catalog_courses set lat = 59.1899, lng = 17.5643 where id = 'sodertalje-park-golfklubb-blagul-bana';
update public.catalog_courses set lat = 59.1899, lng = 17.5643 where id = 'sodertalje-park-golfklubb-gul-bana';
update public.catalog_courses set lat = 59.6056, lng = 17.9966 where id = 'tjusta-golfklubb';
update public.catalog_courses set lat = 59.3146, lng = 17.7663 where id = 'troxhammar-golfklubb-18-hals';
update public.catalog_courses set lat = 59.4953, lng = 18.1521 where id = 'ullna-golf-club';
update public.catalog_courses set lat = 59.5614, lng = 18.1073 where id = 'vallentuna-golfklubb';
update public.catalog_courses set lat = 56.0569, lng = 12.7913 where id = 'vasatorps-golfklubb-tournament';
update public.catalog_courses set lat = 57.4098, lng = 15.0467 where id = 'vetlanda-golfklubb';
update public.catalog_courses set lat = 57.4407, lng = 18.1197 where id = 'visby-golfklubb-18-hals';
update public.catalog_courses set lat = 59.3039, lng = 18.4543 where id = 'wermdo-golf-country-club';
update public.catalog_courses set lat = 59.5374, lng = 17.9589 where id = 'wasby-golfklubb-john-deerebanan';
update public.catalog_courses set lat = 59.5374, lng = 17.9589 where id = 'wasby-golfklubb-nibblebanan';
update public.catalog_courses set lat = 59.2234, lng = 18.0826 where id = 'agesta-golfklubb-18-hals';
update public.catalog_courses set lat = 59.5125, lng = 18.2903 where id = 'akersberga-golfklubb';
update public.catalog_courses set lat = 59.2506, lng = 15.2115 where id = 'orebro-city-golf-country-club-elon-ljud-bildbanan-pay-play';
update public.catalog_courses set lat = 59.2506, lng = 15.2115 where id = 'orebro-city-golf-country-club-gustavsviksbanan';
update public.catalog_courses set lat = 59.2506, lng = 15.2115 where id = 'orebro-city-golf-country-club-mosjobanan';
update public.catalog_courses set lat = 55.8538, lng = 12.9038 where id = 'oresunds-golfklubb';
