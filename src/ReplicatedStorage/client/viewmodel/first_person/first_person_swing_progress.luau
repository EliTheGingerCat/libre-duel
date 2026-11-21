-- EntityLivingBase.swingItem, updateArmSwingProgress and getSwingProgress
const FIRST_PERSON = require(script.Parent.Parent.FIRST_PERSON_VIEWMODEL)
const first_person_tick_clock = require(script.Parent.first_person_tick_clock)

const SWING_DURATION = FIRST_PERSON.swing_duration_ticks

local is_swing_in_progress = false
local swing_progress_int = 0
local swing_progress = 0
local previous_swing_progress = 0

const function swing_item(): ()
	if not is_swing_in_progress or swing_progress_int >= SWING_DURATION / 2 or swing_progress_int < 0 then
		swing_progress_int = -1
		is_swing_in_progress = true
	end
end

const function update_arm_swing_progress(): ()
	previous_swing_progress = swing_progress
	if is_swing_in_progress then
		swing_progress_int += 1
		if swing_progress_int >= SWING_DURATION then
			swing_progress_int = 0
			is_swing_in_progress = false
		end
	else
		swing_progress_int = 0
	end
	swing_progress = swing_progress_int / SWING_DURATION
end

const function get_swing_progress(partial_tick: number): number
	local difference = swing_progress - previous_swing_progress
	if difference < 0 then
		difference += 1
	end
	return previous_swing_progress + difference * partial_tick
end

first_person_tick_clock.on_tick(update_arm_swing_progress)

return {
	swing_item = swing_item,
	get_swing_progress = get_swing_progress,
}
