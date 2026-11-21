const ReplicatedStorage = game:GetService("ReplicatedStorage")

const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const React = require(ReplicatedStorage.Packages.react)
const use_ui_motion = require(script.Parent.Parent.visuals.use_ui_motion)

const create_element = React.createElement

const HOVER_DARKNESS = 0.55

const function shade_transparency(value: number): number
	return 1 - HOVER_DARKNESS * value
end

const function label_transparency(value: number): number
	return 1 - value
end

-- an invisible button over an image that darkens it and shows a hint on hover, for images the viewer may change
-- give corner_radius the image's own corner so the shade doesn't poke out of it
const function editable_image_overlay(props: {
	hint: string,
	corner_radius: UDim?,
	on_activated: () -> (),
})
	const hovered, set_hovered = React.useState(false)
	const motion = use_ui_motion(if hovered then 1 else 0)
	const function enter(): ()
		set_hovered(true)
	end
	const function leave(): ()
		set_hovered(false)
	end
	return create_element("TextButton", {
		Name = "edit_overlay",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = motion:map(shade_transparency),
		AutoButtonColor = false,
		FontFace = FONTS.semi_bold,
		Text = props.hint,
		TextSize = 28,
		TextColor3 = Color3.new(1, 1, 1),
		TextTransparency = motion:map(label_transparency),
		TextWrapped = true,
		ZIndex = 3,
		[React.Event.Activated] = props.on_activated,
		[React.Event.MouseEnter] = enter,
		[React.Event.MouseLeave] = leave,
	}, {
		corner = props.corner_radius and create_element("UICorner", { CornerRadius = props.corner_radius }),
	})
end

return editable_image_overlay
