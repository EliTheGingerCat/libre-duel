local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)

local function animated_button(props: { [any]: any })
	local ref = React.useRef(nil :: GuiButton?)
	local minimum, set_minimum = React.useBinding(Vector2.zero)
	local automatic = props.AutomaticSize
	local auto_x = automatic == "X"
		or automatic == "XY"
		or automatic == Enum.AutomaticSize.X
		or automatic == Enum.AutomaticSize.XY
	local auto_y = automatic == "Y"
		or automatic == "XY"
		or automatic == Enum.AutomaticSize.Y
		or automatic == Enum.AutomaticSize.XY
	local size = props.Size or UDim2.fromOffset(100, 100)

	local function measure()
		if not auto_x and not auto_y then
			return
		end
		local button = ref.current
		assert(button)
		local function update_minimum(): ()
			local motion = button:FindFirstChildOfClass("UIScale")
			if motion and motion.Scale ~= 1 then
				return
			end
			local factor = 1
			local ancestor: Instance? = button
			while ancestor do
				local scale = ancestor:FindFirstChildOfClass("UIScale")
				if scale then
					factor *= scale.Scale
				end
				ancestor = ancestor.Parent
			end
			local measured = button.AbsoluteSize / factor
			set_minimum(
				Vector2.new(if auto_x then math.round(measured.X) else 0, if auto_y then math.round(measured.Y) else 0)
			)
		end
		local connection = button:GetPropertyChangedSignal("AbsoluteSize"):Connect(update_minimum)
		update_minimum()
		local function disconnect(): ()
			connection:Disconnect()
		end
		return disconnect
	end
	React.useLayoutEffect(measure, { auto_x, auto_y })

	local button_props = table.clone(props)
	button_props.class_name = nil
	button_props.children = nil
	button_props.ref = ref
	button_props.AnchorPoint = Vector2.new(0.5, 0.5)
	button_props.Position = UDim2.fromScale(0.5, 0.5)
	button_props.Size = UDim2.new(
		if auto_x then 0 else 1,
		if auto_x then size.X.Offset else 0,
		if auto_y then 0 else 1,
		if auto_y then size.Y.Offset else 0
	)
	button_props.LayoutOrder = nil
	button_props.Rotation = nil

	-- The layout owns this slot; only the centred button inside it scales.
	return React.createElement("Frame", {
		Name = props.Name,
		AnchorPoint = props.AnchorPoint,
		Position = props.Position,
		Size = size,
		SizeConstraint = props.SizeConstraint,
		LayoutOrder = props.LayoutOrder,
		Rotation = props.Rotation,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		BackgroundTransparency = 1,
	}, {
		minimum = (auto_x or auto_y) and React.createElement("UISizeConstraint", { MinSize = minimum }),
		button = React.createElement(props.class_name or "TextButton", button_props, props.children),
	})
end

return animated_button
