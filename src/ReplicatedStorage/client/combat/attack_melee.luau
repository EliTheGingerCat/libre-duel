const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const add_cooldown = require(ReplicatedStorage.shared.cooldown.add_cooldown)
const debug_print = require(script.Parent.Parent.util.debug_print)
const ENTITY_RANGE = require(ReplicatedStorage.shared.combat.ENTITY_RANGE)
const get_entity_position = require(ReplicatedStorage.shared.entity.get_entity_position)
const get_mouse_target = require(script.Parent.get_mouse_target)
const hit_feedback = require(script.Parent.hit_feedback)
const is_on_cooldown = require(ReplicatedStorage.shared.cooldown.is_on_cooldown)
const registry = require(ReplicatedStorage.shared.entity.registry)
const SWORD_COOLDOWN = require(ReplicatedStorage.shared.combat.SWORD_COOLDOWN)

const local_player = Players.LocalPlayer

local function attack_melee(): ()
	const target_hitbox: BasePart? = get_mouse_target()
	if target_hitbox == nil then
		debug_print("Mouse target is missing.")
		return
	end

	const local_position = get_entity_position(local_player)
	if local_position == nil then
		debug_print("Local position is missing.")
		return
	end

	const target_root_container = target_hitbox.Parent
	const target_character = if target_root_container then target_root_container.Parent else nil
	if target_character == nil then
		debug_print("Mouse target's character is missing.")
		return
	end

	if not target_character:IsA("Model") then
		debug_print("Mouse target's parent is not a Model.")
		return
	end

	const target_root = target_character:FindFirstChild("HumanoidRootPart")
	if target_root == nil or not target_root:IsA("BasePart") then
		debug_print("Humanoid root part is missing.")
		return
	end

	const target_position = target_root.CFrame.Position

	const distance = (target_position - (local_position + Vector3.new(0, 3, 0))).Magnitude
	if distance > ENTITY_RANGE then
		debug_print("Too far.")
		return
	end

	if is_on_cooldown(local_player, "attack_melee") then
		debug_print("On cooldown.")
		return
	end

	debug_print("Success. Attacking.")

	const target = registry.from_character(target_character)
	if target == nil then
		return
	end

	ReplicatedStorage.remotes.attack_entity:FireServer(target)
	add_cooldown(local_player, "attack_melee", SWORD_COOLDOWN)
	hit_feedback.report(distance)
end

return attack_melee
