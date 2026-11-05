local ReplicatedStorage = game:GetService("ReplicatedStorage")

const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
local React = require(ReplicatedStorage.Packages.react)
local big_button = require(script.Parent.Parent.visuals.big_button)
local button = require(script.Parent.Parent.visuals.button)
local check_box = require(script.Parent.Parent.visuals.check_box)
local colour_preview = require(script.Parent.Parent.visuals.colour_preview)
local danger_text = require(script.Parent.Parent.visuals.danger_text)
local dangerous_button = require(script.Parent.Parent.visuals.dangerous_button)
local dropdown = require(script.Parent.Parent.visuals.dropdown)
local information_text = require(script.Parent.Parent.visuals.information_text)
local settings_registry = require(script.Parent.settings_registry)
local slider = require(script.Parent.Parent.visuals.slider)
local switch = require(script.Parent.Parent.visuals.switch)
local text_input = require(script.Parent.Parent.visuals.text_input)
local warning_text = require(script.Parent.Parent.visuals.warning_text)

local create_element = React.createElement
const BUTTONS = { button = button, big_button = big_button, dangerous_button = dangerous_button }
const MESSAGES = { information = information_text, warning = warning_text, danger = danger_text }

local function setting_row(props: { entry: settings_registry.entry, order: number })
	local entry = props.entry
	local value = settings_registry.get(entry.id)
	local function changed(next_value: settings_registry.value): ()
		settings_registry.set(entry.id, next_value)
	end
	local function colour_changed(colour: Color3, alpha: number): ()
		changed({ colour = colour, alpha = alpha })
	end
	local control
	local label = false
	local height = 50
	if entry.kind == "information" or entry.kind == "warning" or entry.kind == "danger" then
		height = 0
		control = create_element(MESSAGES[entry.kind], { text = entry.text })
	elseif entry.kind == "button" or entry.kind == "big_button" or entry.kind == "dangerous_button" then
		height = if entry.kind == "big_button" then 128 else 50
		control = create_element(BUTTONS[entry.kind], { text = entry.text, on_activated = entry.on_activated })
	elseif entry.kind == "dropdown" then
		height = 0
		control = create_element(dropdown, { value = value :: string, options = entry.options, on_changed = changed })
	elseif entry.kind == "slider" then
		height = 64
		control = create_element(slider, {
			value = value :: number,
			minimum = entry.minimum,
			maximum = entry.maximum,
			step = entry.step,
			suffix = entry.suffix,
			text = entry.text,
			on_changed = changed,
		})
	elseif entry.kind == "text" then
		control = create_element(
			text_input,
			{ text = value :: string, placeholder = entry.text, icon = entry.icon, on_changed = changed }
		)
	elseif entry.kind == "colour" then
		height = 180
		label = true
		local colour = value :: { colour: Color3, alpha: number }
		control = create_element(
			colour_preview,
			{ colour = colour.colour, alpha = colour.alpha, on_changed = colour_changed }
		)
	elseif entry.kind == "switch" or entry.kind == "checkbox" then
		height = 40
		label = true
		control = create_element(if entry.kind == "switch" then switch else check_box, {
			active = value :: boolean,
			round = if entry.kind == "checkbox" then entry.round else nil,
			on_changed = changed,
		})
	end
	local toggle = entry.kind == "switch" or entry.kind == "checkbox"
	return create_element("Frame", {
		Name = entry.id,
		LayoutOrder = props.order,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, height),
		AutomaticSize = if height == 0 then Enum.AutomaticSize.Y else Enum.AutomaticSize.None,
	}, {
		label = label and create_element("TextLabel", {
			Size = UDim2.new(1, if toggle then -100 else 0, 0, 40),
			BackgroundTransparency = 1,
			Text = entry.text,
			TextSize = 32,
			TextColor3 = Color3.new(1, 1, 1),
			FontFace = FONTS.regular,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
		control = create_element("Frame", {
			BackgroundTransparency = 1,
			AnchorPoint = if toggle then Vector2.new(1, 0) else Vector2.zero,
			Position = if toggle
				then UDim2.fromScale(1, 0)
				elseif label then UDim2.fromOffset(0, 52)
				else UDim2.fromOffset(0, 0),
			Size = if toggle
				then UDim2.fromOffset(if entry.kind == "switch" then 78 else 40, 40)
				else UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		}, control),
	})
end

return setting_row
