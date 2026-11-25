const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const add_cooldown = require(ReplicatedStorage.shared.cooldown.add_cooldown)
const debug_print = require(ReplicatedStorage.client.util.debug_print)
const get_melee_ray = require(script.Parent.get_melee_ray)
const get_melee_target = require(script.Parent.get_melee_target)
const get_target_render_times = require(script.Parent.lag_compensation.get_target_render_times)
const hit_feedback = require(script.Parent.hit_feedback)
const is_on_cooldown = require(ReplicatedStorage.shared.cooldown.is_on_cooldown)
const MELEE_COOLDOWN = require(ReplicatedStorage.shared.combat.MELEE_COOLDOWN)
const zap_client_network = require(ReplicatedStorage.client.network.zap_client_network)

const local_player = Players.LocalPlayer

const function attack_melee(): ()
	if is_on_cooldown(local_player, "attack_melee") then
		debug_print("On cooldown.")
		return
	end

	-- every swing goes to the server, which decides what it hit
	const melee_ray = get_melee_ray()
	zap_client_network.melee_swing.fire({
		origin = melee_ray.Origin,
		direction = melee_ray.Direction,
		render_times = get_target_render_times(),
	})

	-- the local guess only drives instant feedback and the client side cooldown
	const melee_target, fail_reason = get_melee_target()
	if melee_target == nil then
		debug_print(fail_reason)
		return
	end

	debug_print("Predicted hit.")
	add_cooldown(local_player, "attack_melee", MELEE_COOLDOWN)
	hit_feedback.report(melee_target.distance)
end

return attack_melee
