const FIRST_PERSON = require(script.Parent.FIRST_PERSON_VIEWMODEL)
const cake_state = require(script.Parent.Parent.tools.cake.cake_state)
const gl_transform = require(script.Parent.first_person.gl_transform)
const first_person_item_transforms = require(script.Parent.first_person.first_person_item_transforms)
const viewmodel_types = require(script.Parent.viewmodel_types)

const function is_using(): boolean
	return cake_state.eating and cake_state.eat_started ~= nil
end

const function apply_before_hold(transform: gl_transform.gl_transform): ()
	const started = cake_state.eat_started
	if started == nil then
		return
	end
	const elapsed_ticks = (os.clock() - started) * FIRST_PERSON.ticks_per_second
	const remaining_ticks = math.max(FIRST_PERSON.eat_duration_ticks - elapsed_ticks, 0) + 1
	first_person_item_transforms.perform_drinking(transform, remaining_ticks, FIRST_PERSON.eat_duration_ticks)
end

const eat_animation: viewmodel_types.use_animation = {
	is_using = is_using,
	apply_before_hold = apply_before_hold,
}

return eat_animation
