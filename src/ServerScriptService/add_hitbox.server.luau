local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local debug_print = require(script.Parent.modules.debug_print)
local hitbox = ServerStorage.hitbox

local function on_character_added(character: Model): ()
	local clone = hitbox:Clone()

	local root = character:FindFirstChild("HumanoidRootPart") :: Part?
	if root == nil then
		debug_print("Humanoid root part is missing.")
		return
	end

	local weld = clone.Weld
	weld.Part0 = clone
	weld.Part1 = root

	clone.Parent = root -- changed to parent to root instead because parenting to character made roblox goof with the size for some reason..
end

local function on_player_added(player: Player): ()
	if player.Character then
		on_character_added(player.Character)
	end

	player.CharacterAdded:Connect(on_character_added)
end

for _, player in Players:GetPlayers() do
	on_player_added(player)
end

Players.PlayerAdded:Connect(on_player_added)
