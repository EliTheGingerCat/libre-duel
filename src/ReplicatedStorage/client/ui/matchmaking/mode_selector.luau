const GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

const MODE_DEFINITIONS = require(ReplicatedStorage.shared.modes.MODE_DEFINITIONS)
local React = require(ReplicatedStorage.Packages.react)
local menu_window = require(script.Parent.Parent.visuals.menu_window)
local mode_option = require(script.Parent.mode_option)
local use_mode_selector = require(script.Parent.use_mode_selector)
const input_device = require(ReplicatedStorage.client.util.input_device)

local create_element = React.createElement

const function mode_selector()
	local state = use_mode_selector()
	const mode_options_ref = React.useRef(nil :: Frame?)

	-- a gamepad has no cursor to reach the options with, so it starts on the first one
	const function focus_first_mode_option(): (() -> ())?
		const mode_options = mode_options_ref.current
		if not state.enabled or mode_options == nil then
			return nil
		end
		if input_device.current == "gamepad" then
			const first_mode_option = mode_options:FindFirstChild(`{MODE_DEFINITIONS[1].id}_button`, true)
			if first_mode_option ~= nil and first_mode_option:IsA("GuiObject") then
				GuiService.SelectedObject = first_mode_option
			end
		end

		const function release_focus(): ()
			const selected_object = GuiService.SelectedObject
			if selected_object ~= nil and selected_object:IsDescendantOf(mode_options) then
				GuiService.SelectedObject = nil
			end
		end

		return release_focus
	end
	React.useEffect(focus_first_mode_option, { state.enabled })
	local children: { [string]: unknown } = {
		layout = create_element("UIListLayout", { Padding = UDim.new(0, 20), SortOrder = Enum.SortOrder.LayoutOrder }),
	}
	for index, definition in MODE_DEFINITIONS do
		children[definition.id] = create_element(
			mode_option,
			{ mode = definition.id, layout_order = index, busy = state.busy, on_join = state.join }
		)
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
			ref = mode_options_ref,
			Name = "mode_options",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(0.8, -100, 0, 404),
			BackgroundTransparency = 1,
		}, children)
	)
end

return mode_selector
