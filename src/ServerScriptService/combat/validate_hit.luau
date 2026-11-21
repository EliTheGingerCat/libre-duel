const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const add_cooldown = require(ReplicatedStorage.shared.cooldown.add_cooldown)
const debug_print = require(ServerScriptService.util.debug_print)
const get_player_cps = require(ServerScriptService.cps.get_player_cps)
const god_mode = require(script.Parent.god_mode)
const is_on_cooldown = require(ReplicatedStorage.shared.cooldown.is_on_cooldown)
const match = require(ServerScriptService.match.match)
const MITIGATION_CONFIG = require(ServerScriptService.mitigation.MITIGATION_CONFIG)
const registry = require(ReplicatedStorage.shared.entity.registry)

type projectile_hit = {
	direction: Vector3,
}

-- Projectile hits must come from a server cast, rather than a client-supplied target.
-- reach isn't checked here, melee callers have to resolve the target with lag compensation first
-- (see melee_swing), since current positions can be further apart than the rewound ones that were hit
const function validate_hit(
	attacker: registry.entity,
	target: registry.entity,
	damage: number,
	hit: projectile_hit?
): boolean
	const is_melee = hit == nil
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

	if god_mode.is_god(target) then
		debug_print("Target is in god mode.")
		return false
	end

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

	if is_melee and is_on_cooldown(attacker, "attack_melee") then
		debug_print("Attacker is on cooldown.")
		return false
	end

	if is_melee and is_on_cooldown(attacker, "attack_melee_mitigation") then
		debug_print("Attacker is mitigated.")
		return false
	end

	--i'm surprised this basic sanity check was not yet added
	--credits to nothm for finding
	const attacker_player = registry.get_player(attacker)
	if is_melee and attacker_character == target_character then
		if attacker_player then
			attacker_player:Kick("Cheating")
		end
		return false
	end

	const attacker_team = registry.get_team(attacker)
	const target_team = registry.get_team(target)
	if attacker_team ~= nil and attacker_team == target_team and attacker ~= target then
		debug_print("Attacker and target are on the same team.")
		return false
	end

	if match.get_match_of(attacker) ~= match.get_match_of(target) then
		debug_print("Attacker and target are not in the same match.")
		return false
	end

	if
		is_melee
		and attacker_player
		and get_player_cps(attacker_player) >= MITIGATION_CONFIG.cps_treshold
		and math.random(1, 100) <= MITIGATION_CONFIG.rejection_chance
	then
		add_cooldown(attacker, "attack_melee_mitigation", MITIGATION_CONFIG.duration)
		debug_print("Attacker has triggered a mitigation.")
		return false
	end

	return true
end

return validate_hit
