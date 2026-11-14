const Players = game:GetService("Players")
const RunService = game:GetService("RunService")

const ARROW_FLYBY_CONSTANTS = require(script.Parent.ARROW_FLYBY_CONSTANTS)
const get_flyby_crossing = require(script.Parent.get_flyby_crossing)
const play_sound_local = require(script.Parent.Parent.util.play_sound_local)

const LOCAL_PLAYER = Players.LocalPlayer
const projectiles_folder = workspace:WaitForChild("runtime_instances"):WaitForChild("projectiles")

const last_positions: { [BasePart]: Vector3 } = {}
const already_played: { [BasePart]: true } = {}
local tracked_arrow_count = 0
local heartbeat_connection: RBXScriptConnection? = nil

const function is_own_arrow(arrow: BasePart): boolean
	return arrow:GetAttribute(ARROW_FLYBY_CONSTANTS.SHOOTER_ATTRIBUTE) == LOCAL_PLAYER.UserId
end

const function update_arrow(arrow: BasePart, listener_position: Vector3, delta_time: number): ()
	const previous_position = last_positions[arrow]
	const current_position = arrow.Position
	last_positions[arrow] = current_position

	if already_played[arrow] or is_own_arrow(arrow) then
		return
	end

	const speed = (current_position - previous_position).Magnitude / delta_time
	if speed < ARROW_FLYBY_CONSTANTS.MINIMUM_SPEED then
		return
	end

	const crossing_point =
		get_flyby_crossing(previous_position, current_position, listener_position, ARROW_FLYBY_CONSTANTS.RADIUS)
	if crossing_point == nil then
		return
	end

	already_played[arrow] = true
	play_sound_local(ARROW_FLYBY_CONSTANTS.SOUND_NAME, crossing_point)
end

const function on_heartbeat(delta_time: number): ()
	const camera = workspace.CurrentCamera
	if camera == nil or delta_time <= 0 then
		return
	end

	const listener_position = camera.CFrame.Position
	for arrow in last_positions do
		update_arrow(arrow, listener_position, delta_time)
	end
end

const function on_projectile_added(child: Instance): ()
	if not child:IsA("BasePart") then
		return
	end

	last_positions[child] = child.Position
	tracked_arrow_count += 1

	if heartbeat_connection == nil then
		heartbeat_connection = RunService.Heartbeat:Connect(on_heartbeat)
	end
end

const function on_projectile_removed(child: Instance): ()
	if not child:IsA("BasePart") or not last_positions[child] then
		return
	end

	last_positions[child] = nil
	already_played[child] = nil
	tracked_arrow_count -= 1

	if tracked_arrow_count == 0 and heartbeat_connection then
		heartbeat_connection:Disconnect()
		heartbeat_connection = nil
	end
end

for _, child in projectiles_folder:GetChildren() do
	on_projectile_added(child)
end

projectiles_folder.ChildAdded:Connect(on_projectile_added)
projectiles_folder.ChildRemoved:Connect(on_projectile_removed)
