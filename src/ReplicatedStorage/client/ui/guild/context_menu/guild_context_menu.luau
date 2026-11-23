const ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const React = require(ReplicatedStorage.Packages.react)
const guild_context_menu_types = require(script.Parent.guild_context_menu_types)
const use_ui_motion = require(script.Parent.Parent.Parent.components.hooks.use_ui_motion)

const create_element = React.createElement

const CONFIRM_TEXT = "Click again"
-- an armed option goes back to normal after this long so a stray click later doesn't fire it
const CONFIRM_TIMEOUT = 3

type option = guild_context_menu_types.option

const function invert(value: number): number
	return 1 - value
end

const function pop_scale(value: number): number
	return 0.9 + 0.1 * value
end

const function hover_transparency(value: number): number
	return 1 - 0.15 * value
end

const function context_menu_option(props: {
	option: option,
	layout_order: number,
	armed: boolean,
	on_pressed: (option) -> (),
})
	const hovered, set_hovered = React.useState(false)
	const hover_motion = use_ui_motion(if hovered then 1 else 0)
	const function enter(): ()
		set_hovered(true)
	end
	const function leave(): ()
		set_hovered(false)
	end
	const function activate(): ()
		props.on_pressed(props.option)
	end
	return create_element("TextButton", {
		Name = props.option.id,
		LayoutOrder = props.layout_order,
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = hover_motion:map(hover_transparency),
		AutoButtonColor = false,
		FontFace = if props.armed then FONTS.semi_bold else FONTS.regular,
		Text = if props.armed then CONFIRM_TEXT else props.option.text,
		TextSize = 30,
		TextColor3 = props.option.colour,
		[React.Event.Activated] = activate,
		[React.Event.MouseEnter] = enter,
		[React.Event.MouseLeave] = leave,
	}, {
		corner = create_element("UICorner", { CornerRadius = UDim.new(0, 10) }),
	})
end

-- pops in next to the button that opened it, position is a fraction of the window
-- remount it (change its key) for every opening so armed options never carry over
const function guild_context_menu(props: {
	position: UDim2,
	options: { option },
	on_action: (id: string) -> (),
})
	const motion = use_ui_motion(1, 0)
	const armed_id: string?, set_armed_id: (string?) -> () = React.useState(nil :: string?)

	const function disarm_after_timeout(): (() -> ())?
		if armed_id == nil then
			return nil
		end
		const timeout = task.delay(CONFIRM_TIMEOUT, set_armed_id, nil)
		const function cancel(): ()
			task.cancel(timeout)
		end
		return cancel
	end
	React.useEffect(disarm_after_timeout, { armed_id })

	const function pressed(option: option): ()
		if option.needs_confirmation and armed_id ~= option.id then
			set_armed_id(option.id)
			return
		end
		set_armed_id(nil)
		props.on_action(option.id)
	end

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
	for index, option in props.options do
		children[option.id] = create_element(context_menu_option, {
			option = option,
			layout_order = index,
			armed = armed_id == option.id,
			on_pressed = pressed,
		})
	end
	return create_element("CanvasGroup", {
		Name = "guild_context_menu",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = props.position,
		Size = UDim2.fromOffset(190, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = COLOURS.surface,
		BackgroundTransparency = 0.5,
		GroupTransparency = motion:map(invert),
		ZIndex = 2,
	}, children)
end

return guild_context_menu
