local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local menu_window = require(script.Parent.Parent.visuals.menu_window)
local mode_option = require(script.Parent.mode_option)
local use_mode_selector = require(script.Parent.use_mode_selector)

local create_element = React.createElement

local function mode_selector()
	local state = use_mode_selector()
	local function join_solo(): ()
		state.join("solo")
	end
	local function join_duo(): ()
		state.join("duo")
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
		}, {
			layout = create_element(
				"UIListLayout",
				{ Padding = UDim.new(0, 20), SortOrder = Enum.SortOrder.LayoutOrder }
			),
			solo = create_element(mode_option, { mode = "solo", busy = state.busy, on_activate = join_solo }),
			duo = create_element(mode_option, { mode = "duo", busy = state.busy, on_activate = join_duo }),
		})
	)
end

return mode_selector
