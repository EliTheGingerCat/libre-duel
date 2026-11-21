-- EntityRenderer.setupViewBobbing with the cameraYaw, cameraPitch and distanceWalkedModified it reads
const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const CUBE_SIZE = require(ReplicatedStorage.shared.cube.CUBE_SIZE)
const gl_transform = require(script.Parent.gl_transform)
const first_person_tick_clock = require(script.Parent.first_person_tick_clock)

const local_player = Players.LocalPlayer

local camera_yaw = 0
local camera_pitch = 0
local previous_camera_yaw = 0
local previous_camera_pitch = 0
local distance_walked = 0
local previous_distance_walked = 0
local last_position: Vector3? = nil

const function get_root_and_grounded(): (BasePart?, boolean)
	const character = local_player.Character
	const humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
	if humanoid == nil or humanoid.RootPart == nil then
		return nil, false
	end
	return humanoid.RootPart, humanoid.FloorMaterial ~= Enum.Material.Air and humanoid.Health > 0
end

const function update_view_bobbing(): ()
	previous_camera_yaw = camera_yaw
	previous_camera_pitch = camera_pitch
	previous_distance_walked = distance_walked

	const root, is_grounded = get_root_and_grounded()
	local motion = Vector3.zero
	if root ~= nil then
		if last_position ~= nil then
			motion = (root.Position - last_position) / CUBE_SIZE
		end
		last_position = root.Position
	else
		last_position = nil
	end

	const horizontal_motion = math.sqrt(motion.X * motion.X + motion.Z * motion.Z)
	distance_walked += horizontal_motion * 0.6

	local yaw_target = math.min(horizontal_motion, 0.1)
	-- radians times 15 is what the source does
	local pitch_target = math.atan(-motion.Y * 0.2) * 15
	if not is_grounded then
		yaw_target = 0
	else
		pitch_target = 0
	end
	camera_yaw += (yaw_target - camera_yaw) * 0.4
	camera_pitch += (pitch_target - camera_pitch) * 0.8
end

const function apply_view_bobbing(transform: gl_transform.gl_transform, partial_tick: number): ()
	const walked = -(distance_walked + (distance_walked - previous_distance_walked) * partial_tick)
	const yaw = previous_camera_yaw + (camera_yaw - previous_camera_yaw) * partial_tick
	const pitch = previous_camera_pitch + (camera_pitch - previous_camera_pitch) * partial_tick
	gl_transform.translate(
		transform,
		math.sin(walked * math.pi) * yaw * 0.5,
		-math.abs(math.cos(walked * math.pi) * yaw),
		0
	)
	gl_transform.rotate(transform, math.sin(walked * math.pi) * yaw * 3, 0, 0, 1)
	gl_transform.rotate(transform, math.abs(math.cos(walked * math.pi - 0.2) * yaw) * 5, 1, 0, 0)
	gl_transform.rotate(transform, pitch, 1, 0, 0)
end

first_person_tick_clock.on_tick(update_view_bobbing)

return {
	apply = apply_view_bobbing,
}
