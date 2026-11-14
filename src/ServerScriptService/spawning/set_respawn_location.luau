const ReplicatedStorage = game:GetService("ReplicatedStorage")

const registry = require(ReplicatedStorage.shared.entity.registry)

-- roblox only honours this while the SpawnLocation's TeamColor matches the player's, nil sends them back to the lobby
const function set_respawn_location(entity: registry.entity, spawn_location: SpawnLocation?): ()
	const player = registry.get_player(entity)
	if player then
		-- the type definitions don't allow nil here even though roblox accepts it
		player.RespawnLocation = spawn_location :: any
	end
end

return set_respawn_location
