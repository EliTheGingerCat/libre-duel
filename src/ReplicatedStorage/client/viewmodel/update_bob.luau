const get_grounded_speed = require(script.Parent.get_grounded_speed)
const VIEWMODEL_CONSTANTS = require(script.Parent.VIEWMODEL_CONSTANTS)

const TWO_PI = 2 * math.pi

local bob_phase = 0
local bob_strength = 0

const function update_bob(delta_time: number): CFrame
	const speed = get_grounded_speed()
	const target_strength = math.min(speed / VIEWMODEL_CONSTANTS.bob_full_speed, 1)

	bob_phase = (bob_phase + speed * VIEWMODEL_CONSTANTS.bob_radians_per_stud * delta_time) % TWO_PI
	bob_strength += (target_strength - bob_strength) * (1 - math.exp(-VIEWMODEL_CONSTANTS.bob_smoothing * delta_time))

	-- sin(2x) dips twice per side-to-side sway, tracing a figure of eight
	return CFrame.new(
		math.sin(bob_phase) * VIEWMODEL_CONSTANTS.bob_sideways * bob_strength,
		math.sin(2 * bob_phase) * VIEWMODEL_CONSTANTS.bob_vertical * bob_strength,
		0
	)
end

return update_bob
