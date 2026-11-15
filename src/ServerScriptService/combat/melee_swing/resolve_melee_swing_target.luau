const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const AIM_VALIDATION_CONSTANTS = require(ServerScriptService.aim_validation.AIM_VALIDATION_CONSTANTS)
const debug_print = require(ServerScriptService.util.debug_print)
const get_ray_box_hit_distance = require(ReplicatedStorage.shared.geometry.get_ray_box_hit_distance)
const get_reach = require(ServerScriptService.aim_validation.get_reach)
const get_rewound_root_cframe = require(ServerScriptService.combat.lag_compensation.get_rewound_root_cframe)
const is_aim_line_of_sight_clear = require(ServerScriptService.aim_validation.is_aim_line_of_sight_clear)
const registry = require(ReplicatedStorage.shared.entity.registry)
const sanitise_render_times = require(script.Parent.sanitise_render_times)
const validate_aim_ray = require(ServerScriptService.aim_validation.validate_aim_ray)

export type melee_hit = {
	entity: registry.entity,
	hit_position: Vector3,
}

type candidate = {
	entity: registry.entity,
	ray_distance: number,
}

const function get_root(character: Model): BasePart?
	const root = character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return root
	end
	return nil
end

const function get_hitbox(root: BasePart): BasePart?
	const hitbox = root:FindFirstChild("hitbox")
	if hitbox and hitbox:IsA("BasePart") then
		return hitbox
	end
	return nil
end

-- read from the weld rather than the part, so it can be placed on a rewound root
-- the weld has the hitbox as Part0 and the root as Part1
const function get_hitbox_offset(hitbox: BasePart): CFrame?
	const weld = hitbox:FindFirstChildOfClass("Weld")
	if weld == nil then
		return nil
	end
	return weld.C1 * weld.C0:Inverse()
end

-- bots aren't owned by a client, so they're checked where the server has them
const function get_target_root_cframe(
	attacker: Player,
	target: registry.entity,
	root: BasePart,
	render_times: sanitise_render_times.render_times
): CFrame
	if type(target) == "string" then
		return root.CFrame
	end
	const rewound_root_cframe = get_rewound_root_cframe(attacker, target, render_times[target])
	if rewound_root_cframe == nil then
		debug_print("No render time or history for", target, "so it isn't rewound.")
		return root.CFrame
	end
	return rewound_root_cframe
end

-- casts the attacker's aim against every hitbox as the attacker saw it, then checks reach and walls from their eyes
const function resolve_melee_swing_target(
	attacker: Player,
	aim: validate_aim_ray.validated_aim,
	render_times: sanitise_render_times.render_times
): melee_hit?
	local closest_candidate: candidate? = nil

	for _, entity in registry.get_all() do
		if entity == attacker then
			continue
		end
		const character = registry.get_character(entity)
		const root = if character then get_root(character) else nil
		const hitbox = if root then get_hitbox(root) else nil
		const hitbox_offset = if hitbox then get_hitbox_offset(hitbox) else nil
		if root == nil or hitbox == nil or hitbox_offset == nil then
			continue
		end

		const hitbox_cframe = get_target_root_cframe(attacker, entity, root, render_times) * hitbox_offset
		const ray_distance = get_ray_box_hit_distance(
			aim.origin,
			aim.direction,
			AIM_VALIDATION_CONSTANTS.maximum_ray_distance,
			hitbox_cframe,
			hitbox.Size
		)
		if ray_distance and (closest_candidate == nil or ray_distance < closest_candidate.ray_distance) then
			closest_candidate = { entity = entity, ray_distance = ray_distance }
		end
	end

	if closest_candidate == nil then
		debug_print("Aim ray missed every hitbox.")
		return nil
	end

	const hit_position = aim.origin + aim.direction * closest_candidate.ray_distance
	const reach, is_in_reach = get_reach(aim, hit_position)
	if not is_in_reach then
		debug_print("Too far:", reach)
		return nil
	end

	if not is_aim_line_of_sight_clear(aim, hit_position) then
		debug_print("Hit is behind a wall.")
		return nil
	end

	debug_print("Hit at reach:", reach)
	return { entity = closest_candidate.entity, hit_position = hit_position }
end

return resolve_melee_swing_target
