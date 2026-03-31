local Players = game:GetService("Players")

local sneaking_constants = require(script.Parent.sneaking_constants)
local debug_print = require(script.Parent.Parent.util.debug_print)

local edge_fall_prevention = require(script.Parent.edge_fall_prevention)

local player = Players.LocalPlayer

local sneaking_state: boolean = false
local default_walkspeed: number? = nil

local function set_player_sneak(set_to_state: boolean)

	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	if not default_walkspeed then
		default_walkspeed = humanoid.WalkSpeed
	end

	if sneaking_state == set_to_state then
		debug_print("Sneak state unchanged.")
		return
	end

	sneaking_state = set_to_state

	if sneaking_state then
		humanoid.WalkSpeed = default_walkspeed * sneaking_constants.speed_change
		humanoid.CameraOffset -= Vector3.new(0, sneaking_constants.camera_offset, 0)

		edge_fall_prevention.enable()
	else
		humanoid.WalkSpeed = default_walkspeed
		humanoid.CameraOffset += Vector3.new(0, sneaking_constants.camera_offset, 0)

		edge_fall_prevention.disable()
	end

end

return set_player_sneak
