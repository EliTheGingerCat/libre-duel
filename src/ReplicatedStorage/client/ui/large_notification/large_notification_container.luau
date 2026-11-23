const ReplicatedStorage = game:GetService("ReplicatedStorage")

const LARGE_NOTIFICATION_LAYOUT = require(script.Parent.LARGE_NOTIFICATION_LAYOUT)
const React = require(ReplicatedStorage.Packages.react)
const large_notification_card = require(script.Parent.large_notification_card)
const large_notification_management = require(script.Parent.large_notification_management)
const scale = require(script.Parent.Parent.components.layout.scale)

const create_element = React.createElement

type large_notification = large_notification_management.large_notification

const MARGIN = LARGE_NOTIFICATION_LAYOUT.SCREEN_MARGIN

const function use_large_notifications(): { large_notification }
	const large_notifications, set_large_notifications = React.useState(large_notification_management.get_all)

	const function effect_large_notifications()
		const function on_change(): ()
			set_large_notifications(large_notification_management.get_all())
		end

		const connection = large_notification_management.on_change:Connect(on_change)

		const function disconnect(): ()
			connection:Disconnect()
		end

		return disconnect
	end
	React.useEffect(effect_large_notifications, {})

	return large_notifications
end

const function large_notification_container()
	const large_notifications = use_large_notifications()

	const card_elements = {}
	for index, large_notification in large_notifications do
		card_elements[`large_notification_{large_notification.id}`] = create_element(large_notification_card, {
			large_notification = large_notification,
			layout_order = index,
		})
	end

	return create_element("ScreenGui", {
		Name = "LargeNotifications",
		DisplayOrder = LARGE_NOTIFICATION_LAYOUT.DISPLAY_ORDER,
		ResetOnSpawn = false,
	}, {
		stack = create_element("Frame", {
			Name = "stack",
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -MARGIN, 0, MARGIN),
			Size = UDim2.fromOffset(LARGE_NOTIFICATION_LAYOUT.WIDTH, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
		}, {
			scale = create_element(scale),
			layout = create_element("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, LARGE_NOTIFICATION_LAYOUT.PADDING),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			cards = create_element(React.Fragment, {}, card_elements),
		}),
	})
end

return large_notification_container
