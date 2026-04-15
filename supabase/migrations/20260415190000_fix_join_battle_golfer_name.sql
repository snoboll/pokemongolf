-- Re-deploy join_battle with corrected column reference.
-- The original function was deployed when the column was still called trainer_name;
-- after the rename to golfer_name the function was never updated on the live DB.

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
    opponent_name = (select golfer_name from profiles where user_id = auth.uid()),
    opponent_team = p_team,
    status        = 'active'
  where id = p_battle_id;

  return (select row_to_json(b)::jsonb from battles b where id = p_battle_id);
end;
$$;
