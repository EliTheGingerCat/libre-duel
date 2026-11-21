const ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const React = require(ReplicatedStorage.Packages.react)
const use_ui_motion = require(script.Parent.Parent.Parent.visuals.use_ui_motion)

const create_element = React.createElement

export type action = "view_profile" | "kick" | "ban"

type option = { action: action, text: string, colour: Color3, owner_only: boolean }

const OPTIONS: { option } = {
	{ action = "view_profile", text = "View profile", colour = Color3.new(1, 1, 1), owner_only = false },
	{ action = "kick", text = "Kick", colour = COLOURS.danger_text, owner_only = true },
	{ action = "ban", text = "Ban", colour = COLOURS.danger_text, owner_only = true },
}

const function invert(value: number): number
	return 1 - value
end

const function pop_scale(value: number): number
	return 0.9 + 0.1 * value
end

const function hover_transparency(value: number): number
	return 1 - 0.15 * value
end

const function context_menu_option(props: { option: option, layout_order: number, on_action: (action) -> () })
	const hovered, set_hovered = React.useState(false)
	const hover_motion = use_ui_motion(if hovered then 1 else 0)
	const function enter(): ()
		set_hovered(true)
	end
	const function leave(): ()
		set_hovered(false)
	end
	const function activate(): ()
		props.on_action(props.option.action)
	end
	return create_element("TextButton", {
		Name = props.option.action,
		LayoutOrder = props.layout_order,
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = hover_motion:map(hover_transparency),
		AutoButtonColor = false,
		FontFace = FONTS.regular,
		Text = props.option.text,
		TextSize = 30,
		TextColor3 = props.option.colour,
		[React.Event.Activated] = activate,
		[React.Event.MouseEnter] = enter,
		[React.Event.MouseLeave] = leave,
	}, {
		corner = create_element("UICorner", { CornerRadius = UDim.new(0, 10) }),
	})
end

-- pops in next to the manage button that opened it, position is a fraction of the window
const function member_context_menu(props: {
	position: UDim2,
	viewer_is_owner: boolean,
	on_action: (action) -> (),
})
	const motion = use_ui_motion(1, 0)
	const children = {
		layout = create_element("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
		padding = create_element("UIPadding", {
			PaddingTop = UDim.new(0, 6),
			PaddingBottom = UDim.new(0, 6),
			PaddingLeft = UDim.new(0, 6),
			PaddingRight = UDim.new(0, 6),
		}),
		corner = create_element("UICorner", { CornerRadius = UDim.new(0, 16) }),
		scale = create_element("UIScale", { Scale = motion:map(pop_scale) }),
	}
	for index, option in OPTIONS do
		if props.viewer_is_owner or not option.owner_only then
			children[option.action] = create_element(
				context_menu_option,
				{ option = option, layout_order = index, on_action = props.on_action }
			)
		end
	end
	return create_element("CanvasGroup", {
		Name = "member_context_menu",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = props.position,
		Size = UDim2.fromOffset(170, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = COLOURS.surface,
		BackgroundTransparency = 0.5,
		GroupTransparency = motion:map(invert),
		ZIndex = 2,
	}, children)
end

return member_context_menu
