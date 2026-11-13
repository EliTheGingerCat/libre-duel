local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local get_nearest_supported_point = require(script.Parent.get_nearest_supported_point)
const SNEAKING_CONSTANTS = require(script.Parent.SNEAKING_CONSTANTS)

local player = Players.LocalPlayer

local edge_fall_prevention = {}

const OVERHANG = SNEAKING_CONSTANTS.overhang
-- How far above or below the feet a surface can be and still count as the floor being stood on.
const STEP_TOLERANCE = 1
-- How far past the overhang limit a floor is still found, so being pushed out a little keeps the limit.
const SEARCH_MARGIN = 2
const SEARCH_SIZE = Vector3.new((OVERHANG + SEARCH_MARGIN) * 2, STEP_TOLERANCE * 2, (OVERHANG + SEARCH_MARGIN) * 2)
const PAD_SIZE = Vector3.new(2, 0.05, 2)

local controls_module: any = nil
local old_move_function: any = nil

local update_connection: RBXScriptConnection? = nil
local cleanup_connection: RBXScriptConnection? = nil
local pad_part: Part? = nil

local floor_query = OverlapParams.new()
floor_query.FilterType = Enum.RaycastFilterType.Exclude
floor_query.RespectCanCollide = true

local pad_ray_check = RaycastParams.new()
pad_ray_check.FilterType = Enum.RaycastFilterType.Include

local cached_char: Model? = nil
local cached_root: BasePart? = nil
local cached_hum: Humanoid? = nil
local is_enabled = false

-- The pad is never a floor, otherwise standing on it would hide the real floor it extends.
const function refresh_floor_filter(): ()
	local ignored: { Instance } = { Workspace.Terrain }
	if cached_char then
		table.insert(ignored, cached_char)
	end
	if pad_part then
		table.insert(ignored, pad_part)
	end
	floor_query.FilterDescendantsInstances = ignored
end

const function update_character_cache(): ()
	local char = player.Character
	if char == cached_char then
		return
	end

	cached_char = char
	if char then
		cached_root = char:FindFirstChild("HumanoidRootPart") :: BasePart?
		cached_hum = char:FindFirstChildOfClass("Humanoid")
	else
		cached_root = nil
		cached_hum = nil
	end
	refresh_floor_filter()
end

-- PlayerModule only exists at runtime, so it cannot be required with the others.
const function require_controls(player_module: Instance): any
	return (require :: any)(player_module):GetControls()
end

const function get_controls(): any
	if controls_module then
		return controls_module
	end

	local player_scripts = player:WaitForChild("PlayerScripts", 5)
	if player_scripts then
		local player_module = player_scripts:WaitForChild("PlayerModule", 5)
		if player_module then
			local success, result = pcall(require_controls, player_module)
			if success then
				controls_module = result
			end
		end
	end

	return controls_module
end

const function is_airborne(hum: Humanoid): boolean
	local state = hum:GetState()
	return hum.FloorMaterial == Enum.Material.Air
		or state == Enum.HumanoidStateType.Freefall
		or state == Enum.HumanoidStateType.Jumping
end

const function get_feet_y(root: BasePart, hum: Humanoid): number
	return root.Position.Y - (root.Size.Y * 0.5) - hum.HipHeight
end

const function get_floor_parts(position: Vector3, feet_y: number): { BasePart }
	return Workspace:GetPartBoundsInBox(CFrame.new(position.X, feet_y, position.Z), SEARCH_SIZE, floor_query)
end

const function is_on_pad(): boolean
	local root, hum = cached_root, cached_hum
	if not (root and hum and hum.Health > 0) then
		return false
	end
	local drop_vec = Vector3.new(0, -(root.Size.Y * 0.5) - hum.HipHeight - 1, 0)
	return Workspace:Raycast(root.Position, drop_vec, pad_ray_check) ~= nil
end

