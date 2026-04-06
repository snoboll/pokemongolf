-- Add battles to the Supabase Realtime publication so row changes
-- are broadcast over websocket to subscribed clients.
alter publication supabase_realtime add table public.battles;
