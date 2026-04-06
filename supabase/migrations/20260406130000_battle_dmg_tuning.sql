-- Damage tuning for 15 hcp target audience.
--
-- Math:
--   15 hcp score distribution: birdie 5%, par 25%, bogey 45%, double 20%, triple+ 5%
--   P(tie per hole) ≈ 0.31  →  18 holes × 0.31 ≈ 5-6 ties  ✓
--   Active holes ≈ 12, each player wins ≈ 6
--   Avg score diff on active holes: diff1=65%, diff2=28%, diff3+=7%
--   Avg bonus per winning hole (multiplier 10): 10 × 1.42 = 14.2
--   Avg rawDmg (off5 vs def5): 5 - 2 = 3
--   Avg finalDmg ≈ (3 + 14.2) × 1.05 (type) ≈ 18 HP/hole
--   Avg team HP (tier*10, 3 pokemon, avg tier 3.5): 3 × 35 = 105
--   Loser takes ≈ 6 × 18 = 108 HP → full wipe in ~18 holes  ✓
--
-- HP change (hpTier * 10 instead of * 20) is Dart-side only (applied at team creation).
-- Only the RPC needs updating here.

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

  v_c_team     := v_battle.challenger_team;
  v_o_team     := v_battle.opponent_team;
  v_score_diff := abs(v_c_strokes - v_o_strokes);

  if v_c_strokes = v_o_strokes then
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

    -- Damage formula (tuned for 15 hcp):
    --   rawDmg     = max(1, offenseTier - floor(defenseTier / 2))
    --   scoreBonus = scoreDiff * 10
    --   finalDmg   = max(1, round((rawDmg + scoreBonus) * typeMult))
    v_raw_dmg     := greatest(1, (v_lead_atk ->> 'offense_tier')::int - ((v_lead_def ->> 'defense_tier')::int / 2));
    v_score_bonus := v_score_diff * 10;
    v_type_mult   := battle_type_mult(
      array(select jsonb_array_elements_text(v_lead_atk -> 'types')),
      array(select jsonb_array_elements_text(v_lead_def -> 'types'))
    );
    if v_type_mult = 0 then v_type_mult := 1.0; end if;
    v_final_dmg   := greatest(1, round((v_raw_dmg + v_score_bonus)::numeric * v_type_mult)::int);

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

    v_log_entry := jsonb_build_object(
      'hole',             p_hole,
      'c_strokes',        v_c_strokes,
      'o_strokes',        v_o_strokes,
      'result',           case when v_c_strokes < v_o_strokes then 'challenger_wins' else 'opponent_wins' end,
      'damage',           v_final_dmg,
      'type_mult',        v_type_mult,
      'attacker_pokemon', v_lead_atk ->> 'name',
      'defender_pokemon', v_lead_def ->> 'name',
      'c_team_after',     v_c_team,
      'o_team_after',     v_o_team
    );
  end if;

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
    v_winner_id := v_battle.challenger_id;
  elsif v_c_alive = 0 then
    v_winner_id := v_battle.opponent_id;
  elsif v_o_alive = 0 then
    v_winner_id := v_battle.challenger_id;
  elsif p_hole = v_battle.hole_count then
    if v_c_alive > v_o_alive then
      v_winner_id := v_battle.challenger_id;
    elsif v_o_alive > v_c_alive then
      v_winner_id := v_battle.opponent_id;
    elsif v_c_total_hp > v_o_total_hp then
      v_winner_id := v_battle.challenger_id;
    elsif v_o_total_hp > v_c_total_hp then
      v_winner_id := v_battle.opponent_id;
    else
      v_winner_id := v_battle.challenger_id;
    end if;
  end if;

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
