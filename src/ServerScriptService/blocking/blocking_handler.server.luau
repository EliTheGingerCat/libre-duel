const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const blocking_entities = require(script.Parent.blocking_entities)
const inventory_util = require(script.Parent.Parent.inventory.inventory_util)

-- suffixing _remote as to not confuse roblo
const update_blocking_remote = ReplicatedStorage.remotes.update_blocking

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

update_blocking_remote.OnServerInvoke = update_blocking
