local ReplicatedStorage = game:GetService("ReplicatedStorage")

local notification_management = require(script.Parent.Parent.modules.notification_management)
local React = require(ReplicatedStorage.Packages.react)
local ReactRoblox = require(ReplicatedStorage.Packages["react-roblox"])

local colours = require(ReplicatedStorage.modules.colours)
local create_element = React.createElement
type notification = notification_management.notification
local use_effect = React.useEffect
local use_state = React.useState

local lifetime_until_fade = 3
local fade_duration = 0.5

local function use_fade_out(created_at: number): number
	local transparency, set_transparency = use_state(0)
	
	local function effect_fade_out()
		local time_since_creation = tick() - created_at
		local time_until_fade = lifetime_until_fade - time_since_creation
		
		local function thread_fade(): ()
			if time_until_fade > 0 then
				task.wait(time_until_fade)
			end

			local time_since_start_fading = 0

			while true do
				local new_transparency = math.min(1, time_since_start_fading / fade_duration)
				set_transparency(new_transparency)

				local time_waited = task.wait()
				time_since_start_fading += time_waited
			end
		end

		local task_fade = task.spawn(thread_fade)
		
		local function disconnect(): ()
			task.cancel(task_fade)
		end

		return disconnect
	end
	
	use_effect(effect_fade_out, {})

	return transparency
end

local function notification_component(props: {
	notification: notification,
	index: number,
	on_destroy: () -> (),
})
	local notification = props.notification
	local index = props.index
	
	local transparency = use_fade_out(notification.created_at)

	if transparency == 1 then
		props.on_destroy()
	end
	
	return create_element("Frame", {
		AutomaticSize = "X",
		Size = UDim2.new(0, 0, 0, 28),
		Position = UDim2.new(0, 0, 1, -(index * 32)),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = colours.black,
		BackgroundTransparency = 0.5 + (transparency * 0.5),
	},
		create_element("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
		create_element("UIStroke", {
			Thickness = 1,
			Color = colours.white,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Transparency = transparency,
		}, 
			create_element("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, colours.light_grey),
					ColorSequenceKeypoint.new(1, colours.dark_grey),
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
			FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
			TextSize = 24, -- Slightly bigger from 14 to 15
			Text = notification.message,
			TextColor3 = colours.white,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextScaled = false,
			TextTransparency = transparency,
			RichText = true,
		})
	)
end

local function use_notifications(): {notification}
	local notifications, set_notifications = use_state(notification_management.existing)

	local function effect_notifications()
		local function on_fire(): ()
			set_notifications(table.clone(notification_management.existing))
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

local function notifications_container()
	local notifications = use_notifications()
	
	local notification_elements = {}
	local notifications_length = #notifications
	for index, notification in notifications do
		local display_order = notifications_length - index + 1 -- Convert to bottom-up index

		local function on_destroy(): ()
			notification_management.remove(notification.id)
		end

		table.insert(notification_elements, create_element(notification_component, {
			key = notification.id,
			notification = notification,
			index = display_order,
			on_destroy = on_destroy,
		}))
	end

	return create_element("ScreenGui", {
		Name = "Notifications",
		ResetOnSpawn = false,
	}, {
		create_element("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 15, 1, -15),
			Size = UDim2.new(0, 240, 0, 180),
			BackgroundTransparency = 1,
		},
			notification_elements
		)
	})
end

return notifications_container
