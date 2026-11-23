local ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const use_ui_motion = require(script.Parent.Parent.components.hooks.use_ui_motion)

const create_element = React.createElement
const SLIDE_DISTANCE = 16

const function invert(value: number): number
	return 1 - value
end

const function slide_position(value: number): UDim2
	return UDim2.fromOffset(0, SLIDE_DISTANCE * (1 - value))
end

-- fades and slides its children up when mounted, give it a new key to play it again
const function entrance_animation(
	props: {
		layout_order: number?,
		-- fills the parent instead of growing with the content, for pages that scroll their own content
		fill: boolean?,
		children: unknown?,
	}
)
	const motion = use_ui_motion(1, 0)
	return create_element("Frame", {
		LayoutOrder = props.layout_order,
		Size = UDim2.fromScale(1, if props.fill then 1 else 0),
		AutomaticSize = if props.fill then Enum.AutomaticSize.None else Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, {
		content = create_element("CanvasGroup", {
			Position = motion:map(slide_position),
			Size = UDim2.fromScale(1, if props.fill then 1 else 0),
			AutomaticSize = if props.fill then Enum.AutomaticSize.None else Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			GroupTransparency = motion:map(invert),
		}, props.children),
	})
end

return entrance_animation
