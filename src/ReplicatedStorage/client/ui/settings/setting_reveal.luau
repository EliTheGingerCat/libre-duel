local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local setting_row = require(script.Parent.setting_row)
local settings_registry = require(script.Parent.settings_registry)
local use_ui_motion = require(script.Parent.Parent.visuals.use_ui_motion)

local create_element = React.createElement
-- Part of each row instead of a list layout's padding, so the gap collapses with the row.
const ROW_GAP = 20
const NESTED_GAP = 8

local function get_scale(instance: Instance): number
	local factor = 1
	local current: Instance? = instance
	while current and not current:IsA("LayerCollector") do
		local scale = current:FindFirstChildOfClass("UIScale")
		if scale then
			factor *= scale.Scale
		end
		current = current.Parent
	end
	return factor
end

local function setting_reveal(props: {
	entry: settings_registry.entry,
	order: number,
	shown: boolean,
	nested: boolean?,
})
	local motion = use_ui_motion(if props.shown then 1 else 0)
	local gap = if props.nested then NESTED_GAP else ROW_GAP
	local height, set_height = React.useBinding(0)
	local content_ref = React.useRef(nil :: GuiObject?)
	local function measure(content: GuiObject): ()
		set_height(content.AbsoluteSize.Y / math.max(0.001, get_scale(content)))
	end
	local function measure_on_mount(): ()
		if content_ref.current then
			measure(content_ref.current)
		end
	end
	React.useLayoutEffect(measure_on_mount, {})
	local function row_size(values: { motion: number, height: number }): UDim2
		return UDim2.new(1, 0, 0, (values.height + gap) * values.motion)
	end
	local function is_visible(value: number): boolean
		return value > 0.001
	end
	local function is_clipped(value: number): boolean
		return value < 0.999
	end
	local function transparency(value: number): number
		return 1 - value
	end
	local fades = props.entry.visible ~= nil
	local nested_rows = nil
	for index, child in settings_registry.get_children(props.entry.id) do
		nested_rows = nested_rows or {}
		nested_rows[child.id] = create_element(
			setting_reveal,
			{ entry = child, order = index, shown = settings_registry.is_visible(child), nested = true }
		)
	end
	return create_element("Frame", {
		Name = props.entry.id,
		LayoutOrder = props.order,
		BackgroundTransparency = 1,
		Size = React.joinBindings({ motion = motion, height = height }):map(row_size),
		Visible = motion:map(is_visible),
		ClipsDescendants = motion:map(is_clipped),
	}, {
		content = create_element(if fades then "CanvasGroup" else "Frame", {
			ref = content_ref,
			Position = UDim2.fromOffset(0, if props.nested then NESTED_GAP else 0),
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			GroupTransparency = if fades then motion:map(transparency) else nil,
			[React.Change.AbsoluteSize] = measure,
		}, {
			row = create_element(setting_row, { entry = props.entry, order = props.order, children = nested_rows }),
		}),
	})
end

return setting_reveal
