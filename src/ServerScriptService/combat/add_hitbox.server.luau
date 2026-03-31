local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local debug_print = require(ServerScriptService.util.debug_print)
local hitbox = ServerStorage.hitbox
local cube_hitbox = ServerStorage.cube_hitbox

local function attach_part(template: BasePart, root: BasePart): ()
	local clone = template:Clone()
	local weld = clone.Weld
	weld.Part0 = clone
	weld.Part1 = root
	clone.Parent = root
end

local function on_character_added(character: Model): ()
	local root = character:FindFirstChild("HumanoidRootPart") :: Part?
	if root == nil then
		debug_print("Humanoid root part is missing.")
		return
	end

	attach_part(hitbox, root)
	attach_part(cube_hitbox, root)
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
