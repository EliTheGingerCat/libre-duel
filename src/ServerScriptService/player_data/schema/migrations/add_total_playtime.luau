const ServerScriptService = game:GetService("ServerScriptService")

const INITIAL_PLAYER_DATA = require(ServerScriptService.player_data.schema.INITIAL_PLAYER_DATA)

export type with_total_playtime = INITIAL_PLAYER_DATA.base_player_data & {
	playtime: number, -- seconds
}

const function add_total_playtime(data: INITIAL_PLAYER_DATA.base_player_data): with_total_playtime
	const new_data = table.clone(data) :: with_total_playtime
	new_data.playtime = 0
	return new_data
end

return add_total_playtime
