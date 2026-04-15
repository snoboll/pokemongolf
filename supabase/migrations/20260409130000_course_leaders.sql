-- Course Leaders: each course can have a defending leader (player or NPC).
-- Players challenge leaders in PvE-style battles. Winners claim the throne.

-- ── Add handicap to profiles ─────────────────────────────────────────────────

alter table public.profiles
  add column if not exists hcp int not null default 36;

-- ── Course leaders table ─────────────────────────────────────────────────────

create table if not exists public.course_leaders (
  course_id    text primary key,
  user_id      uuid references auth.users(id),
  leader_name  text not null,
  hcp          int not null default 36,
  team         jsonb not null default '[]',
  is_npc       boolean not null default false,
  claimed_at   timestamptz not null default now()
);

alter table public.course_leaders enable row level security;

drop policy if exists "leaders_select" on public.course_leaders;
create policy "leaders_select"
  on public.course_leaders for select
  to authenticated using (true);

-- ── Extend battles for leader challenges ─────────────────────────────────────

alter table public.battles
  add column if not exists is_leader_challenge boolean not null default false;

alter table public.battles
  add column if not exists leader_hcp int;

-- ── submit_leader_challenge_score ────────────────────────────────────────────
-- Generates the leader's score from HCP, writes both scores, resolves combat.
-- The player is always the challenger; the leader is the opponent.

create or replace function submit_leader_challenge_score(
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
  v_leader_hcp      int;
  v_par             int;
  v_hcp_adj         numeric;
  v_leader_strokes  int;
  v_roll            numeric;
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
  v_completed       boolean;
  i                 int;
begin
  v_user_id := auth.uid();

  select * into v_battle from battles where id = p_battle_id for update;

  if not found then raise exception 'Battle not found'; end if;
  if not v_battle.is_leader_challenge then
    raise exception 'Not a leader challenge';
  end if;
  if v_battle.status != 'active' then
    raise exception 'Battle is not active';
  end if;
  if v_battle.challenger_id != v_user_id then
    raise exception 'Not the challenger';
  end if;
  if (v_battle.challenger_scores ->> p_hole::text) is not null then
    raise exception 'Score already submitted for hole %', p_hole;
  end if;

  -- ── Generate leader score from HCP ─────────────────────────────────────────

  v_leader_hcp := coalesce(v_battle.leader_hcp, 36);
  v_par := v_battle.course_pars[p_hole];
  v_hcp_adj := v_leader_hcp::numeric / v_battle.hole_count;
  v_roll := random();

  v_leader_strokes := v_par + greatest(0, round(v_hcp_adj + (v_roll * 2.0 - 1.0)))::int;
  v_leader_strokes := greatest(v_par - 1, v_leader_strokes);
  v_leader_strokes := greatest(1, v_leader_strokes);

  -- Write both scores
  update battles set
    challenger_scores = challenger_scores || jsonb_build_object(p_hole::text, p_strokes),
    opponent_scores   = opponent_scores   || jsonb_build_object(p_hole::text, v_leader_strokes)
  where id = p_battle_id;

  select * into v_battle from battles where id = p_battle_id;

  v_c_strokes := p_strokes;
  v_o_strokes := v_leader_strokes;

  -- ── Resolve combat (mirrors submit_battle_score logic) ─────────────────────

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

    if v_lead_atk is not null and v_lead_def is not null then
      v_raw_dmg     := greatest(1, (v_lead_atk ->> 'offense_tier')::int
                                  - ((v_lead_def ->> 'defense_tier')::int / 2));
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
      v_final_dmg := 0;
      v_type_mult := 1.0;
    end if;

    v_log_entry := jsonb_build_object(
      'hole',             p_hole,
      'c_strokes',        v_c_strokes,
      'o_strokes',        v_o_strokes,
      'result',           case when v_c_strokes < v_o_strokes then 'challenger_wins'
                               else 'opponent_wins' end,
      'damage',           v_final_dmg,
      'type_mult',        v_type_mult,
      'attacker_bogeybeast', case when v_lead_atk is not null then v_lead_atk ->> 'name'
                               else null end,
      'defender_bogeybeast', case when v_lead_def is not null then v_lead_def ->> 'name'
                               else null end,
      'c_team_after',     v_c_team,
      'o_team_after',     v_o_team
    );
  end if;

  -- ── Count alive + HP ───────────────────────────────────────────────────────

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

  -- ── Determine winner ───────────────────────────────────────────────────────
  -- For leader challenges opponent_id may be NULL (NPC), so we track completion
  -- separately from winner_id.

  v_winner_id := null;
  v_completed := false;

  if v_c_alive = 0 or v_o_alive = 0 or p_hole = v_battle.hole_count then
    v_completed := true;
    if v_c_alive > v_o_alive then
      v_winner_id := v_battle.challenger_id;
    elsif v_o_alive > v_c_alive then
      v_winner_id := v_battle.opponent_id; -- NULL for NPC = player lost
    elsif v_c_total_hp > v_o_total_hp then
      v_winner_id := v_battle.challenger_id;
    elsif v_o_total_hp > v_c_total_hp then
      v_winner_id := v_battle.opponent_id;
    else
      v_winner_id := v_battle.challenger_id; -- tie: challenger wins
    end if;
  end if;

  -- ── Persist ────────────────────────────────────────────────────────────────

  update battles set
    challenger_team = v_c_team,
    opponent_team   = v_o_team,
    hole_log        = hole_log || v_log_entry,
    winner_id       = v_winner_id,
    status          = case when v_completed then 'completed' else 'active' end,
    completed_at    = case when v_completed then now() else null end
  where id = p_battle_id;

  return (select row_to_json(b)::jsonb from battles b where id = p_battle_id);
end;
$$;

-- ── claim_course_leadership ──────────────────────────────────────────────────
-- Called after winning a leader challenge. Player assigns 3 defenders.

create or replace function claim_course_leadership(
  p_course_id  text,
  p_battle_id  uuid,
  p_team       jsonb
)
returns jsonb
language plpgsql
security definer
as $$
declare
  v_battle       record;
  v_user_id      uuid;
  v_golfer_name text;
  v_hcp          int;
begin
  v_user_id := auth.uid();

  select * into v_battle from battles where id = p_battle_id;
  if not found then raise exception 'Battle not found'; end if;
  if v_battle.winner_id != v_user_id then raise exception 'You did not win this battle'; end if;
  if v_battle.course_id != p_course_id then raise exception 'Battle course mismatch'; end if;
  if not v_battle.is_leader_challenge then raise exception 'Not a leader challenge'; end if;

  select golfer_name, hcp into v_golfer_name, v_hcp
  from profiles where user_id = v_user_id;

  insert into course_leaders (course_id, user_id, leader_name, hcp, team, is_npc, claimed_at)
  values (p_course_id, v_user_id, coalesce(v_golfer_name, 'Golfer'), coalesce(v_hcp, 36), p_team, false, now())
  on conflict (course_id) do update set
    user_id     = excluded.user_id,
    leader_name = excluded.leader_name,
    hcp         = excluded.hcp,
    team        = excluded.team,
    is_npc      = false,
    claimed_at  = now();

  return (select row_to_json(cl)::jsonb from course_leaders cl where course_id = p_course_id);
end;
$$;
