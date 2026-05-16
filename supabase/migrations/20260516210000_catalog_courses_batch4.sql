-- Batch 4: Swedish golf courses — Göteborg, Halland, central Sweden, Norrland.
-- Per-hole pars verified from public scorecards (golfisverige.com, caddee.se).

insert into public.catalog_courses (id, name, sort_order, layout) values
  ('hills-golf-sports-club-hills-course', 'Hills Golf & Sports Club - Hills Course', 95, '{"pars":[5,4,5,4,3,3,4,5,4,3,4,4,3,4,3,4,4,5]}'::jsonb),
  ('albatross-golfklubb-albatrossen', 'Albatross Golfklubb - Albatrossen', 96, '{"pars":[4,3,4,4,3,4,5,5,4,3,4,4,4,4,4,3,5,4]}'::jsonb),
  ('delsjo-golfklubb', 'Delsjö Golfklubb', 97, '{"pars":[5,4,3,3,4,4,4,5,4,5,4,3,4,4,4,3,5,3]}'::jsonb),
  ('gullbringa-golf-country-club', 'Gullbringa Golf & Country Club', 98, '{"pars":[4,5,4,3,4,4,5,3,4,4,3,4,3,4,3,4,4,5]}'::jsonb),
  ('lysegardens-golfklubb', 'Lysegårdens Golfklubb', 99, '{"pars":[3,4,4,3,5,4,4,4,5,4,3,5,4,4,3,5,3,4]}'::jsonb),
  ('forsgardens-golfklubb-slottsbanan', 'Forsgårdens Golfklubb - Slottsbanan', 100, '{"pars":[4,3,4,5,3,4,5,4,4,3,5,4,3,4,4,4,5,4]}'::jsonb),
  ('oijared-golfklubb-gamla-banan', 'Öijared Golfklubb - Gamla banan', 101, '{"pars":[5,4,3,4,4,5,4,3,4,4,5,3,4,4,4,5,3,4]}'::jsonb),
  ('oijared-golfklubb-nya-banan', 'Öijared Golfklubb - Nya banan', 102, '{"pars":[4,4,4,4,3,5,4,3,5,3,5,4,4,5,4,3,4,4]}'::jsonb),
  ('oijared-golfklubb-parkbanan', 'Öijared Golfklubb - Parkbanan', 103, '{"pars":[3,5,4,3,4,4,3,4,3,4,5,4,4,4,3,4,4,5]}'::jsonb),
  ('chalmers-golfklubb', 'Chalmers Golfklubb', 104, '{"pars":[4,3,4,5,4,5,3,4,3,4,3,5,4,3,3,4,5,4]}'::jsonb),
  ('partille-golfklubb', 'Partille Golfklubb', 105, '{"pars":[4,3,5,4,3,5,3,4,4,4,4,4,3,5,4,4,3,4]}'::jsonb),
  ('goteborgs-golf-klubb-hovas', 'Göteborgs Golf Klubb (Hovås)', 106, '{"pars":[3,4,5,3,4,4,3,4,4,5,5,4,3,4,4,4,3,4]}'::jsonb),
  ('sankt-jorgen-park-golf', 'Sankt Jörgen Park Golf', 107, '{"pars":[3,5,4,4,5,3,4,3,5,4,4,3,4,5,4,3,4,5]}'::jsonb),
  ('molndals-golfklubb', 'Mölndals Golfklubb', 108, '{"pars":[4,5,3,4,5,4,3,4,4,5,3,4,4,4,4,4,3,5]}'::jsonb),
  ('stora-lundby-golfklubb-stora-banan', 'Stora Lundby Golfklubb - Stora banan', 109, '{"pars":[5,4,5,3,4,3,5,3,4,3,4,4,3,4,5,4,4,5]}'::jsonb),
  ('halmstad-gk-norra-banan', 'Halmstad GK - Norra banan', 110, '{"pars":[4,5,4,3,5,4,3,4,4,4,5,4,3,5,4,3,4,4]}'::jsonb),
  ('halmstad-gk-sodra-banan', 'Halmstad GK - Södra banan', 111, '{"pars":[4,4,4,3,4,3,4,4,5,5,3,4,5,4,4,4,5,3]}'::jsonb),
  ('falkenbergs-gk-18-halsbanan', 'Falkenbergs GK - 18-hålsbanan', 112, '{"pars":[5,4,4,4,3,4,5,3,4,4,4,5,4,4,4,3,5,3]}'::jsonb),
  ('varbergs-gk-vastra-banan', 'Varbergs GK - Västra banan', 113, '{"pars":[4,5,4,4,4,5,4,3,4,3,4,4,4,3,5,3,4,5]}'::jsonb),
  ('varbergs-gk-ostra-banan', 'Varbergs GK - Östra banan', 114, '{"pars":[5,4,3,5,4,4,3,4,4,4,4,3,5,3,4,3,5,4]}'::jsonb),
  ('ringenas-gk-18-halsbanan', 'Ringenäs GK - 18-hålsbanan', 115, '{"pars":[5,4,4,3,4,4,3,4,5,4,5,4,4,3,4,5,4,3]}'::jsonb),
  ('laholms-gk-vallen', 'Laholms GK - Vallen', 116, '{"pars":[5,3,4,3,4,4,3,4,5,3,4,4,5,4,3,4,3,5]}'::jsonb),
  ('vinbergs-gk-tollstorpslingan', 'Vinbergs GK - Töllstorpslingan', 117, '{"pars":[4,4,4,4,4,5,3,4,4,4,4,4,3,4,4,3,5,5]}'::jsonb),
  ('kungsbacka-gk-gamla-banan', 'Kungsbacka GK - Gamla Banan', 118, '{"pars":[3,4,5,4,4,5,3,4,4,4,4,5,3,4,4,5,4,3]}'::jsonb),
  ('holms-gk', 'Holms GK', 119, '{"pars":[5,3,4,4,5,4,3,4,4,4,4,5,3,4,3,5,4,4]}'::jsonb),
  ('grappas-gk-18-halsbanan', 'Gräppås GK - 18-hålsbanan', 120, '{"pars":[3,5,4,3,4,4,4,3,5,3,4,4,5,4,5,3,4,3]}'::jsonb),
  ('falun-borlange-gk', 'Falun-Borlänge GK', 121, '{"pars":[4,5,3,4,4,5,4,3,4,5,4,4,4,3,4,3,4,5]}'::jsonb),
  ('hagge-gk', 'Hagge GK', 122, '{"pars":[4,4,3,5,3,4,3,4,5,5,4,3,4,4,4,4,3,5]}'::jsonb),
  ('mora-gk', 'Mora GK', 123, '{"pars":[4,3,5,4,5,4,3,4,4,4,5,3,4,3,4,5,4,4]}'::jsonb),
  ('leksands-gk', 'Leksands GK', 124, '{"pars":[4,5,3,4,3,5,4,3,4,4,3,4,5,4,4,3,4,4]}'::jsonb),
  ('karlstad-gk-18-hal', 'Karlstad GK - 18 hål', 125, '{"pars":[5,3,4,4,3,5,4,4,4,5,3,4,5,4,4,3,4,4]}'::jsonb),
  ('arvika-gk-kingselviken', 'Arvika GK - Kingselviken', 126, '{"pars":[5,4,3,4,3,4,4,4,5,4,4,3,4,3,5,3,5,4]}'::jsonb),
  ('kristinehamns-gk', 'Kristinehamns GK', 127, '{"pars":[4,3,4,5,3,4,5,4,4,4,4,3,4,5,4,3,4,5]}'::jsonb),
  ('lindesbergs-gk', 'Lindesbergs GK', 128, '{"pars":[3,4,4,4,5,3,4,4,5,5,3,5,3,5,4,3,4,4]}'::jsonb),
  ('askersunds-gk', 'Askersunds GK', 129, '{"pars":[4,4,5,3,4,3,4,4,5,4,4,3,5,4,5,3,4,4]}'::jsonb),
  ('linkopings-gk', 'Linköpings GK', 130, '{"pars":[5,3,4,4,5,4,3,4,4,4,4,3,5,3,5,3,4,4]}'::jsonb),
  ('vreta-kloster-gk', 'Vreta Kloster GK', 131, '{"pars":[5,4,3,4,5,4,3,4,4,4,4,5,3,4,5,3,4,4]}'::jsonb),
  ('norrkoping-soderkoping-gk-klinga', 'Norrköping Söderköping GK - Klinga', 132, '{"pars":[5,4,4,3,4,4,4,4,5,4,4,3,4,5,4,5,3,3]}'::jsonb),
  ('norrkoping-soderkoping-gk-hylinge', 'Norrköping Söderköping GK - Hylinge', 133, '{"pars":[5,4,3,5,4,4,3,4,4,4,3,4,4,4,5,4,3,5]}'::jsonb),
  ('mjolby-gk', 'Mjölby GK', 134, '{"pars":[4,4,4,3,5,4,5,4,3,5,3,4,4,3,4,4,5,3]}'::jsonb),
  ('vadstena-gk', 'Vadstena GK', 135, '{"pars":[5,4,4,5,3,4,3,4,3,5,3,4,4,4,5,4,3,4]}'::jsonb),
  ('upsala-gk-stora-banan', 'Upsala GK - Stora banan', 136, '{"pars":[4,3,4,4,5,3,4,5,4,3,4,5,4,3,4,5,4,4]}'::jsonb),
  ('sigtuna-gk', 'Sigtuna GK', 137, '{"pars":[4,5,4,3,4,5,3,4,4,4,4,3,4,3,4,4,5,5]}'::jsonb),
  ('enkopings-gk', 'Enköpings GK', 138, '{"pars":[4,4,5,3,5,4,3,4,4,5,3,3,4,5,3,4,4,4]}'::jsonb),
  ('vasteras-gk', 'Västerås GK', 139, '{"pars":[4,4,4,5,4,3,4,3,4,5,3,4,4,4,4,4,3,4]}'::jsonb),
  ('gavle-gk-avan', 'Gävle GK - Avan', 140, '{"pars":[5,4,4,4,4,3,5,4,3,5,4,4,3,4,3,4,4,5]}'::jsonb),
  ('gavle-gk-gamla-banan', 'Gävle GK - Gamla Banan', 141, '{"pars":[4,4,4,5,4,3,5,3,4,5,3,4,3,4,5,4,3,5]}'::jsonb),
  ('soderhamns-gk', 'Söderhamns GK', 142, '{"pars":[4,5,4,3,5,3,4,4,4,5,3,4,5,3,4,5,3,4]}'::jsonb),
  ('hudiksvalls-gk', 'Hudiksvalls GK', 143, '{"pars":[4,4,4,4,5,4,3,4,3,4,4,5,3,4,5,4,3,4]}'::jsonb),
  ('sundsvalls-gk', 'Sundsvalls GK', 144, '{"pars":[4,3,4,3,5,5,4,4,3,4,3,4,4,3,4,4,5,4]}'::jsonb),
  ('timra-gk', 'Timrå GK', 145, '{"pars":[5,4,3,4,4,3,4,5,4,4,4,5,4,3,4,5,3,4]}'::jsonb),
  ('harnosands-gk', 'Härnösands GK', 146, '{"pars":[4,3,5,4,4,3,5,4,4,4,5,5,4,3,4,4,3,4]}'::jsonb),
  ('solleftea-gk', 'Sollefteå GK', 147, '{"pars":[4,5,3,4,4,3,5,3,4,5,3,4,4,5,3,5,4,4]}'::jsonb),
  ('ornskoldsviks-gk-puttom', 'Örnsköldsviks GK Puttom', 148, '{"pars":[4,4,3,5,3,4,4,4,5,4,4,3,5,5,3,4,4,4]}'::jsonb),
  ('umea-gk', 'Umeå GK', 149, '{"pars":[4,3,5,4,4,3,5,4,5,3,4,4,4,5,3,5,4,3]}'::jsonb),
  ('umea-sorfors-gk', 'Umeå Sörfors GK', 150, '{"pars":[4,4,3,5,3,4,5,3,4,5,3,4,3,4,5,4,4,4]}'::jsonb),
  ('skelleftea-gk', 'Skellefteå GK', 151, '{"pars":[4,5,4,3,5,4,3,4,4,5,4,4,3,4,3,5,4,4]}'::jsonb),
  ('pitea-gk-sparbanken-nordslingan', 'Piteå GK - Sparbanken/Nordslingan', 152, '{"pars":[4,4,3,4,4,3,5,3,4,4,3,5,4,5,4,5,4,4]}'::jsonb),
  ('bodens-gk-savastbanan', 'Bodens GK - Sävastbanan', 153, '{"pars":[4,5,4,3,4,4,4,3,4,4,3,4,5,4,3,4,4,5]}'::jsonb),
  ('ostersund-froso-gk', 'Östersund-Frösö GK', 154, '{"pars":[5,4,5,3,4,4,3,5,4,4,4,5,4,3,5,4,3,4]}'::jsonb)
