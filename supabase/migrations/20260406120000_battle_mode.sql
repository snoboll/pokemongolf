-- Battle mode: battles table + RPCs.
-- No live channels needed; clients poll the battles row.

-- ── Type effectiveness helper (single attacker type vs single defender type) ─

create or replace function _battle_single_type_mult(atk text, def text)
returns numeric language sql immutable as $$
  select case
    when atk = 'Normal'   and def in ('Rock', 'Ghost')                        then 0.5
    when atk = 'Fire'     and def in ('Grass', 'Ice', 'Bug')                  then 2.0
    when atk = 'Fire'     and def in ('Fire', 'Water', 'Rock', 'Dragon')      then 0.5
    when atk = 'Water'    and def in ('Fire', 'Ground', 'Rock')               then 2.0
    when atk = 'Water'    and def in ('Water', 'Grass', 'Dragon')             then 0.5
    when atk = 'Grass'    and def in ('Water', 'Ground', 'Rock')              then 2.0
    when atk = 'Grass'    and def in ('Fire', 'Grass', 'Poison', 'Flying', 'Bug', 'Dragon') then 0.5
    when atk = 'Electric' and def in ('Water', 'Flying')                      then 2.0
    when atk = 'Electric' and def in ('Electric', 'Grass', 'Dragon', 'Ground') then 0.5
    when atk = 'Ice'      and def in ('Grass', 'Ground', 'Flying', 'Dragon')  then 2.0
    when atk = 'Ice'      and def in ('Water', 'Ice')                         then 0.5
    when atk = 'Fighting' and def in ('Normal', 'Ice', 'Rock')                then 2.0
    when atk = 'Fighting' and def in ('Poison', 'Bug', 'Psychic', 'Flying', 'Ghost') then 0.5
    when atk = 'Poison'   and def in ('Grass', 'Bug')                         then 2.0
    when atk = 'Poison'   and def in ('Poison', 'Ground', 'Rock', 'Ghost')    then 0.5
    when atk = 'Ground'   and def in ('Fire', 'Electric', 'Poison', 'Rock')   then 2.0
    when atk = 'Ground'   and def in ('Grass', 'Bug', 'Flying')               then 0.5
    when atk = 'Flying'   and def in ('Grass', 'Fighting', 'Bug')             then 2.0
    when atk = 'Flying'   and def in ('Electric', 'Rock')                     then 0.5
    when atk = 'Psychic'  and def in ('Fighting', 'Poison')                   then 2.0
    when atk = 'Psychic'  and def in ('Psychic', 'Ghost')                     then 0.5
    when atk = 'Bug'      and def in ('Grass', 'Poison', 'Psychic')           then 2.0
    when atk = 'Bug'      and def in ('Fire', 'Fighting', 'Flying', 'Ghost')  then 0.5
    when atk = 'Rock'     and def in ('Fire', 'Ice', 'Flying', 'Bug')         then 2.0
    when atk = 'Rock'     and def in ('Fighting', 'Ground')                   then 0.5
    when atk = 'Ghost'    and def in ('Ghost', 'Psychic')                     then 2.0
    when atk = 'Ghost'    and def in ('Normal')                               then 0.5
    when atk = 'Dragon'   and def in ('Dragon')                               then 2.0
    else 1.0
  end
$$;

-- ── Combined type mult (dual attacker: best type; dual defender: multiply) ───

create or replace function battle_type_mult(atk_types text[], def_types text[])
returns numeric language plpgsql immutable as $$
declare
  v_best numeric := 0;
  v_atk  text;
  v_def  text;
  v_mult numeric;
begin
  foreach v_atk in array atk_types loop
    v_mult := 1.0;
    foreach v_def in array def_types loop
      v_mult := v_mult * _battle_single_type_mult(v_atk, v_def);
    end loop;
    if v_mult > v_best then v_best := v_mult; end if;
  end loop;
  return v_best;
end;
$$;

-- ── battles table ─────────────────────────────────────────────────────────────

