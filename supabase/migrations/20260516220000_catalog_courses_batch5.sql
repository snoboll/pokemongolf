-- Batch 5: Swedish golf courses — Smaland/Blekinge/Oland, Bohuslan/Vastergotland, Skane/Gotland.
-- Per-hole pars verified from public scorecards (golfisverige.com, caddee.se).

insert into public.catalog_courses (id, name, sort_order, layout) values
  ('vaxjo-golfklubb', 'Växjö Golfklubb', 155, '{"pars":[3,5,4,4,5,4,3,5,4,4,4,3,4,3,4,5,4,4]}'::jsonb),
  ('kalmar-golfklubb-gamla-banan', 'Kalmar Golfklubb - Gamla Banan', 156, '{"pars":[3,4,4,4,4,3,5,5,4,4,4,5,3,5,4,3,4,4]}'::jsonb),
  ('kalmar-golfklubb-nya-banan', 'Kalmar Golfklubb - Nya Banan', 157, '{"pars":[3,5,5,3,4,4,4,3,5,3,5,5,4,4,3,4,4,3]}'::jsonb),
  ('jonkopings-golfklubb', 'Jönköpings Golfklubb', 158, '{"pars":[5,4,4,4,3,4,4,3,4,3,3,5,4,5,4,3,4,4]}'::jsonb),
  ('isaberg-golfklubb-vastra', 'Isaberg Golfklubb - Västra', 159, '{"pars":[4,4,3,4,3,4,4,5,4,4,5,4,3,4,3,4,5,4]}'::jsonb),
  ('isaberg-golfklubb-ostra', 'Isaberg Golfklubb - Östra', 160, '{"pars":[4,3,5,4,4,3,5,4,4,5,4,5,4,4,3,4,3,4]}'::jsonb),
  ('varnamo-golfklubb', 'Värnamo Golfklubb', 161, '{"pars":[5,4,4,5,3,4,4,4,3,4,3,4,5,3,5,4,4,4]}'::jsonb),
  ('eksjo-golfklubb-skedhult', 'Eksjö Golfklubb - Skedhult', 162, '{"pars":[4,5,3,4,4,4,3,5,4,4,3,4,5,4,4,3,5,4]}'::jsonb),
  ('tranas-golfklubb-norraby', 'Tranås Golfklubb - Norraby', 163, '{"pars":[4,4,5,4,3,4,5,3,4,3,5,3,4,5,4,4,4,4]}'::jsonb),
  ('hooks-golfklubb-parkbanan', 'Hooks Golfklubb - Parkbanan', 164, '{"pars":[4,4,3,5,4,3,3,4,4,5,4,4,3,4,5,5,4,4]}'::jsonb),
  ('hooks-golfklubb-skogsbanan', 'Hooks Golfklubb - Skogsbanan', 165, '{"pars":[5,4,4,3,5,4,3,4,4,4,4,5,3,4,4,4,5,5]}'::jsonb),
  ('nassjo-golfklubb', 'Nässjö Golfklubb', 166, '{"pars":[4,4,5,3,4,5,4,3,4,4,4,3,4,5,4,4,3,5]}'::jsonb),
  ('skinnarebo-golf-country-club', 'Skinnarebo Golf & Country Club', 167, '{"pars":[4,4,4,4,3,4,3,4,5,4,4,5,3,5,3,4,4,4]}'::jsonb),
  ('carlskrona-golfklubb', 'Carlskrona Golfklubb', 168, '{"pars":[3,5,3,5,3,4,4,4,5,3,4,4,4,4,3,4,4,4]}'::jsonb),
  ('ronneby-golfklubb', 'Ronneby Golfklubb', 169, '{"pars":[4,3,5,4,3,5,3,4,3,4,4,4,4,4,3,4,4,5]}'::jsonb),
  ('trummenas-golfklubb', 'Trummenäs Golfklubb', 170, '{"pars":[4,4,4,3,4,3,5,4,5,4,5,3,4,4,5,3,4,4]}'::jsonb),
  ('solvesborgs-golfklubb', 'Sölvesborgs Golfklubb', 171, '{"pars":[4,3,5,4,3,4,4,4,5,4,3,4,5,3,4,4,5,4]}'::jsonb),
  ('ekerum-golfklubb-lange-erik', 'Ekerum Golfklubb - Långe Erik', 172, '{"pars":[4,4,3,5,3,4,4,4,4,5,4,3,4,4,5,4,3,5]}'::jsonb),
  ('ekerum-golfklubb-lange-jan', 'Ekerum Golfklubb - Långe Jan', 173, '{"pars":[4,4,3,4,5,4,5,4,3,4,3,4,4,4,5,3,4,5]}'::jsonb),
  ('oskarshamns-golfklubb-skorpan', 'Oskarshamns Golfklubb - Skorpan', 174, '{"pars":[4,4,3,4,4,4,5,3,4,4,3,5,4,3,5,5,3,4]}'::jsonb),
  ('vasterviks-golfklubb-ekhagen', 'Västerviks Golfklubb - Ekhagen', 175, '{"pars":[4,4,4,3,5,4,3,4,5,4,3,5,4,3,4,4,4,5]}'::jsonb),
  ('almhults-golfklubb-askya', 'Älmhults Golfklubb - Äskya', 176, '{"pars":[4,3,4,3,5,4,4,4,4,4,3,5,4,5,4,3,4,4]}'::jsonb),
  ('lagans-golfklubb', 'Lagans Golfklubb', 177, '{"pars":[4,4,4,3,5,3,4,5,3,4,4,5,4,3,5,4,4,4]}'::jsonb),
  ('emmaboda-golfklubb', 'Emmaboda Golfklubb', 178, '{"pars":[4,3,4,4,4,4,5,3,5,4,3,4,5,4,4,3,5,4]}'::jsonb),
  ('glasrikets-golfklubb', 'Glasrikets Golfklubb', 179, '{"pars":[5,4,4,3,4,4,3,4,5,3,5,5,4,4,4,4,3,4]}'::jsonb),
  ('more-golfklubb', 'Möre Golfklubb', 180, '{"pars":[3,5,4,3,5,4,3,4,4,4,4,5,5,4,4,4,3,4]}'::jsonb),
  ('monsteras-golfklubb', 'Mönsterås Golfklubb', 181, '{"pars":[4,3,4,5,5,3,5,4,3,4,3,4,4,5,3,5,5,3]}'::jsonb),
  ('nybro-golfklubb', 'Nybro Golfklubb', 182, '{"pars":[4,5,4,5,4,3,4,4,4,5,4,3,4,4,3,5,3,4]}'::jsonb),
  ('sand-golf-club', 'Sand Golf Club', 183, '{"pars":[4,5,3,4,4,4,4,3,5,4,4,4,4,4,3,5,3,5]}'::jsonb),
  ('uppvidinge-golfklubb', 'Uppvidinge Golfklubb', 184, '{"pars":[4,3,4,4,4,4,4,3,3]}'::jsonb),
  ('stromstad-golfklubb', 'Strömstad Golfklubb', 185, '{"pars":[4,4,5,3,5,3,4,3,4,4,3,4,4,5,3,4,5,3]}'::jsonb),
  ('uddevalla-golfklubb', 'Uddevalla Golfklubb', 186, '{"pars":[4,5,3,4,4,4,4,4,5,3,5,3,5,3,4,5,3,4]}'::jsonb),
  ('orust-golfklubb', 'Orust Golfklubb', 187, '{"pars":[5,4,4,4,3,4,3,5,4,3,5,4,3,4,3,5,5,4]}'::jsonb),
  ('lyckorna-golfklubb', 'Lyckorna Golfklubb', 188, '{"pars":[4,5,4,3,4,4,4,5,3,4,5,3,4,4,4,5,3,4]}'::jsonb),
  ('skafto-golfklubb', 'Skaftö Golfklubb', 189, '{"pars":[3,4,4,3,4,3,5,5,4,4,5,3,4,3,3,4,4,4]}'::jsonb),
  ('sotenas-golfklubb', 'Sotenäs Golfklubb', 190, '{"pars":[4,3,5,5,3,5,4,3,4,4,5,3,4,3,4,4,5,4]}'::jsonb),
  ('onsjo-golfklubb', 'Onsjö Golfklubb', 191, '{"pars":[5,4,5,3,4,3,4,5,4,4,4,3,5,4,4,3,4,4]}'::jsonb),
  ('koberg-golfklubb', 'Koberg Golfklubb', 192, '{"pars":[4,4,3,4,4,4,4,3,5,4,3,4,4,5,4,3,4,5]}'::jsonb),
  ('forsbacka-golfklubb', 'Forsbacka Golfklubb', 193, '{"pars":[4,5,3,5,4,3,4,4,4,4,4,4,5,3,4,5,3,4]}'::jsonb),
  ('lerjedalens-golfklubb', 'Lerjedalens Golfklubb', 194, '{"pars":[4,4,3,5,4,3,4,3,5,4,3,5,4,4,5,5,3,4]}'::jsonb),
  ('hulta-golfklubb', 'Hulta Golfklubb', 195, '{"pars":[4,4,3,4,4,3,5,4,4,3,4,4,5,4,5,4,3,5]}'::jsonb),
  ('boras-golfklubb-norra-banan', 'Borås Golfklubb - Norra banan', 196, '{"pars":[5,4,4,4,3,4,3,4,5,3,4,5,4,4,4,4,3,5]}'::jsonb),
  ('boras-golfklubb-sodra-banan', 'Borås Golfklubb - Södra banan', 197, '{"pars":[4,3,4,5,4,5,4,3,3,4,4,3,4,5,3,3,4,4]}'::jsonb),
  ('ulricehamns-golfklubb', 'Ulricehamns Golfklubb', 198, '{"pars":[3,4,4,5,4,4,4,4,3,4,4,3,5,4,4,5,3,4]}'::jsonb),
  ('marks-golfklubb', 'Marks Golfklubb', 199, '{"pars":[4,4,3,5,4,3,4,4,5,3,4,5,3,4,4,3,4,4]}'::jsonb),
  ('ekarnas-golfklubb', 'Ekarnas Golfklubb', 200, '{"pars":[4,3,5,4,4,5,4,4,3,4,3,4,4,3,5,4,5,3]}'::jsonb),
  ('skovde-golfklubb-sodra-banan', 'Skövde Golfklubb - Södra banan', 201, '{"pars":[4,4,5,3,4,3,5,4,4,5,3,4,5,3,4,4,3,5]}'::jsonb),
  ('hokensas-golfklubb', 'Hökensås Golfklubb', 202, '{"pars":[5,4,3,4,5,4,4,3,4,3,5,5,3,4,3,4,5,4]}'::jsonb),
  ('billingens-golfklubb', 'Billingens Golfklubb', 203, '{"pars":[4,3,4,3,5,3,4,4,4,3,4,5,4,3,4,4,4,5]}'::jsonb),
  ('mariestads-golfklubb', 'Mariestads Golfklubb', 204, '{"pars":[4,5,4,3,4,3,4,4,5,4,4,4,5,3,4,3,5,5]}'::jsonb),
  ('toreboda-golfklubb-mansarudsbanan', 'Töreboda Golfklubb - Månsarudsbanan', 205, '{"pars":[4,3,4,4,5,4,5,3,4,3,4,4,3,4,3,4,4,5]}'::jsonb),
  ('falkopings-golfklubb', 'Falköpings Golfklubb', 206, '{"pars":[5,4,3,4,4,5,3,4,4,4,5,4,4,3,4,3,5,4]}'::jsonb),
  ('soderslatts-golfklubb', 'Söderslätts Golfklubb', 207, '{"pars":[4,3,4,5,4,4,5,3,4,4,3,4,4,5,4,4,3,5]}'::jsonb),
  ('perstorps-golfklubb', 'Perstorps Golfklubb', 208, '{"pars":[4,3,4,5,3,4,4,4,4,4,5,3,5,3,4,4,4,4]}'::jsonb),
  ('nar-golfklubb', 'När Golfklubb', 209, '{"pars":[5,4,4,4,3,4,4,4,3,4,3,4,3,4,5,4,3,5]}'::jsonb),
  ('vellinge-golfklubb', 'Vellinge Golfklubb', 210, '{"pars":[4,4,5,5,3,4,3,4,4,5,3,4,3,4,4,4,5,4]}'::jsonb),
  ('akagardens-golfklubb', 'Åkagårdens Golfklubb', 211, '{"pars":[4,3,4,4,5,3,4,4,4,5,5,4,4,4,3,4,3,4]}'::jsonb),
  ('ostra-goinge-golfklubb', 'Östra Göinge Golfklubb', 212, '{"pars":[3,4,4,4,5,5,3,4,3,4,3,5,4,4,3,4,5,4]}'::jsonb),
  ('varpinge-golfklubb', 'Värpinge Golfklubb', 213, '{"pars":[5,3,4,3,3,5,4,3,4,5,3,4,3,3,5,4,3,4]}'::jsonb),
  ('gotska-golfklubb', 'Gotska Golfklubb', 214, '{"pars":[5,3,4,4,3,4,5,4,3,4,4,5,3,4,4,3,4,3]}'::jsonb)
