const Players = game:GetService("Players")
const ServerScriptService = game:GetService("ServerScriptService")

const blocking_entities = require(script.Parent.blocking_entities)
const inventory_util = require(script.Parent.Parent.inventory.inventory_util)
const zap_server_network = require(ServerScriptService.network.zap_server_network)

const function update_blocking(player: Player, to: boolean): ()
	if to == false then
		blocking_entities[player] = nil
	end
	if to == true then
		assert(inventory_util.has_behaviour(player, "sword"), `{player.Name} tried to block without holding a sword.`)
		blocking_entities[player] = true
	end
end

const function player_removing(player: Player): ()
	update_blocking(player, false)
end

const function player_added(player: Player): ()
	-- CharacterRemoving passes the character, so the player has to come from here
	const function character_removing(): ()
		update_blocking(player, false)
	end
	player.CharacterRemoving:Connect(character_removing)
end

Players.PlayerAdded:Connect(player_added)
Players.PlayerRemoving:Connect(player_removing)

zap_server_network.update_blocking.set_callback(update_blocking)
