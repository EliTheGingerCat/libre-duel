-- the item transform functions, in gl units
const gl_transform = require(script.Parent.gl_transform)

type gl_transform = gl_transform.gl_transform

const translate = gl_transform.translate
const rotate = gl_transform.rotate
const scale = gl_transform.scale

const function transform_first_person_item(transform: gl_transform, equip_drop: number, swing_progress: number): ()
	translate(transform, 0.56, -0.52, -0.72)
	translate(transform, 0, equip_drop * -0.6, 0)
	rotate(transform, 45, 0, 1, 0)
	const squared_wave = math.sin(swing_progress * swing_progress * math.pi)
	const root_wave = math.sin(math.sqrt(swing_progress) * math.pi)
	rotate(transform, squared_wave * -20, 0, 1, 0)
	rotate(transform, root_wave * -20, 0, 0, 1)
	rotate(transform, root_wave * -80, 1, 0, 0)
	scale(transform, 0.4)
end

const function do_item_used_transformations(transform: gl_transform, swing_progress: number): ()
	const root = math.sqrt(swing_progress)
	translate(
		transform,
		-0.4 * math.sin(root * math.pi),
		0.2 * math.sin(root * math.pi * 2),
		-0.2 * math.sin(swing_progress * math.pi)
	)
end

const function do_block_transformations(transform: gl_transform): ()
	translate(transform, -0.5, 0.2, 0)
	rotate(transform, 30, 0, 1, 0)
	rotate(transform, -80, 1, 0, 0)
	rotate(transform, 60, 0, 1, 0)
end

-- remaining_ticks is getItemInUseCount - partialTicks + 1
const function perform_drinking(transform: gl_transform, remaining_ticks: number, max_use_ticks: number): ()
	const remaining_fraction = remaining_ticks / max_use_ticks
	local bob = math.abs(math.cos(remaining_ticks / 4 * math.pi) * 0.1)
	if remaining_fraction >= 0.8 then
		bob = 0
	end
	translate(transform, 0, bob, 0)
	const raised = 1 - remaining_fraction ^ 27
	translate(transform, raised * 0.6, raised * -0.5, 0)
	rotate(transform, raised * 90, 0, 1, 0)
	rotate(transform, raised * 10, 1, 0, 0)
	rotate(transform, raised * 30, 0, 0, 1)
end

-- the scale(1, 1, 1 + draw * 0.2) at the end is left out since the transform only holds uniform scale
const function do_bow_transformations(transform: gl_transform, drawn_ticks: number): ()
	rotate(transform, -18, 0, 0, 1)
	rotate(transform, -12, 0, 1, 0)
	rotate(transform, -8, 1, 0, 0)
	translate(transform, -0.9, 0.2, 0)
	local draw = drawn_ticks / 20
	draw = (draw * draw + draw * 2) / 3
	if draw > 1 then
		draw = 1
	end
	if draw > 0.1 then
		const shake = math.sin((drawn_ticks - 0.1) * 1.3) * (draw - 0.1)
		translate(transform, 0, shake * 0.01, 0)
	end
	translate(transform, 0, 0, draw * 0.1)
end

-- the firstperson display transform of item/generated and item/handheld, then RenderItem.renderItem
const function apply_flat_item_model(transform: gl_transform): ()
	translate(transform, 0, 4 / 16, 2 / 16)
	rotate(transform, -135, 0, 1, 0)
	rotate(transform, 25, 0, 0, 1)
	scale(transform, 1.7)
	scale(transform, 0.5)
end

-- 3d items are doubled, then the firstperson transform of block/block
const function apply_block_item_model(transform: gl_transform): ()
	scale(transform, 2)
	rotate(transform, 45, 0, 1, 0)
	scale(transform, 0.4)
	scale(transform, 0.5)
end

return {
	transform_first_person_item = transform_first_person_item,
	do_item_used_transformations = do_item_used_transformations,
	do_block_transformations = do_block_transformations,
	perform_drinking = perform_drinking,
	do_bow_transformations = do_bow_transformations,
	apply_flat_item_model = apply_flat_item_model,
	apply_block_item_model = apply_block_item_model,
}
