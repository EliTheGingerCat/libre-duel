--[[
COLOR THEME:
- Success, Green: #85dd32
- Error,,boxing, Red: #ff6464  
- Info?, Blue: #0da2dd -- could be success like in bridge duel
- Orange : #e67e22 
- Purple (basic fight colour): #9b59b6
- Red Team: #ff6464  --change these later if you want
- Blue Team: #0da2dd 
- White: #ffffff -- was info in bridge duel
- document more colours here for consistency

example of how to use it:
local notification_system = require(ReplicatedStorage.client.modules.notification_system)
notification_system.show("success message", "#85dd32")
notification_system.show("player", "#0da2dd", " was killed by ", "#ffffff", "oTillyy", "#b14c4e")
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local React = require(ReplicatedStorage.vendor.ReactLua.React)
local ReactRoblox = require(ReplicatedStorage.vendor.ReactLua.ReactRoblox)

local create_element = React.createElement

local player = Players.LocalPlayer
local player_gui = player:WaitForChild("PlayerGui")

local notification_system = {}

local notifications = {}
local set_notifications = nil
local next_id = 0

local NOTIFICATION_LIFETIME = 3
local FADE_START_TIME = 2.7
local FADE_DURATION = 0.3

local function notification_component(props)
	local notification = props.notification
	local index = props.index
	
	local transparency, set_transparency = React.useState(0)
	
	React.useEffect(function()
		local time_since_creation = tick() - notification.created_at
		local time_until_fade = FADE_START_TIME - time_since_creation
		
		local fade_task = task.spawn(function()
			if time_until_fade > 0 then
				task.wait(time_until_fade)
			end
			
			local fade_steps = 15
			local step_duration = FADE_DURATION / fade_steps
			
			for i = 1, fade_steps do
				local alpha = i / fade_steps
				set_transparency(alpha)
				task.wait(step_duration)
			end
		end)
		
		return function()
			task.cancel(fade_task)
		end
	end, {notification.id})

	local rich_text_parts = {}
	for i = 1, #notification.parts, 2 do
		local text = notification.parts[i]
		local color = notification.parts[i + 1] or "#ffffff"
		table.insert(rich_text_parts, '<font color="' .. color .. '">' .. text .. '</font>')
	end
	local text_content = table.concat(rich_text_parts, "")
	
	return create_element("Frame", {
		Size = UDim2.new(1, 0, 0, 26), -- Slightly bigger from 22 to 26
		Position = UDim2.new(0, 0, 1, -(index * 30)),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.5 + (transparency * 0.5),
	}, {
		create_element("UICorner", { CornerRadius = UDim.new(0, 13) }),
		create_element("UIStroke", {
			Thickness = 1,
			Color = Color3.fromRGB(255, 255, 255),
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Transparency = transparency,
		}, {
			create_element("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(134, 134, 134)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
				}),
				Rotation = -90,
			}),
		}),
		create_element("UIPadding", {
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 2),
			PaddingLeft = UDim.new(0, 2),
			PaddingRight = UDim.new(0, 2),
		}),
		
		create_element("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
			TextSize = 15, -- Slightly bigger from 14 to 15
			Text = text_content,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextScaled = false,
			TextTransparency = transparency,
			RichText = true,
		}),
	})
end

local function notifications_container()
	local notifications_state, set_notifications_state = React.useState({})
	
	React.useEffect(function()
		set_notifications = set_notifications_state
		return function()
			set_notifications = nil
		end
	end, {})
	
	if #notifications_state == 0 then
		return nil
	end
	
	local notification_elements = {}
	for i = #notifications_state, 1, -1 do
		local notification = notifications_state[i]
		local display_index = #notifications_state - i + 1 -- Convert to bottom-up index
		notification_elements[tostring(notification.id)] = create_element(notification_component, {
			notification = notification,
			index = display_index,
		})
	end
	
	return create_element("ScreenGui", {
		ScreenInsets = "None",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		create_element("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 15, 1, -15),
			Size = UDim2.new(0, 240, 0, 180),
			BackgroundTransparency = 1,
		}, notification_elements)
	})
end

--cleanup
local function cleanup_notifications()
	local current_time = tick()
	local updated = false
	
	for i = #notifications, 1, -1 do
		local notification = notifications[i]
		if current_time - notification.created_at >= NOTIFICATION_LIFETIME then
			table.remove(notifications, i)
			updated = true
		end
	end
	
	if updated and set_notifications then
		set_notifications({unpack(notifications)})
	end
end

task.spawn(function()
	while true do
		task.wait(0.1)
		cleanup_notifications()
	end
end)

function notification_system.show(...: string)
	local parts = {...}
	next_id = next_id + 1
	
	local new_notification = {
		parts = parts,
		id = next_id,
		created_at = tick()
	}
	
	table.insert(notifications, new_notification)
	
	if set_notifications then
		set_notifications({unpack(notifications)})
	end
end

local tree = ReactRoblox.createRoot(Instance.new("Folder"))
tree:render(ReactRoblox.createPortal(React.createElement(notifications_container), player_gui))

return notification_system
