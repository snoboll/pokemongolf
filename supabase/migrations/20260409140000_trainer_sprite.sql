-- Add golfer sprite choice to player profiles
alter table public.profiles
  add column if not exists golfer_sprite text;

-- Add golfer sprite to course leaders so claimed courses show the player's avatar
alter table public.course_leaders
  add column if not exists golfer_sprite text;

-- Update claim_course_leadership to propagate the player's sprite
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
  v_battle         record;
  v_user_id        uuid;
  v_golfer_name   text;
  v_hcp            int;
  v_golfer_sprite text;
begin
  v_user_id := auth.uid();

  select * into v_battle from battles where id = p_battle_id;
  if not found then raise exception 'Battle not found'; end if;
  if v_battle.winner_id != v_user_id then raise exception 'You did not win this battle'; end if;
  if v_battle.course_id != p_course_id then raise exception 'Battle course mismatch'; end if;
  if not v_battle.is_leader_challenge then raise exception 'Not a leader challenge'; end if;

  select golfer_name, hcp, golfer_sprite
    into v_golfer_name, v_hcp, v_golfer_sprite
    from profiles where user_id = v_user_id;

  insert into course_leaders (course_id, user_id, leader_name, hcp, team, is_npc, claimed_at, golfer_sprite)
  values (p_course_id, v_user_id, coalesce(v_golfer_name, 'Golfer'), coalesce(v_hcp, 36), p_team, false, now(), v_golfer_sprite)
  on conflict (course_id) do update set
    user_id        = excluded.user_id,
    leader_name    = excluded.leader_name,
    hcp            = excluded.hcp,
    team           = excluded.team,
    is_npc         = false,
    claimed_at     = now(),
    golfer_sprite = excluded.golfer_sprite;

  return (select row_to_json(cl)::jsonb from course_leaders cl where course_id = p_course_id);
end;
$$;
