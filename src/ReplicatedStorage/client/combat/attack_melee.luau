local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local add_cooldown = require(ReplicatedStorage.shared.cooldown.add_cooldown)
local debug_print = require(script.Parent.Parent.util.debug_print)
local get_player_position = require(ReplicatedStorage.shared.player.get_player_position)
local is_on_cooldown = require(ReplicatedStorage.shared.cooldown.is_on_cooldown)
local player_range = require(ReplicatedStorage.shared.combat.player_range)
local sword_cooldown  = require(ReplicatedStorage.shared.combat.sword_cooldown)
local get_mouse_target = require(script.Parent.get_mouse_target)

local local_player = Players.LocalPlayer

local function attack_melee(): ()
	local target_hitbox = get_mouse_target()
	if target_hitbox == nil then
		debug_print("Mouse target is missing.")
		return
	end

	local local_position = get_player_position(local_player)
	if local_position == nil then
		debug_print("Local position is missing.")
		return
	end
	local_position += Vector3.new(0, 3, 0) --adding a y offset because calculating reach from the head tends to feel better.

	local target_root = target_hitbox.Parent
	if target_root == nil then
		debug_print("Mouse target's parent is missing. This should be a humanoid root part.")
		return
	end

	if not target_root:IsA("Part") then
		debug_print("Mouse target's parent (humanoid root part) is not a part.")
		return
	end

	local target_character = target_root.Parent
	if target_character == nil then
		debug_print("Mouse target's character is missing.")
		return
	end

	if not target_character:IsA("Model") then
		debug_print("Mouse target's parent is not a Model.")
		return
	end

	local target_position = target_root.CFrame.Position

	local distance = (target_position - local_position).Magnitude
	if distance > player_range then
		debug_print("Too far.")
		return
	end

	if is_on_cooldown(local_player, "attack_melee") then
		debug_print("On cooldown.")
		return
	end

	debug_print("Success. Attacking.")

	ReplicatedStorage.remotes.attack_player:FireServer(target_character)
	add_cooldown(local_player, "attack_melee", sword_cooldown)
end

return attack_melee
