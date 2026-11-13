const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const drop = require(ServerScriptService.ServerPackages.drop)
const registry = require(ReplicatedStorage.shared.entity.registry)
const player_schema = require(ServerScriptService.player_data.schema.player_schema)
const player_store = require(ServerScriptService.player_data.player_store)

-- bots have no saved data so updating one does nothing
const function update_player_data(
	entity: registry.entity,
	transform: (data: player_schema.player_data) -> player_schema.player_data
): ()
	const player = registry.get_player(entity)
	if player == nil then
		return
	end
	drop.update(player_store, tostring(player.UserId), transform)
end

return update_player_data
