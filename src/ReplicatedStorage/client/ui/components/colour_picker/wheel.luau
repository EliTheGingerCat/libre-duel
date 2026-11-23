local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local drag_detector = require(script.Parent.Parent.controls.drag_detector)

const function wheel(props: { hue: number, saturation: number, on_changed: (number, number) -> () })
	const function drag(point: Vector2): ()
		local offset = (point - Vector2.new(0.5, 0.5)) * 2
		props.on_changed((math.atan2(offset.Y, -offset.X) / (2 * math.pi)) % 1, math.min(1, offset.Magnitude))
	end
	const function key(_button: GuiButton, input: InputObject): ()
		local code = input.KeyCode
		if code == Enum.KeyCode.Left or code == Enum.KeyCode.DPadLeft then
			props.on_changed((props.hue - 1 / 360) % 1, props.saturation)
		elseif code == Enum.KeyCode.Right or code == Enum.KeyCode.DPadRight then
			props.on_changed((props.hue + 1 / 360) % 1, props.saturation)
		elseif code == Enum.KeyCode.Up or code == Enum.KeyCode.DPadUp then
			props.on_changed(props.hue, math.min(1, props.saturation + 0.01))
		elseif code == Enum.KeyCode.Down or code == Enum.KeyCode.DPadDown then
			props.on_changed(props.hue, math.max(0, props.saturation - 0.01))
		end
	end
	local angle = props.hue * math.pi * 2
	return React.createElement("ImageButton", {
		Name = "wheel",
		Size = UDim2.fromOffset(160, 160),
		BackgroundTransparency = 1,
		Image = "rbxassetid://113835590316379",
		AutoButtonColor = false,
		[React.Event.InputBegan] = key,
	}, {
		drag = React.createElement(drag_detector, { on_changed = drag }),
		picker = React.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Rotation = 45,
			Size = UDim2.fromOffset(8, 8),
			Position = UDim2.fromScale(
				0.5 - math.cos(angle) * props.saturation / 2,
				0.5 + math.sin(angle) * props.saturation / 2
			),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 1,
		}),
	})
end

return wheel
