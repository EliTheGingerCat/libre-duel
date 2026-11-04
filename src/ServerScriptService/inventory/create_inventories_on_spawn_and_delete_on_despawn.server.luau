const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const inventory_util = require(script.Parent.inventory_util)

const update_inventory = ReplicatedStorage.remotes.update_inventory

local function character_added(player: Player, character: Model): ()
	const inventory = inventory_util.generate_inventory(player)
	if type(inventory) == "table" then
		inventory_util.give_loadout(inventory)
		-- remote events queue until the client connects, so this arrives even if the client script loads late
		update_inventory:FireClient(player, { inventory = inventory })
	end

	local function on_died(): ()
		if inventory_util.delete_inventory(player) then
			update_inventory:FireClient(player, { inventory = nil })
		end
	end

	const humanoid = character:WaitForChild("Humanoid") :: Humanoid
	-- the connection gets cleaned up when the character is destroyed
	humanoid.Died:Once(on_died)
end

local function player_added(player: Player): ()
	local function on_character_added(character: Model): ()
		character_added(player, character)
	end

	player.CharacterAdded:Connect(on_character_added)
	if player.Character then
		character_added(player, player.Character)
	end
end

-- players leaving while alive never fire Died
local function player_removing(player: Player): ()
	inventory_util.delete_inventory(player)
end

Players.PlayerAdded:Connect(player_added)
Players.PlayerRemoving:Connect(player_removing)

for _, player in Players:GetPlayers() do
	player_added(player)
end
