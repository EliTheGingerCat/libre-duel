const ReplicatedStorage = game:GetService("ReplicatedStorage")

const PLAYER_ROW_LAYOUT = require(script.Parent.PLAYER_ROW_LAYOUT)
const React = require(ReplicatedStorage.Packages.react)
const animated_button = require(script.Parent.Parent.components.buttons.animated_button)
const button_motion = require(script.Parent.Parent.components.buttons.button_motion)
const player_row_types = require(script.Parent.player_row_types)
const use_ui_motion = require(script.Parent.Parent.components.hooks.use_ui_motion)

const create_element = React.createElement

export type props = {
	player: player_row_types.player_summary,
	layout_order: number?,
	-- fills the space between the headshot and the action button, give it a UIFlexItem set to fill
	content: unknown,
	action_icon: string?,
	on_action: ((button: GuiObject) -> ())?,
	-- makes the whole row pressable, with a hover highlight
	on_activated: (() -> ())?,
}

const function hover_transparency(value: number): number
	return 1 - 0.06 * value
end

-- the banner, headshot and trailing action button that every player list row is built from
const function player_banner_row(props: props)
	const hovered, set_hovered = React.useState(false)
	const hover_motion = use_ui_motion(if hovered then 1 else 0)
	const pressable = props.on_activated ~= nil
	const function enter(): ()
		set_hovered(true)
	end
	const function leave(): ()
		set_hovered(false)
	end
	const function activate_action(button: GuiObject): ()
		if props.on_action then
			props.on_action(button)
		end
	end
	const action_reserved = if props.action_icon
		then PLAYER_ROW_LAYOUT.action_size + PLAYER_ROW_LAYOUT.action_inset
		else 0
	return create_element(if pressable then "TextButton" else "Frame", {
		Name = "banner_row",
		LayoutOrder = props.layout_order,
		Size = UDim2.new(1, 0, 0, PLAYER_ROW_LAYOUT.height),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = if pressable then hover_motion:map(hover_transparency) else 1,
		AutoButtonColor = if pressable then false else nil,
		Text = if pressable then "" else nil,
		[React.Event.Activated] = props.on_activated,
		[React.Event.MouseEnter] = if pressable then enter else nil,
		[React.Event.MouseLeave] = if pressable then leave else nil,
	}, {
		banner = create_element("ImageLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = props.player.banner,
			ScaleType = Enum.ScaleType.Crop,
		}, {
			fade = create_element("UIGradient", { Transparency = PLAYER_ROW_LAYOUT.banner_fade }),
		}),
		row = create_element("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ZIndex = 2,
		}, {
			padding = create_element("UIPadding", {
				PaddingTop = UDim.new(0, PLAYER_ROW_LAYOUT.padding),
				PaddingBottom = UDim.new(0, PLAYER_ROW_LAYOUT.padding),
				PaddingLeft = UDim.new(0, PLAYER_ROW_LAYOUT.padding),
				PaddingRight = UDim.new(0, PLAYER_ROW_LAYOUT.padding + action_reserved),
			}),
			layout = create_element("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, PLAYER_ROW_LAYOUT.headshot_gap),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			headshot = create_element("ImageLabel", {
				LayoutOrder = 1,
				Size = UDim2.fromScale(1, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency = 1,
				Image = props.player.headshot,
				ScaleType = Enum.ScaleType.Crop,
			}, {
				corner = create_element("UICorner", { CornerRadius = UDim.new(0, 12) }),
			}),
			content = props.content,
		}),
		action = props.action_icon and create_element(animated_button, {
			class_name = "ImageButton",
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -PLAYER_ROW_LAYOUT.action_inset, 0.5, 0),
			Size = UDim2.fromOffset(PLAYER_ROW_LAYOUT.action_size, PLAYER_ROW_LAYOUT.action_size),
			BackgroundTransparency = 1,
			Image = props.action_icon,
			ZIndex = 3,
			[React.Event.Activated] = activate_action,
		}, { feedback = create_element(button_motion) }),
	})
end

return player_banner_row
