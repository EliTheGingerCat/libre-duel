local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local animated_button = require(script.Parent.animated_button)
local button_motion = require(script.Parent.button_motion)
local surface = require(script.Parent.controls.surface)
local use_ui_motion = require(script.Parent.use_ui_motion)

local DEFAULT_OPTIONS: { { text: string, colour: Color3? } } = {
	{ text = "Red", colour = Color3.new(177 / 255, 76 / 255, 78 / 255) },
	{ text = "Blue", colour = Color3.new(13 / 255, 162 / 255, 221 / 255) },
	{ text = "Spectator", colour = Color3.new(1, 1, 1) },
}

local function dropdown(props: {
	value: string?,
	options: { { text: string, colour: Color3? } }?,
	on_changed: ((string) -> ())?,
})
	local expanded, set_expanded = React.useState(false)
	local stored, set_stored = React.useState(props.value or "Red")
	local value = if props.on_changed then props.value else stored
	local options: { { text: string, colour: Color3? } } = props.options or DEFAULT_OPTIONS
	local motion = use_ui_motion(if expanded then 1 else 0)
	local function size(amount: number): UDim2
		return UDim2.fromOffset(200, 40 + #options * 40 * amount)
	end
	local function rotation(amount: number): number
		return amount * 180
	end
	local function toggle(): ()
		set_expanded(not expanded)
	end
	local children = {
		surface = React.createElement(surface, { radius = 20 }),
		motion = React.createElement(button_motion),
	}
	local selected_colour = Color3.new(1, 1, 1)
	for index, option in ipairs(options) do
		if option.text == value then
			selected_colour = option.colour or selected_colour
		end
		local function choose(): ()
			if props.on_changed then
				props.on_changed(option.text)
			else
				set_stored(option.text)
			end
			set_expanded(false)
		end
		children["option_" .. index] = React.createElement(animated_button, {
			Name = option.text,
			Position = UDim2.fromOffset(0, index * 40),
			Size = UDim2.fromOffset(200, 40),
			Visible = expanded,
			BackgroundTransparency = 1,
			Text = option.text,
			TextColor3 = option.colour or Color3.new(1, 1, 1),
			TextSize = 32,
			FontFace = Font.fromId(11702779409),
			[React.Event.Activated] = choose,
		}, { motion = React.createElement(button_motion) })
	end
	children.title = React.createElement("TextLabel", {
		Size = UDim2.fromOffset(200, 40),
		BackgroundTransparency = 1,
		Text = value or "",
		TextColor3 = selected_colour,
		TextSize = 32,
		FontFace = Font.fromId(11702779409, Enum.FontWeight.Bold),
	})
	children.arrow = React.createElement("ImageLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.fromOffset(42, 42),
		BackgroundTransparency = 1,
		Image = "rbxassetid://85332232207991",
		Rotation = motion:map(rotation),
	})
	return React.createElement(animated_button, {
		Name = "dropdown",
		Size = motion:map(size),
		BackgroundColor3 = Color3.new(17 / 255, 17 / 255, 17 / 255),
		BackgroundTransparency = 0.5,
		Text = "",
		[React.Event.Activated] = toggle,
	}, children)
end

return dropdown
