local Players = game:GetService("Players")

const SNEAKING_CONSTANTS = require(script.Parent.SNEAKING_CONSTANTS)
local debug_print = require(script.Parent.Parent.util.debug_print)

local edge_fall_prevention = require(script.Parent.edge_fall_prevention)
const walkspeed = require(script.Parent.Parent.util.walkspeed)

local player = Players.LocalPlayer

local sneaking_state: boolean = false

const function set_player_sneak(set_to_state: boolean)
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	if sneaking_state == set_to_state then
		debug_print("Sneak state unchanged.")
		return
	end

	sneaking_state = set_to_state

	if sneaking_state then
		walkspeed.set_modifier("sneak", SNEAKING_CONSTANTS.speed_change)
		humanoid.CameraOffset -= Vector3.new(0, SNEAKING_CONSTANTS.camera_offset, 0)

		edge_fall_prevention.enable()
	else
		walkspeed.set_modifier("sneak", nil)
		humanoid.CameraOffset += Vector3.new(0, SNEAKING_CONSTANTS.camera_offset, 0)

		edge_fall_prevention.disable()
	end
end

return set_player_sneak