const function update_pad(): ()
	update_character_cache()

	local root, hum, pad = cached_root, cached_hum, pad_part
	if not (root and hum and pad and hum.Health > 0) then
		return
	end

	-- The pad stays where it was during a jump, so jumping in place lands back on it.
	if is_airborne(hum) then
		return
	end

	local position = root.Position
	local feet_y = get_feet_y(root, hum)
	local point =
		get_nearest_supported_point(position, feet_y, get_floor_parts(position, feet_y), OVERHANG, STEP_TOLERANCE)

	-- The pad sits on the nearest allowed point rather than under the player, so being knocked past
	-- the limit still drops them, and losing the floor entirely takes the pad with it.
	if point then
		pad.CFrame = CFrame.new(point.X, point.Y - (PAD_SIZE.Y * 0.5), point.Z)
		pad.Parent = Workspace
	else
		pad.Parent = nil
	end
end

const function get_safe_direction(vec: Vector3): Vector3
	local root, hum = cached_root, cached_hum
	if not (root and hum and hum.Health > 0) or vec.Magnitude == 0 or is_airborne(hum) then
		return vec
	end

	local look_ahead = (hum.WalkSpeed / 60) * 1.5
	if look_ahead <= 0 then
		return vec
	end

	local position = root.Position
	local feet_y = get_feet_y(root, hum)
	local parts = get_floor_parts(position, feet_y)

	-- Measuring from the nearest allowed point instead of the real position means stopping a little
	-- past the limit neither pulls the player back nor blocks sliding along the edge.
	local base = get_nearest_supported_point(position, feet_y, parts, OVERHANG, STEP_TOLERANCE)
	if not base then
		return vec
	end

	local flat_vec = Vector3.new(vec.X, 0, vec.Z)
	local target = get_nearest_supported_point(base + (flat_vec * look_ahead), feet_y, parts, OVERHANG, STEP_TOLERANCE)
	if not target then
		return vec
	end

	local allowed = Vector3.new(target.X - base.X, 0, target.Z - base.Z) / look_ahead
	if allowed:FuzzyEq(flat_vec, 1e-3) then
		return vec
	end
	return allowed
end

const function move_with_edge_check(self: any, vec: Vector3, face: boolean): ()
	old_move_function(self, get_safe_direction(vec), face)
end

const function destroy_pad(): ()
	if pad_part then
		pad_part:Destroy()
		pad_part = nil
	end
end

const function wait_until_off_pad(): ()
	update_character_cache()
	if is_on_pad() then
		return
	end
	if cleanup_connection then
		cleanup_connection:Disconnect()
		cleanup_connection = nil
	end
	destroy_pad()
end

function edge_fall_prevention.enable()
	if is_enabled then
		return
	end
	is_enabled = true

	if cleanup_connection then
		cleanup_connection:Disconnect()
		cleanup_connection = nil
	end

	local controls = get_controls()
	if not controls or old_move_function then
		return
	end

	if not pad_part then
		local pad = Instance.new("Part")
		pad.Name = "sneak_overhang"
		pad.Size = PAD_SIZE
		pad.Anchored = true
		pad.CanCollide = true
		pad.Transparency = 1
		pad.CastShadow = false
		pad.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0, 0, 0, 0) --Density has to be 0.0001 so roblox stops crying in the console...
		pad_part = pad

		pad_ray_check.FilterDescendantsInstances = { pad }
		refresh_floor_filter()
	end

	update_connection = RunService.Heartbeat:Connect(update_pad)

	old_move_function = controls.moveFunction
	controls.moveFunction = move_with_edge_check
end

function edge_fall_prevention.disable()
	if not is_enabled then
		return
	end
	is_enabled = false

	if update_connection then
		update_connection:Disconnect()
		update_connection = nil
	end

	local controls = get_controls()
	if controls and old_move_function then
		controls.moveFunction = old_move_function
		old_move_function = nil
	end

	if pad_part then
		update_character_cache()
		if is_on_pad() then
			cleanup_connection = RunService.Heartbeat:Connect(wait_until_off_pad)
		else
			destroy_pad()
		end
	end
end

return edge_fall_prevention
