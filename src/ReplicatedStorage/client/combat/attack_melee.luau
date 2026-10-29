local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local add_cooldown = require(ReplicatedStorage.shared.cooldown.add_cooldown)
local debug_print = require(script.Parent.Parent.util.debug_print)
local get_mouse_target = require(script.Parent.get_mouse_target)
local get_player_position = require(ReplicatedStorage.shared.player.get_player_position)
local hit_feedback = require(script.Parent.hit_feedback)
local is_on_cooldown = require(ReplicatedStorage.shared.cooldown.is_on_cooldown)
const PLAYER_RANGE = require(ReplicatedStorage.shared.combat.PLAYER_RANGE)
const SWORD_COOLDOWN  = require(ReplicatedStorage.shared.combat.SWORD_COOLDOWN)

local local_player = Players.LocalPlayer

local function attack_melee(): ()
	local target_hitbox: BasePart? = get_mouse_target()
	if target_hitbox == nil then
		debug_print("Mouse target is missing.")
		return
	end

	local local_position = get_player_position(local_player) + Vector3.new(0, 3, 0) --adding a y offset because calculating reach from the head tends to feel better.
	if local_position == nil then
		debug_print("Local position is missing.")
		return
	end

	local target_character = target_hitbox.Parent.Parent -- hitbox >> HumanoidRootPart >> Character
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
	if distance > PLAYER_RANGE then
		debug_print("Too far.")
		return
	end

	if is_on_cooldown(local_player, "attack_melee") then
		debug_print("On cooldown.")
		return
	end

	debug_print("Success. Attacking.")

	ReplicatedStorage.remotes.attack_player:FireServer(target_character.Name)
	add_cooldown(local_player, "attack_melee", SWORD_COOLDOWN)
	hit_feedback.report(distance)
end

return attack_melee
