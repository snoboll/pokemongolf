-- Shiny variant flag for caught Bogeybeasts (1 in 256 roll on catch).
alter table caught_bogeybeast
  add column if not exists is_shiny boolean not null default false;
