local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local debug_print = require(script.Parent.debug_print)
local get_player_position = require(ReplicatedStorage.modules.get_player_position)
local play_sound_local = require(script.Parent.play_sound_local)
local player_attack_range = require(ReplicatedStorage.modules.player_attack_range)

local local_player = Players.LocalPlayer
local local_mouse = local_player:GetMouse()

local function attack_melee(): ()
	local target_limb: BasePart? = local_mouse.Target
	if target_limb == nil then
		debug_print("Mouse target is missing.")
		return
	end

	local local_position = get_player_position(local_player)
	if local_position == nil then
		debug_print("Local position is missing.")
		return
	end

	local target_character = target_limb.Parent
	if target_character == nil then
		debug_print("Mouse target's character is missing.")
		return
	end

	if not target_character:IsA("Model") then
		debug_print("Mouse target's parent is not a Model.")
		return
	end

	local target_root = target_character:FindFirstChild("HumanoidRootPart") :: Part?
	if target_root == nil then
		debug_print("Humanoid root part is missing.")
		return
	end

	local target_position = target_root.CFrame.Position
	
	local distance = (target_position - local_position).Magnitude
	if distance > player_attack_range then
		debug_print("Too far.")
		return
	end

	debug_print("Success. Attacking.")

	play_sound_local("player_damaged", target_position)

	ReplicatedStorage.remotes.attack_player:FireServer(target_character)
end

return attack_melee
