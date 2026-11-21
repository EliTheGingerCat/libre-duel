const first_person_item_transforms = require(script.Parent.first_person.first_person_item_transforms)
const sword_state = require(script.Parent.Parent.tools.sword.sword_state)
const viewmodel_types = require(script.Parent.viewmodel_types)

const function is_using(): boolean
	return sword_state.blocking
end

const block_animation: viewmodel_types.use_animation = {
	is_using = is_using,
	apply_after_hold = first_person_item_transforms.do_block_transformations,
}

return block_animation
