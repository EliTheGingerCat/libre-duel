local ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
local React = require(ReplicatedStorage.Packages.react)
local fade = require(script.Parent.Parent.effects.fade)
local hud_screen = require(script.Parent.Parent.hud.hud_screen)
local notification_management = require(script.Parent.Parent.notification_management)
local shadow = require(script.Parent.shadow)
local use_editable_hud = require(script.Parent.Parent.hud.use_editable_hud)
local use_editor_enabled = require(script.Parent.Parent.hud.use_editor_enabled)

local create_element = React.createElement
type notification = notification_management.notification
local use_effect = React.useEffect
local use_state = React.useState

const LIFETIME_UNTIL_FADE = 3
const FADE_DURATION = 0.5
const EXAMPLE_NOTIFICATION: notification = { id = 0, message = "Example notification", created_at = 0 }

local function do_nothing(): () end

local function use_fade_out(created_at: number, preview: boolean): number
	local transparency, set_transparency = use_state(0)

	local function effect_fade_out()
		if preview then
			set_transparency(0)
			return
		end
		local time_since_creation = os.clock() - created_at
		local time_until_fade = LIFETIME_UNTIL_FADE - time_since_creation

		local function thread_fade(): ()
			if time_until_fade > 0 then
				task.wait(time_until_fade)
			end

			fade(0, 1, FADE_DURATION, set_transparency)
		end

		local task_fade = task.spawn(thread_fade)

		local function disconnect(): ()
			if coroutine.status(task_fade) ~= "dead" then
				task.cancel(task_fade)
			end
		end

		return disconnect
	end

	local dependencies: { number | boolean } = { created_at, preview }
	use_effect(effect_fade_out, dependencies)

	return transparency
end

local function notification_component(props: {
	notification: notification,
	index: number,
	on_destroy: () -> (),
	preview: boolean?,
})
	local notification = props.notification
	local index = props.index

	local transparency = use_fade_out(notification.created_at, props.preview == true)

	local function effect_destroy()
		if transparency == 1 then
			props.on_destroy()
		end
	end
	use_effect(effect_destroy, { transparency == 1 })

	return create_element(
		"Frame",
		{
			AutomaticSize = "X",
			Size = UDim2.new(0, 0, 0, 28),
			Position = UDim2.new(0, 0, 1, -(index * 32)),
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = COLOURS.black,
			BackgroundTransparency = 0.5 + (transparency * 0.5),
			ZIndex = 2,
		},
		create_element(shadow, { ShowBehindParent = false, BlurRadius = UDim.new(0, 8), Transparency = 0.3 + (transparency * 0.7) }),
		create_element("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
		create_element(
			"UIStroke",
			{
				Thickness = 1,
				Color = COLOURS.white,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Transparency = transparency,
			},
			create_element("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, COLOURS.light_grey),
					ColorSequenceKeypoint.new(1, COLOURS.dark_grey),
				}),
				Rotation = -90,
			})
		),
		create_element("UIPadding", {
			PaddingTop = UDim.new(0, 3), --without this the text would look offset and Ugly!
			PaddingBottom = UDim.new(0, 0),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
		}),
		create_element("TextLabel", {
			AutomaticSize = "XY",
			Size = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			FontFace = FONTS.regular,
			TextSize = 24, -- Slightly bigger from 14 to 15
			Text = notification.message,
			TextColor3 = COLOURS.white,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextScaled = false,
			TextTransparency = transparency,
			RichText = true,
			ZIndex = 3,
		})
	)
end

local function use_notifications(): { notification }
	local notifications, set_notifications = use_state(notification_management.get_all)

	local function effect_notifications()
		local function on_fire(): ()
			set_notifications(notification_management.get_all())
		end

		local connection = notification_management.on_change:Connect(on_fire)

		local function disconnect(): ()
			connection:Disconnect()
		end

		return disconnect
	end

	use_effect(effect_notifications, {})

	return notifications
end

local function notifications_container(props: use_editable_hud.props)
	local content_ref = use_editable_hud(notifications_container, props)
	local editor_enabled = use_editor_enabled()
	local current_notifications = use_notifications()
	local notifications: { notification } = if props.preview then {} else current_notifications

	local notification_elements = {}
	if (editor_enabled or props.preview) and #notifications == 0 then
		table.insert(
			notification_elements,
			create_element(notification_component, {
				key = "example",
				notification = EXAMPLE_NOTIFICATION,
				index = 1,
				preview = true,
				on_destroy = do_nothing,
			})
		)
	end
	local notifications_length = #notifications
	for index, notification in notifications do
		local display_order = notifications_length - index + 1 -- Convert to bottom-up index

		local function on_destroy(): ()
			notification_management.remove(notification.id)
		end

		table.insert(
			notification_elements,
			create_element(notification_component, {
				key = notification.id,
				notification = notification,
				index = display_order,
				on_destroy = on_destroy,
			})
		)
	end

	return create_element(hud_screen, {
		Name = "Notifications",
		preview = props.preview,
		ResetOnSpawn = false,
	}, {
		create_element("Frame", {
			ref = content_ref,
			AnchorPoint = if props.preview then Vector2.new(0.5, 0.5) else Vector2.new(0, 1),
			Position = if props.preview then UDim2.fromOffset(0, 0) else UDim2.new(0, 15, 1, -15),
			Size = UDim2.new(0, 240, 0, 180),
			BackgroundTransparency = 1,
		}, notification_elements),
	})
end

return notifications_container
