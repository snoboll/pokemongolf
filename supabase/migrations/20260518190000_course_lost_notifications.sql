-- Login notifications. First use: tell a course leader they were dethroned.

create table if not exists notifications (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid references auth.users(id) not null,
  type       text not null,
  title      text not null,
  body       text not null,
  created_at timestamptz not null default now(),
  read_at    timestamptz
);

create index if not exists notifications_user_unread_idx
  on notifications (user_id) where read_at is null;

alter table notifications enable row level security;

drop policy if exists "Users read their own notifications" on notifications;
create policy "Users read their own notifications"
  on notifications for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "Users update their own notifications" on notifications;
create policy "Users update their own notifications"
  on notifications for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Re-deploy claim_course_leadership: notify the displaced human leader.
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
  v_golfer_name    text;
  v_hcp            int;
  v_golfer_sprite  text;
  v_golfer_team    text;
  v_old_leader_id  uuid;
  v_old_is_npc     boolean;
  v_course_name    text;
begin
  v_user_id := auth.uid();

  select * into v_battle from battles where id = p_battle_id;
  if not found then raise exception 'Battle not found'; end if;
  if v_battle.winner_id != v_user_id then raise exception 'You did not win this battle'; end if;
  if v_battle.course_id != p_course_id then raise exception 'Battle course mismatch'; end if;
  if not v_battle.is_leader_challenge then raise exception 'Not a leader challenge'; end if;

  select golfer_name, hcp, golfer_sprite, golfer_team
    into v_golfer_name, v_hcp, v_golfer_sprite, v_golfer_team
    from profiles where user_id = v_user_id;

  -- Capture the current leader before it is overwritten.
  select user_id, is_npc into v_old_leader_id, v_old_is_npc
    from course_leaders where course_id = p_course_id;

  insert into course_leaders (
    course_id,
    user_id,
    leader_name,
    hcp,
    team,
    is_npc,
    claimed_at,
    golfer_sprite,
    golfer_team
  )
  values (
    p_course_id,
    v_user_id,
    coalesce(v_golfer_name, 'Golfer'),
    coalesce(v_hcp, 36),
    p_team,
    false,
    now(),
    v_golfer_sprite,
    v_golfer_team
  )
  on conflict (course_id) do update set
    user_id       = excluded.user_id,
    leader_name   = excluded.leader_name,
    hcp           = excluded.hcp,
    team          = excluded.team,
    is_npc        = false,
    claimed_at    = now(),
    golfer_sprite = excluded.golfer_sprite,
    golfer_team   = excluded.golfer_team;

  -- Notify the displaced human leader (not NPCs, not self).
  if v_old_leader_id is not null
     and v_old_leader_id <> v_user_id
     and coalesce(v_old_is_npc, true) = false then
    select name into v_course_name from catalog_courses where id = p_course_id;
    insert into notifications (user_id, type, title, body)
    values (
      v_old_leader_id,
      'course_lost',
      'You lost a course',
      coalesce(v_golfer_name, 'A golfer')
        || ' defeated your team and claimed '
        || coalesce(v_course_name, p_course_id) || '.'
    );
  end if;

  return (
    select row_to_json(cl)::jsonb
    from course_leaders cl
    where course_id = p_course_id
  );
end;
$$;
