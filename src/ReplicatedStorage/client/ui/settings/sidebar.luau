local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local category_button = require(script.Parent.category_button)
local settings_registry = require(script.Parent.settings_registry)
local text_input = require(script.Parent.Parent.visuals.text_input)

local function sidebar(
	props: { selected: string, query: string, on_selected: (string) -> (), on_search: (string) -> () }
)
	local buttons = {
		padding = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 20),
			PaddingRight = UDim.new(0, 20),
			PaddingTop = UDim.new(0, 20),
			PaddingBottom = UDim.new(0, 20),
		}),
		layout = React.createElement(
			"UIListLayout",
			{ Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }
		),
	}
	local bottom = {}
	for index, category in settings_registry.categories do
		local target = if category.bottom then bottom else buttons
		target[category.id] = React.createElement("Frame", {
			LayoutOrder = index,
			Size = UDim2.new(1, 0, 0, 50),
			BackgroundTransparency = 1,
		}, {
			button = React.createElement(
				category_button,
				{ category = category, selected = props.selected == category.id, on_selected = props.on_selected }
			),
		})
	end
	return React.createElement("Frame", {
		Position = UDim2.fromOffset(20, 20),
		Size = UDim2.new(0.25, -20, 1, -40),
		BackgroundColor3 = Color3.new(17 / 255, 17 / 255, 17 / 255),
		BackgroundTransparency = 0.5,
	}, {
		corner = React.createElement("UICorner", { CornerRadius = UDim.new(0, 40) }),
		shadow = React.createElement(
			"UIShadow",
			{ BlurRadius = UDim.new(0, 8), Transparency = 0.3, ShowBehindParent = false }
		),
		search = React.createElement("Frame", {
			Position = UDim2.fromOffset(20, 20),
			Size = UDim2.new(1, -40, 0, 50),
			BackgroundTransparency = 1,
		}, {
			input = React.createElement(text_input, {
				text = props.query,
				placeholder = "Search...",
				icon = "rbxassetid://113215135352721",
				on_changed = props.on_search,
			}),
		}),
		categories = React.createElement("ScrollingFrame", {
			Position = UDim2.fromOffset(0, 70),
			Size = UDim2.new(1, 0, 1, -140),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 0,
			CanvasSize = UDim2.fromOffset(0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
		}, buttons),
		bottom = React.createElement("Frame", {
			Position = UDim2.new(0, 20, 1, -70),
			Size = UDim2.new(1, -40, 0, 50),
			BackgroundTransparency = 1,
		}, bottom),
	})
end

return sidebar
