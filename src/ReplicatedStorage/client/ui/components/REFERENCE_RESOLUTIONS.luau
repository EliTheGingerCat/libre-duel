-- The viewport size each input device's UI is designed for, keyed like input_device.
-- Touch is smaller since phones report points, not pixels, and fingers need bigger targets than a cursor.
-- Devices missing here fall back to keyboard_mouse.
const REFERENCE_RESOLUTIONS = {
	-- full scale UI, used by use_viewport_scale
	full = {
		keyboard_mouse = Vector2.new(1920, 1080),
		touch = Vector2.new(1280, 720),
	},
	-- below this the builtin HUD widgets start shrinking
	shrink = {
		keyboard_mouse = Vector2.new(900, 700),
		touch = Vector2.new(640, 360),
	},
}

const function get_reference_resolution(kind: "full" | "shrink", device: string): Vector2
	const resolutions: { [string]: Vector2 } = REFERENCE_RESOLUTIONS[kind]
	return resolutions[device] or resolutions.keyboard_mouse
end

return get_reference_resolution
