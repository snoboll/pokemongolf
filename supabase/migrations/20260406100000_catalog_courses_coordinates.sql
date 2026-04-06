-- Add lat/lng coordinates to catalog_courses

alter table public.catalog_courses
  add column if not exists lat double precision,
  add column if not exists lng double precision;

update public.catalog_courses set lat = 55.4077812,  lng = 13.6050570 where id = 'abbekas';
update public.catalog_courses set lat = 56.1324373,  lng = 12.7146547 where id = 'allerum';
update public.catalog_courses set lat = 56.2665786,  lng = 13.0111575 where id = 'angelholm';
update public.catalog_courses set lat = 56.0649910,  lng = 14.0859040 where id = 'araslov-sodra';
update public.catalog_courses set lat = 55.7923908,  lng = 12.9419877 where id = 'barseback-masters';
update public.catalog_courses set lat = 55.7923908,  lng = 12.9419877 where id = 'barseback-ocean';
update public.catalog_courses set lat = 56.4299527,  lng = 12.7894733 where id = 'bastad';
update public.catalog_courses set lat = 55.3655473,  lng = 13.4302779 where id = 'bedinge';
update public.catalog_courses set lat = 56.4055879,  lng = 12.7734916 where id = 'bjare';
update public.catalog_courses set lat = 55.5511657,  lng = 13.2280286 where id = 'bokskogen';
update public.catalog_courses set lat = 55.8787690,  lng = 13.5217667 where id = 'bosjokloster';
update public.catalog_courses set lat = 55.8209077,  lng = 14.1299844 where id = 'degeberga';
update public.catalog_courses set lat = 55.6120709,  lng = 14.2799753 where id = 'djupadal';
update public.catalog_courses set lat = 55.8286029,  lng = 13.5511115 where id = 'elisefarm';
update public.catalog_courses set lat = 55.8118378,  lng = 13.3158702 where id = 'eslov';
update public.catalog_courses set lat = 55.3823851,  lng = 12.8207884 where id = 'falsterbo';
update public.catalog_courses set lat = 55.3932313,  lng = 12.8277774 where id = 'flommen';
update public.catalog_courses set lat = 56.1496800,  lng = 13.7511463 where id = 'hasslegarden';
update public.catalog_courses set lat = 56.1598742,  lng = 12.5669830 where id = 'helsingborg';
update public.catalog_courses set lat = 55.5312630,  lng = 13.1018449 where id = 'hinton';
update public.catalog_courses set lat = 56.1844436,  lng = 12.5682269 where id = 'hoganas';
update public.catalog_courses set lat = 55.7933140,  lng = 13.1526590 where id = 'kavlinge';
update public.catalog_courses set lat = 55.9237075,  lng = 14.2737487 where id = 'kristianstad';
update public.catalog_courses set lat = 55.9034880,  lng = 12.8093310 where id = 'landskrona';
update public.catalog_courses set lat = 55.6217498,  lng = 14.2735137 where id = 'lilla-vik';
update public.catalog_courses set lat = 55.3905380,  lng = 12.9073050 where id = 'ljunghusen';
update public.catalog_courses set lat = 55.7127093,  lng = 13.2758076 where id = 'lund-akademiska';
update public.catalog_courses set lat = 55.6170833,  lng = 13.0664521 where id = 'malmo-burlov';
update public.catalog_courses set lat = 56.2990978,  lng = 12.4686759 where id = 'molle';
update public.catalog_courses set lat = 55.6944941,  lng = 13.0652436 where id = 'orestad';
update public.catalog_courses set lat = 55.5663781,  lng = 13.1836053 where id = 'pga-national-lakes';
update public.catalog_courses set lat = 55.5663781,  lng = 13.1836053 where id = 'pga-national-links';
update public.catalog_courses set lat = 55.5948961,  lng = 13.5202412 where id = 'romelajsen';
update public.catalog_courses set lat = 55.9759626,  lng = 12.7567058 where id = 'rya';
update public.catalog_courses set lat = 55.6455770,  lng = 13.6500410 where id = 'sjobo';
update public.catalog_courses set lat = 56.0491110,  lng = 12.9533010 where id = 'soderasen';
update public.catalog_courses set lat = 55.5417807,  lng = 13.3460260 where id = 'sturup-park';
update public.catalog_courses set lat = 55.4601569,  lng = 13.2330794 where id = 'tegelberga';
update public.catalog_courses set lat = 55.5308495,  lng = 13.9762890 where id = 'tomelilla';
update public.catalog_courses set lat = 56.4390449,  lng = 12.6504859 where id = 'torekov';
update public.catalog_courses set lat = 55.3697222,  lng = 13.0813889 where id = 'trelleborg';
update public.catalog_courses set lat = 56.0577150,  lng = 12.7886340 where id = 'vasatorp';
update public.catalog_courses set lat = 55.4360229,  lng = 13.9239151 where id = 'ystad';
