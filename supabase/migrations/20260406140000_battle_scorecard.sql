-- 1. Add round_type and course_name to rounds so battle scorecards are identifiable.
alter table public.rounds
  add column if not exists round_type text not null default 'catch';

alter table public.rounds
  add column if not exists course_name text;

-- 2. Update submit_battle_score: no longer ends on mid-game KO.
--    Combat is simply skipped when either side has no alive Pokemon.
--    Winner is determined only when all holes have been played.
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
      'hole',         p_hole,
      'c_strokes',    v_c_strokes,
      'o_strokes',    v_o_strokes,
      'result',       'tie',
      'damage',       0,
      'type_mult',    1.0,
      'c_team_after', v_c_team,
      'o_team_after', v_o_team
    );
  else
    if v_c_strokes < v_o_strokes then
      v_attacker_team := v_c_team;
      v_defender_team := v_o_team;
    else
      v_attacker_team := v_o_team;
      v_defender_team := v_c_team;
    end if;

    -- Find lead alive Pokemon on each side
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

    -- Combat only if BOTH sides still have alive Pokemon.
    -- If either team is KO'd the game continues but no damage is dealt.
    if v_lead_atk is not null and v_lead_def is not null then
      v_raw_dmg     := greatest(1, (v_lead_atk ->> 'offense_tier')::int - ((v_lead_def ->> 'defense_tier')::int / 2));
      v_score_bonus := v_score_diff * 10;
      v_type_mult   := battle_type_mult(
        array(select jsonb_array_elements_text(v_lead_atk -> 'types')),
        array(select jsonb_array_elements_text(v_lead_def -> 'types'))
      );
      if v_type_mult = 0 then v_type_mult := 1.0; end if;
      v_final_dmg := greatest(1, round((v_raw_dmg + v_score_bonus)::numeric * v_type_mult)::int);

      if v_c_strokes < v_o_strokes then
        for i in 0..jsonb_array_length(v_o_team) - 1 loop
          if (v_o_team -> i ->> 'hp_current')::int > 0 then
            v_new_hp := greatest(0, (v_o_team -> i ->> 'hp_current')::int - v_final_dmg);
            v_o_team := jsonb_set(v_o_team, array[i::text, 'hp_current'], to_jsonb(v_new_hp));
            exit;
          end if;
        end loop;
      else
        for i in 0..jsonb_array_length(v_c_team) - 1 loop
          if (v_c_team -> i ->> 'hp_current')::int > 0 then
            v_new_hp := greatest(0, (v_c_team -> i ->> 'hp_current')::int - v_final_dmg);
            v_c_team := jsonb_set(v_c_team, array[i::text, 'hp_current'], to_jsonb(v_new_hp));
            exit;
          end if;
        end loop;
      end if;
    else
      -- One or both teams KO'd: hole winner recorded but no damage
      v_final_dmg := 0;
      v_type_mult := 1.0;
    end if;

    v_log_entry := jsonb_build_object(
      'hole',             p_hole,
      'c_strokes',        v_c_strokes,
      'o_strokes',        v_o_strokes,
      'result',           case when v_c_strokes < v_o_strokes then 'challenger_wins' else 'opponent_wins' end,
      'damage',           v_final_dmg,
      'type_mult',        v_type_mult,
      'attacker_pokemon', case when v_lead_atk is not null then v_lead_atk ->> 'name' else null end,
      'defender_pokemon', case when v_lead_def is not null then v_lead_def ->> 'name' else null end,
      'c_team_after',     v_c_team,
      'o_team_after',     v_o_team
    );
  end if;

  -- ── Count alive + HP ──────────────────────────────────────────────────────

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

  -- ── Winner only at the final hole ─────────────────────────────────────────

  v_winner_id := null;
  if p_hole = v_battle.hole_count then
    if v_c_alive > v_o_alive then
      v_winner_id := v_battle.challenger_id;
    elsif v_o_alive > v_c_alive then
      v_winner_id := v_battle.opponent_id;
    elsif v_c_total_hp > v_o_total_hp then
      v_winner_id := v_battle.challenger_id;
    elsif v_o_total_hp > v_c_total_hp then
      v_winner_id := v_battle.opponent_id;
    else
      v_winner_id := v_battle.challenger_id; -- perfect tie: challenger wins
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
