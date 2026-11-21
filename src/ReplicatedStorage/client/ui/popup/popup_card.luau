const ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const POPUP_LAYOUT = require(script.Parent.POPUP_LAYOUT)
const React = require(ReplicatedStorage.Packages.react)
const popup_buttons = require(script.Parent.buttons.popup_buttons)
const popup_close_button = require(script.Parent.popup_close_button)
const popup_management = require(script.Parent.popup_management)
const popup_text_inputs = require(script.Parent.text_inputs.popup_text_inputs)
const popup_types = require(ReplicatedStorage.shared.popup.popup_types)
const surface = require(script.Parent.Parent.visuals.controls.surface)
const use_ui_motion = require(script.Parent.Parent.visuals.use_ui_motion)
const use_viewport_scale = require(script.Parent.Parent.visuals.use_viewport_scale)

const create_element = React.createElement

type popup = popup_management.popup

const PADDING = POPUP_LAYOUT.PADDING

-- same entrance as menu_window so popups feel like the other menus
const function get_entrance_position(motion: number): UDim2
	return UDim2.new(0.5, 0, 0.5, POPUP_LAYOUT.ENTRANCE_SLIDE_DISTANCE * (1 - motion))
end

const function get_entrance_scale_factor(motion: number): number
	const starting_scale = POPUP_LAYOUT.ENTRANCE_STARTING_SCALE
	return starting_scale + (1 - starting_scale) * motion
end

const function create_empty_text_input_values(popup: popup): popup_types.popup_text_input_values
	const text_input_values = {}
	const text_inputs = popup.params.text_inputs
	if text_inputs == nil then
		return text_input_values
	end
	for _, text_input in text_inputs do
		text_input_values[text_input.id] = ""
	end
	return text_input_values
end

const function popup_card(props: { popup: popup })
	const popup = props.popup
	const params = popup.params
	-- a ref because typing should not rerender the whole popup
	const text_input_values = React.useRef(create_empty_text_input_values(popup))

	const function respond(button_index: number?): ()
		popup_management.respond(popup.id, button_index, table.clone(text_input_values.current))
	end

	const function on_text_changed(id: string, text: string): ()
		text_input_values.current[id] = text
	end

	const function on_close_activated(): ()
		respond(nil)
	end

	const text_inputs = params.text_inputs
	const buttons = params.buttons

	const entrance_motion = use_ui_motion(1, 0)
	const viewport_scale = use_viewport_scale()
	const function get_entrance_scale(motion: number): number
		return viewport_scale * get_entrance_scale_factor(motion)
	end

	return create_element("Frame", {
		Name = "popup",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = entrance_motion:map(get_entrance_position),
		Size = UDim2.fromOffset(POPUP_LAYOUT.WIDTH, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = COLOURS.surface,
		BackgroundTransparency = 0.5,
	}, {
		scale = create_element("UIScale", { Scale = entrance_motion:map(get_entrance_scale) }),
		surface = create_element(surface, { radius = POPUP_LAYOUT.CORNER_RADIUS }),
		close_button = create_element(popup_close_button, { on_activated = on_close_activated }),
		container = create_element("Frame", {
			Name = "container",
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
		}, {
			padding = create_element("UIPadding", {
				PaddingTop = UDim.new(0, PADDING),
				PaddingBottom = UDim.new(0, PADDING),
				PaddingLeft = UDim.new(0, PADDING),
				PaddingRight = UDim.new(0, PADDING),
			}),
			layout = create_element("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, PADDING),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			icon = create_element("ImageLabel", {
				Name = "icon",
				LayoutOrder = 0,
				Size = UDim2.fromOffset(POPUP_LAYOUT.ICON_SIZE, POPUP_LAYOUT.ICON_SIZE),
				BackgroundTransparency = 1,
				Image = params.icon,
				ScaleType = Enum.ScaleType.Crop,
			}, {
				corner = create_element("UICorner", { CornerRadius = UDim.new(0, POPUP_LAYOUT.ICON_CORNER_RADIUS) }),
			}),
			text = create_element("TextLabel", {
				Name = "text",
				LayoutOrder = 1,
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				FontFace = FONTS.semi_bold,
				RichText = true,
				Text = params.text,
				TextColor3 = COLOURS.white,
				TextSize = POPUP_LAYOUT.TEXT_SIZE,
				TextWrapped = true,
			}),
			text_inputs = if text_inputs and #text_inputs > 0
				then create_element(popup_text_inputs, {
					text_inputs = text_inputs,
					layout_order = 2,
					on_text_changed = on_text_changed,
				})
				else nil,
			buttons = if buttons and #buttons > 0
				then create_element(popup_buttons, {
					buttons = buttons,
					layout_order = 3,
					on_button_pressed = respond,
				})
				else nil,
		}),
	})
end

return popup_card
