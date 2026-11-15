const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")
const Workspace = game:GetService("Workspace")

const debug_print = require(ServerScriptService.util.debug_print)
const ENTITY_RANGE = require(ReplicatedStorage.shared.combat.ENTITY_RANGE)
const get_ray_box_hit_distance = require(ReplicatedStorage.shared.geometry.get_ray_box_hit_distance)
const get_rewound_root_cframe = require(ServerScriptService.combat.lag_compensation.get_rewound_root_cframe)
const MELEE_SWING_CONSTANTS = require(script.Parent.MELEE_SWING_CONSTANTS)
const registry = require(ReplicatedStorage.shared.entity.registry)
const sanitise_render_times = require(script.Parent.sanitise_render_times)

-- nothing past this along the aim ray can be in reach, even from a zoomed out camera
const MAXIMUM_RAY_DISTANCE = MELEE_SWING_CONSTANTS.maximum_origin_offset + ENTITY_RANGE * 2

export type melee_hit = {
	entity: registry.entity,
	hit_position: Vector3,
}

type candidate = {
	entity: registry.entity,
	ray_distance: number,
}

const occlusion_parameters = RaycastParams.new()
occlusion_parameters.FilterType = Enum.RaycastFilterType.Exclude
occlusion_parameters.CollisionGroup = "hitbox"

const function is_finite_vector(vector: Vector3): boolean
	const sum = vector.X + vector.Y + vector.Z
	return sum == sum and math.abs(sum) ~= math.huge
end

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

const function is_path_clear(from: Vector3, to: Vector3): boolean
	return Workspace:Raycast(from, to - from, occlusion_parameters) == nil
end

-- casts the attacker's aim against every hitbox as the attacker saw it, then checks reach and walls from their eyes
const function resolve_melee_swing_target(
	attacker: Player,
	origin: Vector3,
	direction: Vector3,
	render_times: sanitise_render_times.render_times
): melee_hit?
	if not is_finite_vector(origin) or not is_finite_vector(direction) or direction.Magnitude < 1e-3 then
		debug_print("Invalid aim ray.")
		return nil
	end

	const attacker_character = attacker.Character
	const attacker_root = if attacker_character then get_root(attacker_character) else nil
	if attacker_root == nil then
		debug_print("Attacker root is missing.")
		return nil
	end
	const origin_offset = (origin - attacker_root.Position).Magnitude
	if origin_offset > MELEE_SWING_CONSTANTS.maximum_origin_offset then
		debug_print("Aim origin too far from attacker:", origin_offset)
		return nil
	end

	const unit_direction = direction.Unit
	const characters: { Instance } = {}
	local closest_candidate: candidate? = nil

	for _, entity in registry.get_all() do
		const character = registry.get_character(entity)
		if character == nil then
			continue
		end
		table.insert(characters, character)
		if entity == attacker then
			continue
		end

		const root = get_root(character)
		const hitbox = if root then get_hitbox(root) else nil
		const hitbox_offset = if hitbox then get_hitbox_offset(hitbox) else nil
		if root == nil or hitbox == nil or hitbox_offset == nil then
			continue
		end

		const hitbox_cframe = get_target_root_cframe(attacker, entity, root, render_times) * hitbox_offset
		const ray_distance =
			get_ray_box_hit_distance(origin, unit_direction, MAXIMUM_RAY_DISTANCE, hitbox_cframe, hitbox.Size)
		if ray_distance and (closest_candidate == nil or ray_distance < closest_candidate.ray_distance) then
			closest_candidate = { entity = entity, ray_distance = ray_distance }
		end
	end

	if closest_candidate == nil then
		debug_print("Aim ray missed every hitbox.")
		return nil
	end

	const hit_position = origin + unit_direction * closest_candidate.ray_distance
	const eye_position = attacker_root.Position + MELEE_SWING_CONSTANTS.eye_offset
	const reach = (hit_position - eye_position).Magnitude
	if reach > ENTITY_RANGE + MELEE_SWING_CONSTANTS.reach_tolerance then
		debug_print("Too far:", reach)
		return nil
	end

	-- both, so a spoofed origin can't be used to swing through a wall
	occlusion_parameters.FilterDescendantsInstances = characters
	if not is_path_clear(origin, hit_position) or not is_path_clear(eye_position, hit_position) then
		debug_print("Hit is behind a wall.")
		return nil
	end

	debug_print("Hit at reach:", reach)
	return { entity = closest_candidate.entity, hit_position = hit_position }
end

return resolve_melee_swing_target