create table if not exists public.battles (
  id                 uuid primary key default gen_random_uuid(),
  course_id          text not null,
  course_name        text not null default '',
  hole_count         int  not null,
  course_pars        int[] not null default '{}',
  status             text not null default 'pending', -- pending | active | completed

  challenger_id      uuid not null references auth.users(id),
  challenger_name    text not null default '',
  opponent_id        uuid references auth.users(id),
  opponent_name      text,

  -- Teams: [{dex_number, name, types[], hp_max, hp_current, offense_tier, defense_tier}]
  challenger_team    jsonb,
  opponent_team      jsonb,

  -- Per-hole submitted strokes: {"1": 4, "2": 5, ...}
  challenger_scores  jsonb not null default '{}',
  opponent_scores    jsonb not null default '{}',

  -- Combat log: [{hole, c_strokes, o_strokes, result, damage, type_mult,
  --               attacker_pokemon, defender_pokemon, c_team_after, o_team_after}]
  hole_log           jsonb not null default '[]',

  winner_id          uuid references auth.users(id),
  created_at         timestamptz not null default now(),
  completed_at       timestamptz
);

alter table public.battles enable row level security;

-- Pending battles are visible to all authenticated users (so opponents can find invites).
-- Active/completed battles are visible only to participants.
drop policy if exists "battles_select" on public.battles;
create policy "battles_select"
  on public.battles for select
  to authenticated
  using (
    status = 'pending'
    or challenger_id = auth.uid()
    or opponent_id   = auth.uid()
  );

-- Challengers can create battles (INSERT); they become challenger via auth.uid().
drop policy if exists "battles_insert" on public.battles;
create policy "battles_insert"
  on public.battles for insert
  to authenticated
  with check (challenger_id = auth.uid());

-- ── join_battle RPC ───────────────────────────────────────────────────────────

create or replace function join_battle(
  p_battle_id uuid,
  p_team       jsonb
)
returns jsonb
language plpgsql
security definer
as $$
declare
  v_battle record;
begin
  select * into v_battle from battles where id = p_battle_id for update;

  if not found then
    raise exception 'Battle not found';
  end if;
  if v_battle.status != 'pending' then
    raise exception 'Battle is not pending';
  end if;
  if v_battle.challenger_id = auth.uid() then
    raise exception 'Cannot join your own battle';
  end if;
  if v_battle.opponent_id is not null then
    raise exception 'Battle already has an opponent';
  end if;

  update battles set
    opponent_id   = auth.uid(),
    opponent_name = (select trainer_name from profiles where user_id = auth.uid()),
    opponent_team = p_team,
    status        = 'active'
  where id = p_battle_id;

  return (select row_to_json(b)::jsonb from battles b where id = p_battle_id);
end;
$$;

-- ── submit_battle_score RPC ───────────────────────────────────────────────────

create or replace function submit_battle_score(
  p_battle_id uuid,
  p_hole      int,
  p_strokes   int
)
returns jsonb
language plpgsql
security definer
as $$
declare
  v_battle          record;
  v_user_id         uuid;
  v_is_challenger   boolean;
  v_c_strokes       int;
  v_o_strokes       int;
  v_score_diff      int;
  v_c_team          jsonb;
  v_o_team          jsonb;
  v_attacker_team   jsonb;
  v_defender_team   jsonb;
  v_lead_atk        jsonb;
  v_lead_def        jsonb;
  v_raw_dmg         int;
  v_score_bonus     int;
  v_type_mult       numeric;
  v_final_dmg       int;
  v_new_hp          int;
  v_log_entry       jsonb;
  v_c_alive         int;
  v_o_alive         int;
  v_c_total_hp      int;
  v_o_total_hp      int;
  v_winner_id       uuid;
  i                 int;
