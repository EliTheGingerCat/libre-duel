local ReplicatedStorage = game:GetService("ReplicatedStorage")

local play_sound_excluding = require(script.Parent.modules.play_sound_excluding)
local player_attack_range_server = require(script.Parent.modules.player_attack_range_server)

local DAMAGE = 10

local function on_event(player: Player, target_character: unknown): ()
	if typeof(target_character) ~= "Instance" then
		return
	end

	if not target_character:IsA("Model") then
		return
	end

	local target_root = target_character:FindFirstChild("HumanoidRootPart") :: Part?
	if target_root == nil then
		return
	end

	local target_position = target_root.CFrame.Position

	local attacker_character = player.Character
	if attacker_character == nil then
		return
	end

	local attacker_root = attacker_character:FindFirstChild("HumanoidRootPart") :: Part?
	if attacker_root == nil then
		return
	end

	local attacker_position = attacker_root.CFrame.Position
	
	local distance = (target_position - attacker_position).Magnitude
	if distance > player_attack_range_server then
		return
	end

	local target_humanoid = target_character:FindFirstChildOfClass("Humanoid")
	if target_humanoid == nil then
		return
	end

	target_humanoid.Health -= DAMAGE

	play_sound_excluding(player, "player_damaged", attacker_position)
end

ReplicatedStorage.remotes.attack_player.OnServerEvent:Connect(on_event)
