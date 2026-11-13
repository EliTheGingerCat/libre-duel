local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)

const function scrolling_content(props: {
	size: UDim2?,
	position: UDim2?,
	anchor: Vector2?,
	reset_key: any?,
	children: unknown?,
})
	local ref = React.useRef(nil :: ScrollingFrame?)
	local fade, set_fade = React.useBinding(Vector2.zero)
	const function update(list: ScrollingFrame): ()
		local remaining = list.AbsoluteCanvasSize.Y - list.AbsoluteWindowSize.Y - list.CanvasPosition.Y
		set_fade(Vector2.new(math.clamp(list.CanvasPosition.Y / 32, 0, 1), math.clamp(remaining / 32, 0, 1)))
	end
	const function transparency(amount: Vector2): NumberSequence
		return NumberSequence.new({
			NumberSequenceKeypoint.new(0, amount.X),
			NumberSequenceKeypoint.new(0.05, 0),
			NumberSequenceKeypoint.new(0.95, 0),
			NumberSequenceKeypoint.new(1, amount.Y),
		})
	end
	const function reset(): ()
		local list = ref.current
		if list then
			list.CanvasPosition = Vector2.zero
			update(list)
		end
	end
	React.useLayoutEffect(reset, { props.reset_key })
	return React.createElement("CanvasGroup", {
		Name = "list_viewport",
		Size = props.size or UDim2.fromScale(1, 1),
		Position = props.position,
		AnchorPoint = props.anchor,
		BackgroundTransparency = 1,
	}, {
		fade = React.createElement("UIGradient", { Rotation = 90, Transparency = fade:map(transparency) }),
		list = React.createElement("ScrollingFrame", {
			Name = "list",
			ref = ref,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 2,
			CanvasSize = UDim2.fromOffset(0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			[React.Change.CanvasPosition] = update,
			[React.Change.AbsoluteCanvasSize] = update,
			[React.Change.AbsoluteWindowSize] = update,
		}, props.children),
	})
end

return scrolling_content
