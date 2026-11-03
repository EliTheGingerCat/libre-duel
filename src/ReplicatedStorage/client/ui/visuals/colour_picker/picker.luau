local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local alpha_grid = require(script.Parent.Parent.controls.alpha_grid)
local colour_math = require(script.Parent.colour_math)
local fields = require(script.Parent.fields)
local surface = require(script.Parent.Parent.controls.surface)
local vertical_slider = require(script.Parent.vertical_slider)
local wheel = require(script.Parent.wheel)

local function picker(props: { colour: Color3, alpha: number, on_changed: (Color3, number) -> () })
	local hue, saturation, value = props.colour:ToHSV()
	local last_hue = React.useRef(hue)
	local last_saturation = React.useRef(saturation)
	if value > 0 then
		last_saturation.current = saturation
	else
		saturation = last_saturation.current
	end
	if value > 0 and saturation > 0 then
		last_hue.current = hue
	else
		hue = last_hue.current
	end
	local function wheel_changed(next_hue: number, next_saturation: number): ()
		last_hue.current = next_hue
		last_saturation.current = next_saturation
		props.on_changed(colour_math.from_hsv(next_hue, next_saturation, value), props.alpha)
	end
	local function brightness_changed(next_value: number): ()
		props.on_changed(colour_math.from_hsv(hue, saturation, next_value), props.alpha)
	end
	local function alpha_changed(next_alpha: number): ()
		props.on_changed(props.colour, next_alpha)
	end
	local function fields_changed(colour: Color3): ()
		props.on_changed(colour, props.alpha)
	end
	return React.createElement("Frame", {
		Name = "picker",
		Size = UDim2.fromOffset(300, 425),
		BackgroundColor3 = Color3.new(17 / 255, 17 / 255, 17 / 255),
		BackgroundTransparency = 0.2,
		Active = true,
	}, {
		surface = React.createElement(surface, { radius = 40 }),
		wheel = React.createElement(
			"Frame",
			{ BackgroundTransparency = 1, Position = UDim2.fromOffset(20, 20), Size = UDim2.fromOffset(160, 160) },
			{
				control = React.createElement(
					wheel,
					{ hue = hue, saturation = saturation, on_changed = wheel_changed }
				),
			}
		),
		brightness = React.createElement(
			"Frame",
			{ BackgroundTransparency = 1, Position = UDim2.fromOffset(200, 20), Size = UDim2.fromOffset(30, 160) },
			{
				control = React.createElement(vertical_slider, {
					value = value,
					colour = colour_math.from_hsv(hue, saturation, 1),
					on_changed = brightness_changed,
				}),
			}
		),
		alpha = React.createElement(
			"Frame",
			{ BackgroundTransparency = 1, Position = UDim2.fromOffset(250, 20), Size = UDim2.fromOffset(30, 160) },
			{
				control = React.createElement(
					vertical_slider,
					{ value = props.alpha, colour = props.colour, alpha = true, on_changed = alpha_changed }
				),
			}
		),
		fields = React.createElement(
			"Frame",
			{ BackgroundTransparency = 1, Position = UDim2.fromOffset(20, 200), Size = UDim2.fromOffset(260, 144) },
			{
				control = React.createElement(fields, { colour = props.colour, on_changed = fields_changed }),
			}
		),
		preview = React.createElement("Frame", {
			Position = UDim2.fromOffset(20, 365),
			Size = UDim2.fromOffset(260, 40),
			BackgroundTransparency = 1,
		}, {
			grid = React.createElement(alpha_grid, { radius = 20 }, {
				colour = React.createElement("Frame", {
					Size = UDim2.fromScale(1, 1),
					BackgroundColor3 = props.colour,
					BackgroundTransparency = 1 - props.alpha,
					BorderSizePixel = 0,
				}, { corner = React.createElement("UICorner", { CornerRadius = UDim.new(1, 0) }) }),
			}),
		}),
	})
end

return picker
