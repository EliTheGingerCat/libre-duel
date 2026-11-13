const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const registry = require(ReplicatedStorage.shared.entity.registry)
const player_schema = require(ServerScriptService.player_data.schema.player_schema)
const update_player_data = require(script.Parent.update_player_data)

-- for stats that live at the top level of the player data rather than under a mode
const function award_player_stat(entity: registry.entity, stat: player_schema.player_stat, increment: number?): ()
	const amount = increment or 1
	const function add_to_player_stat(data: player_schema.player_data): player_schema.player_data
		const new_data = table.clone(data)
		new_data[stat] += amount
		return new_data
	end
	update_player_data(entity, add_to_player_stat)
end

return award_player_stat
