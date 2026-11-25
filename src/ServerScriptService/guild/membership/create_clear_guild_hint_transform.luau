const ServerScriptService = game:GetService("ServerScriptService")

const player_schema = require(ServerScriptService.player_data.schema.player_schema)

export type player_data_transform = (data: player_schema.player_data) -> player_schema.player_data

-- leaves the hint alone when it already points at a different guild the player joined since
const function create_clear_guild_hint_transform(guild_id: string): player_data_transform
	const function clear_guild_hint(data: player_schema.player_data): player_schema.player_data
		if data.guild_id ~= guild_id then
			return data
		end
		const new_data = table.clone(data)
		new_data.guild_id = ""
		return new_data
	end
	return clear_guild_hint
end

return create_clear_guild_hint_transform
