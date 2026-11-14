const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const move_entity = require(ServerScriptService.util.move_entity)
const registry = require(ReplicatedStorage.shared.entity.registry)
const SPAWN_PIVOT_OFFSET = require(script.Parent.SPAWN_PIVOT_OFFSET)

-- CharacterAdded fires before the character is parented, and a character replicated with its unplaced pose at the
-- origin gets pulled back there by the owning client even after roblox moves it to the RespawnLocation, so it is
-- placed here first and never exists anywhere else
const function on_character_added(_character: Model, entity: registry.entity): ()
	const player = registry.get_player(entity)
	const spawn_location = if player then player.RespawnLocation else nil
	if spawn_location then
		move_entity(entity, (spawn_location.CFrame * SPAWN_PIVOT_OFFSET).Position)
	end
end

registry.character_added:Connect(on_character_added)