begin
  v_user_id := auth.uid();

  select * into v_battle from battles where id = p_battle_id for update;

  if not found then
    raise exception 'Battle not found';
  end if;
  if v_battle.status != 'active' then
    raise exception 'Battle is not active (status: %)', v_battle.status;
  end if;

  if v_battle.challenger_id = v_user_id then
    v_is_challenger := true;
  elsif v_battle.opponent_id = v_user_id then
    v_is_challenger := false;
  else
    raise exception 'Not a participant in this battle';
  end if;

  if v_is_challenger and (v_battle.challenger_scores ->> p_hole::text) is not null then
    raise exception 'Challenger already submitted score for hole %', p_hole;
  end if;
  if not v_is_challenger and (v_battle.opponent_scores ->> p_hole::text) is not null then
    raise exception 'Opponent already submitted score for hole %', p_hole;
  end if;

  -- Write score
  if v_is_challenger then
    update battles
    set challenger_scores = challenger_scores || jsonb_build_object(p_hole::text, p_strokes)
    where id = p_battle_id;
  else
    update battles
    set opponent_scores = opponent_scores || jsonb_build_object(p_hole::text, p_strokes)
    where id = p_battle_id;
  end if;

  select * into v_battle from battles where id = p_battle_id;

  -- Check if both players have submitted for this hole
  v_c_strokes := (v_battle.challenger_scores ->> p_hole::text)::int;
  v_o_strokes := (v_battle.opponent_scores   ->> p_hole::text)::int;

  if v_c_strokes is null or v_o_strokes is null then
    return row_to_json(v_battle)::jsonb;
  end if;

  -- ── Both submitted: resolve combat ────────────────────────────────────────

  v_c_team     := v_battle.challenger_team;
  v_o_team     := v_battle.opponent_team;
  v_score_diff := abs(v_c_strokes - v_o_strokes);

  if v_c_strokes = v_o_strokes then
    -- Tie: no damage
    v_log_entry := jsonb_build_object(
      'hole',        p_hole,
      'c_strokes',   v_c_strokes,
      'o_strokes',   v_o_strokes,
      'result',      'tie',
      'damage',      0,
      'type_mult',   1.0,
      'c_team_after', v_c_team,
      'o_team_after', v_o_team
    );
  else
    -- Attacker = player with lower strokes
    if v_c_strokes < v_o_strokes then
      v_attacker_team := v_c_team;
      v_defender_team := v_o_team;
    else
      v_attacker_team := v_o_team;
      v_defender_team := v_c_team;
    end if;

    -- Find lead Pokemon (first with hp_current > 0)
    v_lead_atk := null;
    v_lead_def := null;
    for i in 0..jsonb_array_length(v_attacker_team) - 1 loop
      if v_lead_atk is null and (v_attacker_team -> i ->> 'hp_current')::int > 0 then
        v_lead_atk := v_attacker_team -> i;
      end if;
    end loop;
    for i in 0..jsonb_array_length(v_defender_team) - 1 loop
      if v_lead_def is null and (v_defender_team -> i ->> 'hp_current')::int > 0 then
        v_lead_def := v_defender_team -> i;
      end if;
    end loop;

    if v_lead_atk is null or v_lead_def is null then
      raise exception 'No alive Pokemon found (game should have ended)';
    end if;

    -- Damage calculation
    -- rawDmg = offenseTier - floor(defenseTier / 2), min 1
    -- scoreDiffBonus = scoreDiff * 4
    -- finalDmg = max(1, round((rawDmg + scoreBonus) * typeMult))
    v_raw_dmg     := greatest(1, (v_lead_atk ->> 'offense_tier')::int - ((v_lead_def ->> 'defense_tier')::int / 2));
    v_score_bonus := v_score_diff * 4;
    v_type_mult   := battle_type_mult(
      array(select jsonb_array_elements_text(v_lead_atk -> 'types')),
      array(select jsonb_array_elements_text(v_lead_def -> 'types'))
    );
    if v_type_mult = 0 then v_type_mult := 1.0; end if; -- Fairy or unknown: neutral
    v_final_dmg   := greatest(1, round((v_raw_dmg + v_score_bonus)::numeric * v_type_mult)::int);

    -- Apply damage: reduce hp_current of the first alive defender Pokemon
    if v_c_strokes < v_o_strokes then
      -- Challenger attacks opponent team
      for i in 0..jsonb_array_length(v_o_team) - 1 loop
        if (v_o_team -> i ->> 'hp_current')::int > 0 then
          v_new_hp := greatest(0, (v_o_team -> i ->> 'hp_current')::int - v_final_dmg);
          v_o_team := jsonb_set(v_o_team, array[i::text, 'hp_current'], to_jsonb(v_new_hp));
          exit;
        end if;
      end loop;
    else
      -- Opponent attacks challenger team
      for i in 0..jsonb_array_length(v_c_team) - 1 loop
        if (v_c_team -> i ->> 'hp_current')::int > 0 then
          v_new_hp := greatest(0, (v_c_team -> i ->> 'hp_current')::int - v_final_dmg);
          v_c_team := jsonb_set(v_c_team, array[i::text, 'hp_current'], to_jsonb(v_new_hp));
          exit;
        end if;
      end loop;
    end if;

    v_log_entry := jsonb_build_object(
      'hole',              p_hole,
      'c_strokes',         v_c_strokes,
      'o_strokes',         v_o_strokes,
      'result',            case when v_c_strokes < v_o_strokes then 'challenger_wins' else 'opponent_wins' end,
      'damage',            v_final_dmg,
      'type_mult',         v_type_mult,
      'attacker_pokemon',  v_lead_atk ->> 'name',
      'defender_pokemon',  v_lead_def ->> 'name',
      'c_team_after',      v_c_team,
      'o_team_after',      v_o_team
    );
  end if;

  -- ── Check win conditions ──────────────────────────────────────────────────

  v_c_alive    := 0; v_o_alive    := 0;
  v_c_total_hp := 0; v_o_total_hp := 0;

  for i in 0..jsonb_array_length(v_c_team) - 1 loop
    if (v_c_team -> i ->> 'hp_current')::int > 0 then
      v_c_alive    := v_c_alive + 1;
      v_c_total_hp := v_c_total_hp + (v_c_team -> i ->> 'hp_current')::int;
    end if;
  end loop;
  for i in 0..jsonb_array_length(v_o_team) - 1 loop
    if (v_o_team -> i ->> 'hp_current')::int > 0 then
      v_o_alive    := v_o_alive + 1;
      v_o_total_hp := v_o_total_hp + (v_o_team -> i ->> 'hp_current')::int;
    end if;
  end loop;

  v_winner_id := null;
  if v_c_alive = 0 and v_o_alive = 0 then
    v_winner_id := v_battle.challenger_id; -- Simultaneous KO: challenger wins
  elsif v_c_alive = 0 then
    v_winner_id := v_battle.opponent_id;
  elsif v_o_alive = 0 then
    v_winner_id := v_battle.challenger_id;
  elsif p_hole = v_battle.hole_count then
    -- All holes played
    if v_c_alive > v_o_alive then
      v_winner_id := v_battle.challenger_id;
    elsif v_o_alive > v_c_alive then
      v_winner_id := v_battle.opponent_id;
    elsif v_c_total_hp > v_o_total_hp then
      v_winner_id := v_battle.challenger_id;
    elsif v_o_total_hp > v_c_total_hp then
      v_winner_id := v_battle.opponent_id;
    else
      v_winner_id := v_battle.challenger_id; -- Perfect tie: challenger wins
    end if;
  end if;

  -- ── Persist ───────────────────────────────────────────────────────────────

  update battles set
    challenger_team = v_c_team,
    opponent_team   = v_o_team,
    hole_log        = hole_log || v_log_entry,
    winner_id       = v_winner_id,
    status          = case when v_winner_id is not null then 'completed' else 'active' end,
    completed_at    = case when v_winner_id is not null then now() else null end
  where id = p_battle_id;

  return (select row_to_json(b)::jsonb from battles b where id = p_battle_id);
end;
$$;
