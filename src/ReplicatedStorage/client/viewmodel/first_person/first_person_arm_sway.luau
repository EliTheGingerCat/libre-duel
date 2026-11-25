-- the rendered arm pitch and yaw lag behind the camera, then the item rotates by the difference
const FIRST_PERSON = require(script.Parent.Parent.FIRST_PERSON_VIEWMODEL)
const get_first_person_camera_rotation = require(script.Parent.get_first_person_camera_rotation)
const gl_transform = require(script.Parent.gl_transform)
const first_person_tick_clock = require(script.Parent.first_person_tick_clock)

local render_arm_pitch = 0
local render_arm_yaw = 0
local previous_render_arm_pitch = 0
local previous_render_arm_yaw = 0
local has_started = false

const function update_render_arm(): ()
	const pitch, yaw = get_first_person_camera_rotation()
	if not has_started then
		has_started = true
		render_arm_pitch = pitch
		render_arm_yaw = yaw
	end
	previous_render_arm_pitch = render_arm_pitch
	previous_render_arm_yaw = render_arm_yaw
	render_arm_pitch += (pitch - render_arm_pitch) * FIRST_PERSON.arm_follow
	render_arm_yaw += (yaw - render_arm_yaw) * FIRST_PERSON.arm_follow
end

const function apply_arm_sway(transform: gl_transform.gl_transform, partial_tick: number): ()
	const pitch, yaw = get_first_person_camera_rotation()
	const arm_pitch = previous_render_arm_pitch + (render_arm_pitch - previous_render_arm_pitch) * partial_tick
	const arm_yaw = previous_render_arm_yaw + (render_arm_yaw - previous_render_arm_yaw) * partial_tick
	gl_transform.rotate(transform, (pitch - arm_pitch) * FIRST_PERSON.arm_sway, 1, 0, 0)
	gl_transform.rotate(transform, (yaw - arm_yaw) * FIRST_PERSON.arm_sway, 0, 1, 0)
end

first_person_tick_clock.on_tick(update_render_arm)

return {
	apply = apply_arm_sway,
}
