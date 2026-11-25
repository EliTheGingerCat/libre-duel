-- the guild each player's hint points at, with a session reference held for it
-- the guild can still be missing them while its cache catches up, get_player_guild checks for that
const player_guild_ids: { [Player]: string } = {}

return player_guild_ids
