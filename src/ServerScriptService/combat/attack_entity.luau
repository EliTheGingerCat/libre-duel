const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const add_cooldown = require(ReplicatedStorage.shared.cooldown.add_cooldown)
const apply_hit_highlight = require(script.Parent.apply_hit_highlight)
const apply_knockback = require(ReplicatedStorage.shared.combat.apply_knockback)
const debug_print = require(ServerScriptService.util.debug_print)
const ENTITY_RANGE_SERVER = require(script.Parent.ENTITY_RANGE_SERVER)
const get_player_cps = require(ServerScriptService.mitigation.get_player_cps)
const is_on_cooldown = require(ReplicatedStorage.shared.cooldown.is_on_cooldown)
const knockback_multiplier = require(script.Parent.knockback_multiplier)
const MITIGATION_CONFIG = require(ServerScriptService.mitigation.MITIGATION_CONFIG)
const play_sound = require(ServerScriptService.util.play_sound)
const registry = require(ReplicatedStorage.shared.entity.registry)
const SWORD_COOLDOWN_SERVER = require(script.Parent.SWORD_COOLDOWN_SERVER)
const SWORD_DAMAGE = require(ReplicatedStorage.shared.combat.SWORD_DAMAGE)

local function attack_entity(attacker: registry.entity, target: registry.entity): boolean
	const target_character = registry.get_character(target)
	if target_character == nil or not target_character:IsDescendantOf(workspace) then
		debug_print("Target character not found in Workspace.")
		return false
	end

	const target_root = target_character:FindFirstChild("HumanoidRootPart")
	if target_root == nil or not target_root:IsA("BasePart") then
		debug_print("Target root is nil.")
		return false
	end

	const target_humanoid = target_character:FindFirstChildOfClass("Humanoid")
	if target_humanoid == nil then
		debug_print("Target humanoid is nil.")
		return false
	end

	if target_humanoid.Health <= 0 then
		debug_print("Target humanoid health is 0.")
		return false
	end

	const target_position = target_root.CFrame.Position

	const attacker_character = registry.get_character(attacker)
	if attacker_character == nil then
		debug_print("Attacker character is nil.")
		return false
	end

	const attacker_humanoid = attacker_character:FindFirstChildOfClass("Humanoid")
	if attacker_humanoid == nil then
		debug_print("Attacker humanoid is nil.")
		return false
	end

	if attacker_humanoid.Health <= 0 then
		debug_print("Attacker humanoid health is 0.")
		return false
	end

	const attacker_root = attacker_character:FindFirstChild("HumanoidRootPart")
	if attacker_root == nil or not attacker_root:IsA("BasePart") then
		debug_print("Attacker root is nil.")
		return false
	end

	const attacker_position = attacker_root.CFrame.Position

	if is_on_cooldown(attacker, "attack_melee") then
		debug_print("Attacker is on cooldown.")
		return false
	end

	if is_on_cooldown(attacker, "attack_melee_mitigation") then
		debug_print("Attacker is mitigated.")
		return false
	end

	--i'm surprised this basic sanity check was not yet added
	--credits to nothm for finding
	if attacker_character == target_character then
		if type(attacker) ~= "string" then
			attacker:Kick("Cheating")
		end
		return false
	end

	const attacker_team = registry.get_team(attacker)
	const target_team = registry.get_team(target)
	if attacker_team ~= nil and attacker_team == target_team then
		debug_print("Attacker and target are on the same team.")
		return false
	end

	const distance = (target_position - attacker_position).Magnitude
	if distance > ENTITY_RANGE_SERVER then
		debug_print("Too far.")
		return false
	end

	if
		type(attacker) ~= "string"
		and get_player_cps(attacker) >= MITIGATION_CONFIG.cps_treshold
		and math.random(1, 100) <= MITIGATION_CONFIG.rejection_chance
	then
		add_cooldown(attacker, "attack_melee_mitigation", MITIGATION_CONFIG.duration)
		debug_print("Attacker has triggered a mitigation.")
		return false
	end
	debug_print("Attack success.")

	target_humanoid.Health -= SWORD_DAMAGE

	apply_knockback(attacker_root.CFrame.LookVector, target_root, knockback_multiplier.X, knockback_multiplier.Y)

	apply_hit_highlight(target_character, 0.6)

	play_sound("player_damaged", target_position)

	add_cooldown(attacker, "attack_melee", SWORD_COOLDOWN_SERVER)
	return true
end

return attack_entity
