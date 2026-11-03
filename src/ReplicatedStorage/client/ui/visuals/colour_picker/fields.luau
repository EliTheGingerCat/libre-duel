local ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
local React = require(ReplicatedStorage.Packages.react)
local colour_math = require(script.Parent.colour_math)

local function fields(props: { colour: Color3, on_changed: (Color3) -> () })
	local hue, saturation, value = props.colour:ToHSV()
	local rows: { { name: string, values: { string } } } = {
		{
			name = "RGB",
			values = {
				tostring(math.round(props.colour.R * 255)),
				tostring(math.round(props.colour.G * 255)),
				tostring(math.round(props.colour.B * 255)),
			},
		},
		{
			name = "HSV",
			values = {
				tostring(math.round(hue * 360)),
				tostring(math.round(saturation * 100)),
				tostring(math.round(value * 100)),
			},
		},
		{ name = "Hex", values = { props.colour:ToHex() } },
	}
	local children = {}
	for row_index, row in rows do
		children[row.name] = React.createElement("TextLabel", {
			Position = UDim2.fromOffset(0, (row_index - 1) * 48),
			Size = UDim2.fromOffset(60, 42),
			BackgroundTransparency = 1,
			Text = row.name,
			TextSize = 28,
			TextColor3 = Color3.new(1, 1, 1),
			FontFace = FONTS.regular,
		})
		for index, initial in row.values do
			local function commit(box: TextBox): ()
				if row.name == "Hex" then
					local hex = box.Text:gsub("#", "")
					if #hex == 6 and hex:match("^%x+$") then
						props.on_changed(
							Color3.new(
								(tonumber(hex:sub(1, 2), 16) or 0) / 255,
								(tonumber(hex:sub(3, 4), 16) or 0) / 255,
								(tonumber(hex:sub(5, 6), 16) or 0) / 255
							)
						)
					else
						box.Text = tostring(initial)
					end
					return
				end
				local number = tonumber((box.Text:gsub("[°%%]", "")))
				if not number or number ~= number then
					box.Text = tostring(initial)
					return
				end
				local values =
					{ tonumber(row.values[1]) or 0, tonumber(row.values[2]) or 0, tonumber(row.values[3]) or 0 }
				values[index] = math.clamp(number, 0, if row.name == "RGB" then 255 elseif index == 1 then 360 else 100)
				if row.name == "RGB" then
					props.on_changed(Color3.new(values[1] / 255, values[2] / 255, values[3] / 255))
				else
					props.on_changed(colour_math.from_hsv(values[1] / 360, values[2] / 100, values[3] / 100))
				end
				box.Text = tostring(values[index])
			end
			local width = 200 / #row.values
			children[row.name .. index] = React.createElement("TextBox", {
				Name = row.name .. index,
				Position = UDim2.fromOffset(60 + (index - 1) * width, (row_index - 1) * 48),
				Size = UDim2.fromOffset(width - 4, 42),
				BackgroundColor3 = COLOURS.surface,
				BackgroundTransparency = 0.5,
				ClearTextOnFocus = false,
				Text = tostring(initial),
				TextSize = 28,
				TextColor3 = Color3.new(1, 1, 1),
				FontFace = FONTS.regular,
				[React.Event.FocusLost] = commit,
			}, { corner = React.createElement("UICorner", { CornerRadius = UDim.new(0, 12) }) })
		end
	end
	return React.createElement("Frame", { BackgroundTransparency = 1, Size = UDim2.fromOffset(260, 144) }, children)
end

return fields
