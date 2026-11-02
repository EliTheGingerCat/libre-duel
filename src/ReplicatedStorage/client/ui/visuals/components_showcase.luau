local ReplicatedStorage = game:GetService("ReplicatedStorage")

local big_button = require(script.Parent.big_button)
local button = require(script.Parent.button)
local check_box = require(script.Parent.check_box)
local colour_preview = require(script.Parent.colour_preview)
local danger_text = require(script.Parent.danger_text)
local dangerous_button = require(script.Parent.dangerous_button)
local dropdown = require(script.Parent.dropdown)
local hue_slider = require(script.Parent.hue_slider)
local information_text = require(script.Parent.information_text)
local saturation_slider = require(script.Parent.saturation_slider)
local slider = require(script.Parent.slider)
local text_input = require(script.Parent.text_input)
local React = require(ReplicatedStorage.Packages.react)
const KEYBINDS = require(ReplicatedStorage.client.util.KEYBINDS)
local menu_window = require(script.Parent.menu_window)
local switch = require(script.Parent.switch)
local use_if_key_held = require(script.Parent.use_if_key_held)
local value_slider = require(script.Parent.value_slider)
local warning_text = require(script.Parent.warning_text)

local create_element = React.createElement

local function components_showcase()
	local held = use_if_key_held(KEYBINDS.components_showcase)
	local dismissed, set_dismissed = React.useState(false)
	React.useEffect(function()
		set_dismissed(false)
	end, { held })

	local function close(): ()
		set_dismissed(true)
	end

	return create_element(
		menu_window,
		{
			name = "Components Showcase",
			title = "Menu",
			enabled = held and not dismissed,
			on_close = close,
		},
		create_element(
			"CanvasGroup",
			{
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.8, 1),
			},
			create_element("UICorner", {
				CornerRadius = UDim.new(0, 55),
			}),
			create_element(
				"ScrollingFrame",
				{
					AnchorPoint = Vector2.new(0.5, 1),
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0.5, 1),
					Size = UDim2.new(1, -20, 1, -76),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					CanvasSize = UDim2.fromOffset(0, 0),
					ClipsDescendants = true,
					ScrollBarThickness = 0,
				},
				create_element("UIListLayout", {
					SortOrder = "LayoutOrder",
					Padding = UDim.new(0, 20),
				}),
				create_element("UIPadding", {
					PaddingBottom = UDim.new(0, 20),
					PaddingLeft = UDim.new(0, 40),
					PaddingRight = UDim.new(0, 40),
					PaddingTop = UDim.new(0, 12),
				}),
				create_element(information_text),
				create_element(warning_text),
				create_element(danger_text),
				create_element(text_input),
				create_element(slider),
				create_element(hue_slider),
				create_element(saturation_slider),
				create_element(value_slider),
				create_element(colour_preview),
				create_element(button, {
					is_pressed = false,
				}),
				create_element(button, {
					is_pressed = true,
				}),
				create_element(dangerous_button),
				create_element(big_button),
				create_element(check_box, {
					active = false,
					round = false,
					text = "Blud didnt select ts.. 💔",
				}),
				create_element(check_box, {
					active = true,
					round = false,
					text = "Blud selected ts.. 💔",
				}),
				create_element(check_box, {
					active = false,
					round = true,
					text = "Blud didnt select ts.. 💔",
				}),
				create_element(check_box, {
					active = true,
					round = true,
					text = "Blud selected ts.. 💔",
				}),
				create_element(switch, {
					active = true,
				}),
				create_element(switch, {
					active = false,
				}),
				create_element(dropdown)
			)
		)
	)
end

return components_showcase
