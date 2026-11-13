local Players = game:GetService("Players")

const SNEAKING_CONSTANTS = require(script.Parent.SNEAKING_CONSTANTS)
local debug_print = require(script.Parent.Parent.util.debug_print)

local edge_fall_prevention = require(script.Parent.edge_fall_prevention)
const walkspeed = require(script.Parent.Parent.util.walkspeed)

local player = Players.LocalPlayer

const SNEAK_CAMERA_OFFSET = Vector3.new(0, SNEAKING_CONSTANTS.camera_offset, 0)

local sneaking_state: boolean = false

const function get_humanoid(): Humanoid?
	const character = player.Character
	if character == nil then
		return nil
	end
	return character:FindFirstChildOfClass("Humanoid")
end

const function set_player_sneak(set_to_state: boolean)
	if sneaking_state == set_to_state then
		debug_print("Sneak state unchanged.")
		return
	end

	sneaking_state = set_to_state

	-- the state still has to flip without a character, otherwise releasing while dead leaves it stuck on
	const humanoid = get_humanoid()

	if sneaking_state then
		walkspeed.set_modifier("sneak", SNEAKING_CONSTANTS.speed_change)
		if humanoid then
			humanoid.CameraOffset -= SNEAK_CAMERA_OFFSET
		end

		edge_fall_prevention.enable()
	else
		walkspeed.set_modifier("sneak", nil)
		if humanoid then
			humanoid.CameraOffset += SNEAK_CAMERA_OFFSET
		end

		edge_fall_prevention.disable()
	end
end

-- this module outlives the character, so a respawn mid sneak needs the new humanoid lowered too
const function on_character_added(character: Model): ()
	const humanoid = character:WaitForChild("Humanoid") :: Humanoid
	if sneaking_state then
		humanoid.CameraOffset -= SNEAK_CAMERA_OFFSET
	end
end

player.CharacterAdded:Connect(on_character_added)

return set_player_sneak
