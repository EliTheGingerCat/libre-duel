const ServerScriptService = game:GetService("ServerScriptService")

const drop = require(ServerScriptService.ServerPackages.drop)
const player_schema = require(ServerScriptService.player_data.schema.player_schema)
const player_store = require(ServerScriptService.player_data.player_store)

const function initialize_player_data(key: string): ()
	const function fill_first_join_fields(data: player_schema.player_data): player_schema.player_data
		if data.first_joined ~= 0 then
			return data
		end
		const new_data = table.clone(data)
		new_data.user_id = key
		new_data.first_joined = os.time()
		return new_data
	end
	drop.update(player_store, key, fill_first_join_fields)
end

return initialize_player_data
