const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const add_cooldown = require(ReplicatedStorage.shared.cooldown.add_cooldown)
const debug_print = require(ReplicatedStorage.client.util.debug_print)
const get_melee_target = require(script.Parent.get_melee_target)
const hit_feedback = require(script.Parent.hit_feedback)
const is_on_cooldown = require(ReplicatedStorage.shared.cooldown.is_on_cooldown)
const MELEE_COOLDOWN = require(ReplicatedStorage.shared.combat.MELEE_COOLDOWN)

const local_player = Players.LocalPlayer

const function attack_melee(): ()
	const melee_target, fail_reason = get_melee_target()
	if melee_target == nil then
		debug_print(fail_reason)
		return
	end

	if is_on_cooldown(local_player, "attack_melee") then
		debug_print("On cooldown.")
		return
	end

	debug_print("Success. Attacking.")

	ReplicatedStorage.remotes.attack_entity:FireServer(melee_target.entity)
	add_cooldown(local_player, "attack_melee", MELEE_COOLDOWN)
	hit_feedback.report(melee_target.distance)
end

return attack_melee
