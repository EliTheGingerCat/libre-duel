const FIRST_PERSON = require(script.Parent.FIRST_PERSON_VIEWMODEL)
const bow_state = require(script.Parent.Parent.tools.bow.bow_state)
const gl_transform = require(script.Parent.first_person.gl_transform)
const first_person_item_transforms = require(script.Parent.first_person.first_person_item_transforms)
const viewmodel_types = require(script.Parent.viewmodel_types)

const function is_using(): boolean
	return bow_state.draw_started ~= nil
end

const function apply_after_hold(transform: gl_transform.gl_transform): ()
	const draw_started = bow_state.draw_started
	if draw_started == nil then
		return
	end
	-- maxUseDuration - (useCount - partialTicks + 1)
	const drawn_ticks = (os.clock() - draw_started) * FIRST_PERSON.ticks_per_second - 1
	first_person_item_transforms.do_bow_transformations(transform, drawn_ticks)
end

const bow_animation: viewmodel_types.use_animation = {
	is_using = is_using,
	apply_after_hold = apply_after_hold,
}

return bow_animation
