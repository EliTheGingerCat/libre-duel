local ReplicatedStorage = game:GetService("ReplicatedStorage")

const QUEUE_MODES = require(ReplicatedStorage.shared.queue.QUEUE_MODES)
local React = require(ReplicatedStorage.Packages.react)
local menu_window = require(script.Parent.Parent.visuals.menu_window)
local mode_option = require(script.Parent.mode_option)
local use_mode_selector = require(script.Parent.use_mode_selector)

local create_element = React.createElement

local function mode_selector()
	local state = use_mode_selector()
	local children: { [string]: unknown } = {
		layout = create_element("UIListLayout", { Padding = UDim.new(0, 20), SortOrder = Enum.SortOrder.LayoutOrder }),
	}
	for _, mode in QUEUE_MODES do
		children[mode] = create_element(mode_option, { mode = mode, busy = state.busy, on_join = state.join })
	end
	return create_element(
		menu_window,
		{
			name = "ModeSelector",
			title = "Choose mode",
			enabled = state.enabled,
			on_close = state.close,
		},
		create_element("Frame", {
			Name = "mode_options",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(0.8, -100, 0, 404),
			BackgroundTransparency = 1,
		}, children)
	)
end

return mode_selector
