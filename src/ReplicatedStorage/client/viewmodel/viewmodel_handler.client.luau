const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")
const Workspace = game:GetService("Workspace")

const get_slot_tool = require(script.Parent.Parent.tools.get_slot_tool)
const get_viewmodel_style = require(script.Parent.get_viewmodel_style)
const get_zoom_transparency = require(script.Parent.get_zoom_transparency)
const swing_animation = require(script.Parent.swing_animation)
const tool_state = require(script.Parent.Parent.tools.tool_state)
const tool_types = require(ReplicatedStorage.shared.tools.tool_types)
const update_bob = require(script.Parent.update_bob)
const viewmodel_types = require(script.Parent.viewmodel_types)
const VIEWMODEL_CONSTANTS = require(script.Parent.VIEWMODEL_CONSTANTS)

const CurrentCamera = Workspace.CurrentCamera

local current_tool: tool_types.tool? = nil
local current_style: viewmodel_types.style? = nil

const function on_tool_change(slot: number): ()
	const tool = get_slot_tool(slot)
	const style = if tool ~= nil then get_viewmodel_style(tool) else nil

	if current_style ~= nil and (style == nil or style.display ~= current_style.display) then
		current_style.display.hide()
	end

	current_tool = tool
	current_style = style
	if tool ~= nil and style ~= nil then
		style.display.show(tool)
	end
end

const function on_tool_used(): ()
	if current_style ~= nil and current_style.swings_on_use then
		swing_animation.play()
	end
end

const function on_render_stepped(delta_time: number): ()
	const bob_offset = update_bob(delta_time)

	if current_style == nil or current_tool == nil then
		return
	end

	const display = current_style.display
	if display.update ~= nil then
		display.update(current_tool)
	end

	const part = display.get_part()
	if part == nil then
		return
	end
	display.set_transparency(get_zoom_transparency())

	const use_animation = current_style.use_animation
	const use_offset = if use_animation ~= nil then use_animation.get_offset(delta_time) else CFrame.identity
	part.CFrame = CurrentCamera.CFrame
		* VIEWMODEL_CONSTANTS.offset
		* bob_offset
		* use_offset
		* swing_animation.get_offset()
		* VIEWMODEL_CONSTANTS.item_rotation
end

tool_state.on_change:Connect(on_tool_change)
tool_state.on_attack:Connect(swing_animation.play)
tool_state.on_use:Connect(on_tool_used)
RunService.RenderStepped:Connect(on_render_stepped)

-- tools.client may have already selected the first slot before this connected
on_tool_change(tool_state.current)