on conflict (id) do update set
  name       = excluded.name,
  sort_order = excluded.sort_order,
  layout     = excluded.layout;

-- Club coordinates.
update public.catalog_courses set lat = 56.9049, lng = 14.7711 where id = 'vaxjo-golfklubb';
update public.catalog_courses set lat = 56.7168, lng = 16.3477 where id = 'kalmar-golfklubb-gamla-banan';
update public.catalog_courses set lat = 56.7168, lng = 16.3477 where id = 'kalmar-golfklubb-nya-banan';
update public.catalog_courses set lat = 57.7511, lng = 14.1424 where id = 'jonkopings-golfklubb';
update public.catalog_courses set lat = 57.4415, lng = 13.6599 where id = 'isaberg-golfklubb-vastra';
update public.catalog_courses set lat = 57.4415, lng = 13.6599 where id = 'isaberg-golfklubb-ostra';
update public.catalog_courses set lat = 57.2256, lng = 14.1467 where id = 'varnamo-golfklubb';
update public.catalog_courses set lat = 57.6441, lng = 14.9002 where id = 'eksjo-golfklubb-skedhult';
update public.catalog_courses set lat = 58.0511, lng = 15.0033 where id = 'tranas-golfklubb-norraby';
update public.catalog_courses set lat = 57.5385, lng = 14.2727 where id = 'hooks-golfklubb-parkbanan';
update public.catalog_courses set lat = 57.5385, lng = 14.2727 where id = 'hooks-golfklubb-skogsbanan';
update public.catalog_courses set lat = 57.6766, lng = 14.6708 where id = 'nassjo-golfklubb';
update public.catalog_courses set lat = 57.7125, lng = 14.0505 where id = 'skinnarebo-golf-country-club';
update public.catalog_courses set lat = 56.1566, lng = 15.4523 where id = 'carlskrona-golfklubb';
update public.catalog_courses set lat = 56.1896, lng = 15.2935 where id = 'ronneby-golfklubb';
update public.catalog_courses set lat = 56.1645, lng = 15.7349 where id = 'trummenas-golfklubb';
update public.catalog_courses set lat = 56.0438, lng = 14.608 where id = 'solvesborgs-golfklubb';
update public.catalog_courses set lat = 56.785, lng = 16.5779 where id = 'ekerum-golfklubb-lange-erik';
update public.catalog_courses set lat = 56.785, lng = 16.5779 where id = 'ekerum-golfklubb-lange-jan';
update public.catalog_courses set lat = 57.1948, lng = 16.394 where id = 'oskarshamns-golfklubb-skorpan';
update public.catalog_courses set lat = 57.7718, lng = 16.6527 where id = 'vasterviks-golfklubb-ekhagen';
update public.catalog_courses set lat = 56.5631, lng = 14.1715 where id = 'almhults-golfklubb-askya';
update public.catalog_courses set lat = 56.9224, lng = 13.98 where id = 'lagans-golfklubb';
update public.catalog_courses set lat = 56.5325, lng = 15.5934 where id = 'emmaboda-golfklubb';
update public.catalog_courses set lat = 56.9026, lng = 14.8645 where id = 'glasrikets-golfklubb';
update public.catalog_courses set lat = 56.4479, lng = 16.0874 where id = 'more-golfklubb';
update public.catalog_courses set lat = 57.0399, lng = 16.4236 where id = 'monsteras-golfklubb';
update public.catalog_courses set lat = 56.6963, lng = 15.9899 where id = 'nybro-golfklubb';
update public.catalog_courses set lat = 57.8456, lng = 14.0355 where id = 'sand-golf-club';
update public.catalog_courses set lat = 57.1454, lng = 15.1609 where id = 'uppvidinge-golfklubb';
update public.catalog_courses set lat = 58.9489, lng = 11.1568 where id = 'stromstad-golfklubb';
update public.catalog_courses set lat = 58.3682, lng = 11.7695 where id = 'uddevalla-golfklubb';
update public.catalog_courses set lat = 58.195, lng = 11.5033 where id = 'orust-golfklubb';
update public.catalog_courses set lat = 58.1996, lng = 11.9016 where id = 'lyckorna-golfklubb';
update public.catalog_courses set lat = 58.2321, lng = 11.4453 where id = 'skafto-golfklubb';
update public.catalog_courses set lat = 58.4336, lng = 11.3785 where id = 'sotenas-golfklubb';
update public.catalog_courses set lat = 58.335, lng = 12.3305 where id = 'onsjo-golfklubb';
update public.catalog_courses set lat = 58.1657, lng = 12.3948 where id = 'koberg-golfklubb';
update public.catalog_courses set lat = 59.0877, lng = 12.6183 where id = 'forsbacka-golfklubb';
update public.catalog_courses set lat = 57.7942, lng = 12.1033 where id = 'lerjedalens-golfklubb';
update public.catalog_courses set lat = 57.6985, lng = 12.5828 where id = 'hulta-golfklubb';
update public.catalog_courses set lat = 57.6695, lng = 12.9388 where id = 'boras-golfklubb-norra-banan';
update public.catalog_courses set lat = 57.6695, lng = 12.9388 where id = 'boras-golfklubb-sodra-banan';
update public.catalog_courses set lat = 57.7874, lng = 13.4415 where id = 'ulricehamns-golfklubb';
update public.catalog_courses set lat = 57.502, lng = 12.7166 where id = 'marks-golfklubb';
update public.catalog_courses set lat = 58.3359, lng = 12.6663 where id = 'ekarnas-golfklubb';
update public.catalog_courses set lat = 58.3568, lng = 13.8087 where id = 'skovde-golfklubb-sodra-banan';
update public.catalog_courses set lat = 58.2499, lng = 14.2109 where id = 'hokensas-golfklubb';
update public.catalog_courses set lat = 58.4685, lng = 13.6859 where id = 'billingens-golfklubb';
update public.catalog_courses set lat = 58.6988, lng = 13.7614 where id = 'mariestads-golfklubb';
update public.catalog_courses set lat = 58.704, lng = 14.2367 where id = 'toreboda-golfklubb-mansarudsbanan';
update public.catalog_courses set lat = 58.214, lng = 13.6291 where id = 'falkopings-golfklubb';
update public.catalog_courses set lat = 55.4675, lng = 13.0809 where id = 'soderslatts-golfklubb';
update public.catalog_courses set lat = 56.1187, lng = 13.4163 where id = 'perstorps-golfklubb';
update public.catalog_courses set lat = 57.2445, lng = 18.6475 where id = 'nar-golfklubb';
update public.catalog_courses set lat = 55.493, lng = 13.103 where id = 'vellinge-golfklubb';
update public.catalog_courses set lat = 56.3653, lng = 12.7936 where id = 'akagardens-golfklubb';
update public.catalog_courses set lat = 56.2031, lng = 14.0788 where id = 'ostra-goinge-golfklubb';
update public.catalog_courses set lat = 55.707, lng = 13.1492 where id = 'varpinge-golfklubb';
update public.catalog_courses set lat = 57.6585, lng = 18.3286 where id = 'gotska-golfklubb';
