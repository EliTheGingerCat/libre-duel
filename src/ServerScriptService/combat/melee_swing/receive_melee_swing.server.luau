const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const attack_entity = require(ServerScriptService.combat.attack_entity)
const inventory_util = require(ServerScriptService.inventory.inventory_util)
const is_on_cooldown = require(ReplicatedStorage.shared.cooldown.is_on_cooldown)
const NON_SWORD_DAMAGE = require(ReplicatedStorage.shared.combat.NON_SWORD_DAMAGE)
const resolve_melee_swing_target = require(script.Parent.resolve_melee_swing_target)
const sanitise_render_times = require(script.Parent.sanitise_render_times)
const SWORD_DAMAGE = require(ReplicatedStorage.shared.combat.SWORD_DAMAGE)
const validate_aim_ray = require(ServerScriptService.aim_validation.validate_aim_ray)

-- the client only says where it aimed and when it was seeing everyone, what got hit is decided here
const function on_melee_swing(player: Player, origin: unknown, direction: unknown, raw_render_times: unknown): ()
	-- an empty hand can't attack, which keeps the lobby peaceful since nobody holds anything there
	const tool = inventory_util.get_selected_tool(player)
	if tool == nil then
		return
	end

	-- checked again by attack_entity, this just skips the casts for swings that can't land anyway
	if is_on_cooldown(player, "attack_melee") then
		return
	end

	const aim = validate_aim_ray(player, origin, direction)
	if aim == nil then
		return
	end

	const melee_hit = resolve_melee_swing_target(player, aim, sanitise_render_times(raw_render_times))
	if melee_hit == nil then
		return
	end

	const sword = tool.behaviours.sword
	const damage = if sword ~= nil then sword.damage or SWORD_DAMAGE else NON_SWORD_DAMAGE
	attack_entity(player, melee_hit.entity, damage, nil, true)
end

ReplicatedStorage.remotes.melee_swing.OnServerEvent:Connect(on_melee_swing)
