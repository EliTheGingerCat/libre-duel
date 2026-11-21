const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")
const Workspace = game:GetService("Workspace")

const FIRST_PERSON = require(script.Parent.FIRST_PERSON_VIEWMODEL)
const get_slot_tool = require(script.Parent.Parent.tools.get_slot_tool)
const get_viewmodel_style = require(script.Parent.get_viewmodel_style)
const get_zoom_transparency = require(script.Parent.get_zoom_transparency)
const gl_transform = require(script.Parent.first_person.gl_transform)
const first_person_arm_sway = require(script.Parent.first_person.first_person_arm_sway)
const first_person_equip_progress = require(script.Parent.first_person.first_person_equip_progress)
const first_person_item_transforms = require(script.Parent.first_person.first_person_item_transforms)
const first_person_swing_progress = require(script.Parent.first_person.first_person_swing_progress)
const first_person_tick_clock = require(script.Parent.first_person.first_person_tick_clock)
const first_person_view_bobbing = require(script.Parent.first_person.first_person_view_bobbing)
const tool_state = require(script.Parent.Parent.tools.tool_state)
const tool_types = require(ReplicatedStorage.shared.tools.tool_types)
const viewmodel_types = require(script.Parent.viewmodel_types)

-- the held tool decides swinging, the rendered one lags behind it until the equip animation swaps them
local held_style: viewmodel_types.style? = nil
local rendered_tool: tool_types.tool? = nil
local rendered_style: viewmodel_types.style? = nil

const function on_tool_change(slot: number): ()
	const tool = get_slot_tool(slot)
	held_style = if tool ~= nil then get_viewmodel_style(tool) else nil
	first_person_equip_progress.set_held_tool(tool)
end

const function on_attack(): ()
	first_person_swing_progress.swing_item()
end

const function on_tool_used(): ()
	if held_style ~= nil and held_style.swings_on_use then
		first_person_swing_progress.swing_item()
	end
end

const function sync_rendered_tool(): ()
	const tool = first_person_equip_progress.get_tool_to_render()
	if tool == rendered_tool then
		return
	end
	const style = if tool ~= nil then get_viewmodel_style(tool) else nil
	if rendered_style ~= nil then
		rendered_style.display.hide()
	end
	rendered_tool = tool
	rendered_style = style
	if tool ~= nil and style ~= nil then
		style.display.show(tool)
	end
end

-- the first person item transform
const function build_item_transform(style: viewmodel_types.style, partial_tick: number): gl_transform.gl_transform
	const transform = gl_transform.new()
	first_person_view_bobbing.apply(transform, partial_tick)
	first_person_arm_sway.apply(transform, partial_tick)

	const equip_drop = first_person_equip_progress.get_equip_drop(partial_tick)
	const use_animation = style.use_animation
	if use_animation ~= nil and use_animation.is_using() then
		if use_animation.apply_before_hold ~= nil then
			use_animation.apply_before_hold(transform)
		end
		first_person_item_transforms.transform_first_person_item(transform, equip_drop, 0)
		if use_animation.apply_after_hold ~= nil then
			use_animation.apply_after_hold(transform)
		end
	else
		const swing_progress = first_person_swing_progress.get_swing_progress(partial_tick)
		first_person_item_transforms.do_item_used_transformations(transform, swing_progress)
		first_person_item_transforms.transform_first_person_item(transform, equip_drop, swing_progress)
	end

	if style.is_block_model then
		first_person_item_transforms.apply_block_item_model(transform)
	else
		first_person_item_transforms.apply_flat_item_model(transform)
	end
	return transform
end

const function on_render_stepped(): ()
	const partial_tick = first_person_tick_clock.advance()
	sync_rendered_tool()

	const camera = Workspace.CurrentCamera
	const tool = rendered_tool
	const style = rendered_style
	if camera == nil or tool == nil or style == nil then
		return
	end

	const display = style.display
	if display.update ~= nil then
		display.update(tool)
	end
	display.set_transparency(get_zoom_transparency())

	const transform = build_item_transform(style, partial_tick)
	-- scaling everything about the eye makes the camera's fov draw the hand like the fixed 70 degree one
	const projection = math.tan(math.rad(camera.FieldOfView) / 2) / math.tan(math.rad(FIRST_PERSON.reference_fov) / 2)
	const studs_per_unit = FIRST_PERSON.unit * projection
	const cframe = camera.CFrame * CFrame.new(transform.cframe.Position * studs_per_unit) * transform.cframe.Rotation
	display.set_pose(cframe, transform.scale * studs_per_unit)
end

tool_state.on_change:Connect(on_tool_change)
tool_state.on_attack:Connect(on_attack)
tool_state.on_use:Connect(on_tool_used)
RunService.RenderStepped:Connect(on_render_stepped)

-- tools.client may have already selected the first slot before this connected
on_tool_change(tool_state.current)