on conflict (id) do update set
  name       = excluded.name,
  sort_order = excluded.sort_order,
  layout     = excluded.layout;

-- Club coordinates.
update public.catalog_courses set lat = 57.629, lng = 12.0134 where id = 'hills-golf-sports-club-hills-course';
update public.catalog_courses set lat = 57.7778, lng = 11.9556 where id = 'albatross-golfklubb-albatrossen';
update public.catalog_courses set lat = 57.6884, lng = 12.0206 where id = 'delsjo-golfklubb';
update public.catalog_courses set lat = 57.8825, lng = 11.7709 where id = 'gullbringa-golf-country-club';
update public.catalog_courses set lat = 57.9423, lng = 12.0335 where id = 'lysegardens-golfklubb';
update public.catalog_courses set lat = 57.4947, lng = 12.099 where id = 'forsgardens-golfklubb-slottsbanan';
update public.catalog_courses set lat = 57.8567, lng = 12.3966 where id = 'oijared-golfklubb-gamla-banan';
update public.catalog_courses set lat = 57.8567, lng = 12.3966 where id = 'oijared-golfklubb-nya-banan';
update public.catalog_courses set lat = 57.8567, lng = 12.3966 where id = 'oijared-golfklubb-parkbanan';
update public.catalog_courses set lat = 57.6906, lng = 12.2701 where id = 'chalmers-golfklubb';
update public.catalog_courses set lat = 57.6907, lng = 12.1106 where id = 'partille-golfklubb';
update public.catalog_courses set lat = 57.6146, lng = 11.9329 where id = 'goteborgs-golf-klubb-hovas';
update public.catalog_courses set lat = 57.7443, lng = 11.944 where id = 'sankt-jorgen-park-golf';
update public.catalog_courses set lat = 57.585, lng = 12.1174 where id = 'molndals-golfklubb';
update public.catalog_courses set lat = 57.8351, lng = 12.2582 where id = 'stora-lundby-golfklubb-stora-banan';
update public.catalog_courses set lat = 56.6471, lng = 12.7354 where id = 'halmstad-gk-norra-banan';
update public.catalog_courses set lat = 56.6471, lng = 12.7354 where id = 'halmstad-gk-sodra-banan';
update public.catalog_courses set lat = 56.8898, lng = 12.5699 where id = 'falkenbergs-gk-18-halsbanan';
update public.catalog_courses set lat = 57.0645, lng = 12.3529 where id = 'varbergs-gk-vastra-banan';
update public.catalog_courses set lat = 57.0645, lng = 12.3529 where id = 'varbergs-gk-ostra-banan';
update public.catalog_courses set lat = 56.6871, lng = 12.7165 where id = 'ringenas-gk-18-halsbanan';
update public.catalog_courses set lat = 56.4361, lng = 13.1183 where id = 'laholms-gk-vallen';
update public.catalog_courses set lat = 56.9612, lng = 12.5545 where id = 'vinbergs-gk-tollstorpslingan';
update public.catalog_courses set lat = 57.4935, lng = 11.9859 where id = 'kungsbacka-gk-gamla-banan';
update public.catalog_courses set lat = 56.756, lng = 12.8756 where id = 'holms-gk';
update public.catalog_courses set lat = 57.4348, lng = 11.9765 where id = 'grappas-gk-18-halsbanan';
update public.catalog_courses set lat = 60.5482, lng = 15.5135 where id = 'falun-borlange-gk';
update public.catalog_courses set lat = 60.116, lng = 15.2494 where id = 'hagge-gk';
update public.catalog_courses set lat = 61.0174, lng = 14.5636 where id = 'mora-gk';
update public.catalog_courses set lat = 60.7488, lng = 15.034 where id = 'leksands-gk';
update public.catalog_courses set lat = 59.4336, lng = 13.5211 where id = 'karlstad-gk-18-hal';
update public.catalog_courses set lat = 59.6493, lng = 12.7814 where id = 'arvika-gk-kingselviken';
update public.catalog_courses set lat = 59.3371, lng = 14.1409 where id = 'kristinehamns-gk';
update public.catalog_courses set lat = 59.5849, lng = 15.2437 where id = 'lindesbergs-gk';
update public.catalog_courses set lat = 58.8557, lng = 15.0003 where id = 'askersunds-gk';
update public.catalog_courses set lat = 58.3979, lng = 15.5712 where id = 'linkopings-gk';
update public.catalog_courses set lat = 58.528, lng = 15.5194 where id = 'vreta-kloster-gk';
update public.catalog_courses set lat = 58.496, lng = 16.1706 where id = 'norrkoping-soderkoping-gk-klinga';
update public.catalog_courses set lat = 58.496, lng = 16.1706 where id = 'norrkoping-soderkoping-gk-hylinge';
update public.catalog_courses set lat = 58.3067, lng = 15.1014 where id = 'mjolby-gk';
update public.catalog_courses set lat = 58.4202, lng = 14.8979 where id = 'vadstena-gk';
update public.catalog_courses set lat = 59.8417, lng = 17.5046 where id = 'upsala-gk-stora-banan';
update public.catalog_courses set lat = 59.6406, lng = 17.7258 where id = 'sigtuna-gk';
update public.catalog_courses set lat = 59.6351, lng = 17.1316 where id = 'enkopings-gk';
update public.catalog_courses set lat = 59.629, lng = 16.5036 where id = 'vasteras-gk';
update public.catalog_courses set lat = 60.7002, lng = 17.178 where id = 'gavle-gk-avan';
update public.catalog_courses set lat = 60.7002, lng = 17.178 where id = 'gavle-gk-gamla-banan';
update public.catalog_courses set lat = 61.293, lng = 17.162 where id = 'soderhamns-gk';
update public.catalog_courses set lat = 61.7053, lng = 17.1291 where id = 'hudiksvalls-gk';
update public.catalog_courses set lat = 62.2847, lng = 17.3884 where id = 'sundsvalls-gk';
update public.catalog_courses set lat = 62.5076, lng = 17.4161 where id = 'timra-gk';
update public.catalog_courses set lat = 62.6711, lng = 17.9479 where id = 'harnosands-gk';
update public.catalog_courses set lat = 63.1636, lng = 17.0115 where id = 'solleftea-gk';
update public.catalog_courses set lat = 63.301, lng = 18.9389 where id = 'ornskoldsviks-gk-puttom';
update public.catalog_courses set lat = 63.7157, lng = 20.3997 where id = 'umea-gk';
update public.catalog_courses set lat = 63.855, lng = 20.0213 where id = 'umea-sorfors-gk';
update public.catalog_courses set lat = 64.7069, lng = 20.9726 where id = 'skelleftea-gk';
update public.catalog_courses set lat = 65.3175, lng = 21.528 where id = 'pitea-gk-sparbanken-nordslingan';
update public.catalog_courses set lat = 65.7507, lng = 21.758 where id = 'bodens-gk-savastbanan';
update public.catalog_courses set lat = 63.1837, lng = 14.4965 where id = 'ostersund-froso-gk';
