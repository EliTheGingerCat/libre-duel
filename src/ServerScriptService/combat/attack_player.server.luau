local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local add_cooldown = require(ReplicatedStorage.shared.cooldown.add_cooldown)
local apply_hit_highlight = require(script.Parent.apply_hit_highlight)
local apply_knockback = require(ReplicatedStorage.shared.combat.apply_knockback)
local debug_print = require(ServerScriptService.util.debug_print)
local get_player_cps = require(ServerScriptService.mitigation.get_player_cps)
local is_on_cooldown = require(ReplicatedStorage.shared.cooldown.is_on_cooldown)
local knockback_multiplier = require(script.Parent.knockback_multiplier)
const MITIGATION_CONFIG = require(ServerScriptService.mitigation.MITIGATION_CONFIG)
local play_sound = require(ServerScriptService.util.play_sound)
const PLAYER_RANGE_SERVER = require(script.Parent.PLAYER_RANGE_SERVER)
const SWORD_COOLDOWN_SERVER = require(script.Parent.SWORD_COOLDOWN_SERVER)
const SWORD_DAMAGE = require(ReplicatedStorage.shared.combat.SWORD_DAMAGE)

local function on_event(player: Player, target_name: unknown): ()
	local target_character = workspace:FindFirstChild(target_name) :: Model?
	if target_character == nil then
		debug_print("Target character not found in Workspace.")
		return
	end

	if typeof(target_character) ~= "Instance" then
		debug_print("Target character is not an Instance.")
		return
	end

	if not target_character:IsA("Model") then
		debug_print("Target character is not a Model.")
		return
	end

	local target_root = target_character:FindFirstChild("HumanoidRootPart") :: Part?
	if target_root == nil then
		debug_print("Target root is nil.")
		return
	end

	local target_humanoid = target_character:FindFirstChildOfClass("Humanoid")
	if target_humanoid == nil then
		debug_print("Target humanoid is nil.")
		return
	end

	if target_humanoid.Health <= 0 then
		debug_print("Target humanoid health is 0.")
		return
	end

	local target_position = target_root.CFrame.Position

	local attacker_character = player.Character
	if attacker_character == nil then
		debug_print("Attacker character is nil.")
		return
	end

	local attacker_humanoid = attacker_character:FindFirstChildOfClass("Humanoid")
	if attacker_humanoid == nil then
		debug_print("Attacker humanoid is nil.")
		return
	end

	if attacker_humanoid.Health <= 0 then
		debug_print("Attacker humanoid health is 0.")
		return
	end

	local attacker_root = attacker_character:FindFirstChild("HumanoidRootPart") :: Part?
	if attacker_root == nil then
		debug_print("Attacker root is nil.")
		return
	end

	local attacker_position = attacker_root.CFrame.Position

	if is_on_cooldown(player, "attack_melee") then
		debug_print("Attacker is on cooldown.")
		return
	end

	if is_on_cooldown(player, "attack_melee_mitigation") then
		debug_print("Attacker is mitigated.")
		return
	end

	--i'm surprised this basic sanity check was not yet added
	--credits to nothm for finding
	if attacker_character == target_character then
		player:Kick("Cheating")
	end

	if
		Players:GetPlayerFromCharacter(attacker_character).Team
			== Players:GetPlayerFromCharacter(target_character).Team
		and not Players:GetPlayerFromCharacter(attacker_character).Neutral
		and not Players:GetPlayerFromCharacter(target_character).Neutral
	then
		debug_print("Attacker and target are on the same team.")
		return
	end

	local distance = (target_position - attacker_position).Magnitude
	if distance > PLAYER_RANGE_SERVER then
		debug_print("Too far.")
		return
	end

	if
		get_player_cps(player) >= MITIGATION_CONFIG.cps_treshold
		and math.random(1, 100) <= MITIGATION_CONFIG.rejection_chance
	then
		add_cooldown(player, "attack_melee_mitigation", MITIGATION_CONFIG.duration)
		debug_print("Attacker has triggered a mitigation.")
		return
	end
	debug_print("Attack success.")

	target_humanoid.Health -= SWORD_DAMAGE

	apply_knockback(attacker_root.CFrame.LookVector, target_root, knockback_multiplier.X, knockback_multiplier.Y)

	apply_hit_highlight(target_character, 0.6)

	play_sound("player_damaged", target_position)

	add_cooldown(player, "attack_melee", SWORD_COOLDOWN_SERVER)
end

ReplicatedStorage.remotes.attack_player.OnServerEvent:Connect(on_event)
