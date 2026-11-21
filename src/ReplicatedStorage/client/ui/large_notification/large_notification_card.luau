const ReplicatedStorage = game:GetService("ReplicatedStorage")

const LARGE_NOTIFICATION_LAYOUT = require(script.Parent.LARGE_NOTIFICATION_LAYOUT)
const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const React = require(ReplicatedStorage.Packages.react)
const large_notification_button = require(script.Parent.large_notification_button)
const large_notification_close_button = require(script.Parent.large_notification_close_button)
const large_notification_management = require(script.Parent.large_notification_management)
const surface = require(script.Parent.Parent.visuals.controls.surface)

const create_element = React.createElement

type large_notification = large_notification_management.large_notification

const PADDING = LARGE_NOTIFICATION_LAYOUT.PADDING

const function create_padding(top: number, bottom: number, left: number, right: number)
	return create_element("UIPadding", {
		PaddingTop = UDim.new(0, top),
		PaddingBottom = UDim.new(0, bottom),
		PaddingLeft = UDim.new(0, left),
		PaddingRight = UDim.new(0, right),
	})
end

const function create_button_row(large_notification: large_notification)
	const buttons = large_notification.params.buttons
	if buttons == nil or #buttons == 0 then
		return nil
	end

	const button_count = #buttons
	const total_gap = PADDING * (button_count - 1)
	const button_elements = {}
	button_elements.grid = create_element("UIGridLayout", {
		CellSize = UDim2.new(1 / button_count, -total_gap / button_count, 1, 0),
		CellPadding = UDim2.fromOffset(PADDING, PADDING),
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	for button_index, button in buttons do
		const function on_button_activated(): ()
			large_notification_management.respond(large_notification.id, button_index)
		end

		button_elements[`button_{button_index}`] = create_element(large_notification_button, {
			text = button.text,
			text_colour = button.text_colour,
			layout_order = button_index,
			on_activated = on_button_activated,
		})
	end

	return create_element("Frame", {
		Name = "buttons",
		LayoutOrder = 2,
		Size = UDim2.fromScale(1, 0),
		BackgroundTransparency = 1,
	}, {
		flex = create_element("UIFlexItem", { FlexMode = Enum.UIFlexMode.Grow }),
		buttons = create_element(React.Fragment, {}, button_elements),
	})
end

const function large_notification_card(props: {
	large_notification: large_notification,
	layout_order: number,
})
	const large_notification = props.large_notification
	const button_row = create_button_row(large_notification)
	const text_height = if button_row then LARGE_NOTIFICATION_LAYOUT.TEXT_HEIGHT_WITH_BUTTONS else 1
	-- keeps the text from running under the close button
	const text_right_padding = LARGE_NOTIFICATION_LAYOUT.CLOSE_BUTTON_SIZE + PADDING

	const function on_close_activated(): ()
		large_notification_management.respond(large_notification.id, nil)
	end

	return create_element("Frame", {
		Name = "large_notification",
		LayoutOrder = props.layout_order,
		Size = UDim2.fromOffset(LARGE_NOTIFICATION_LAYOUT.WIDTH, LARGE_NOTIFICATION_LAYOUT.HEIGHT),
		BackgroundColor3 = COLOURS.surface,
		BackgroundTransparency = 0.5,
	}, {
		surface = create_element(surface, { radius = LARGE_NOTIFICATION_LAYOUT.CARD_CORNER_RADIUS }),
		close_button = create_element(large_notification_close_button, { on_activated = on_close_activated }),
		content = create_element("Frame", {
			Name = "content",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, {
			padding = create_padding(PADDING, PADDING, PADDING, PADDING),
			layout = create_element("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, PADDING),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			icon = create_element("ImageLabel", {
				Name = "icon",
				LayoutOrder = 1,
				Size = UDim2.fromScale(1, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency = 1,
				Image = large_notification.params.icon,
				ScaleType = Enum.ScaleType.Crop,
			}, {
				corner = create_element("UICorner", {
					CornerRadius = UDim.new(0, LARGE_NOTIFICATION_LAYOUT.ICON_CORNER_RADIUS),
				}),
			}),
			text_column = create_element("Frame", {
				Name = "text_column",
				LayoutOrder = 2,
				Size = UDim2.fromScale(0, 1),
				BackgroundTransparency = 1,
			}, {
				flex = create_element("UIFlexItem", { FlexMode = Enum.UIFlexMode.Grow }),
				layout = create_element("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					Padding = UDim.new(0, 5),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				text = create_element("TextLabel", {
					Name = "text",
					LayoutOrder = 1,
					Size = UDim2.fromScale(1, text_height),
					BackgroundTransparency = 1,
					FontFace = FONTS.semi_bold,
					RichText = true,
					Text = large_notification.params.text,
					TextColor3 = COLOURS.white,
					TextSize = LARGE_NOTIFICATION_LAYOUT.TEXT_SIZE,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
				}, {
					padding = create_padding(PADDING, PADDING, 0, text_right_padding),
				}),
				buttons = button_row,
			}),
		}),
	})
end

return large_notification_card
