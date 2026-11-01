local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local MODE_OPTIONS = require(script.Parent.MODE_OPTIONS)
local gradient_stroke = require(script.Parent.Parent.visuals.gradient_stroke)
local hud_screen = require(script.Parent.Parent.hud.hud_screen)
local notification_management = require(script.Parent.Parent.notification_management)
local use_editable_hud = require(script.Parent.Parent.hud.use_editable_hud)
local use_editor_enabled = require(script.Parent.Parent.hud.use_editor_enabled)
local use_queue_status = require(script.Parent.use_queue_status)
local use_viewport_scale = require(script.Parent.Parent.visuals.use_viewport_scale)

local create_element = React.createElement

local function queue_status(props: use_editable_hud.props)
	local content_ref = use_editable_hud(queue_status, props)
	local state = use_queue_status()
	local editor_enabled = use_editor_enabled()
	local factor = use_viewport_scale()
	local busy, set_busy = React.useState(false)
	local pending = React.useRef(false)
	local option = MODE_OPTIONS[state.mode or "solo"]
	local function cancel(): ()
		if pending.current or editor_enabled or props.preview or state.teleporting then
			return
		end
		pending.current = true
		set_busy(true)
		local remote = ReplicatedStorage.remotes.leave_queue
		local ok, left = pcall(remote.InvokeServer, remote)
		pending.current = false
		set_busy(false)
		if not ok or left ~= true then
			notification_management.add("Could not cancel the queue. Please try again.")
		end
	end
	local text = string.format(
		'%s\n<font color="rgb(180,180,180)"><font size="24">Mode: %s | Duration: %d:%02d</font></font>',
		if state.teleporting then "Teleporting..." else "Queueing...",
		option.name,
		math.floor(state.elapsed / 60),
		state.elapsed % 60
	)
	local red = Color3.new(177 / 255, 76 / 255, 78 / 255)
	return create_element(
		hud_screen,
		{
			Name = "QueueStatus",
			Enabled = state.mode ~= nil or editor_enabled,
			ResetOnSpawn = false,
			preview = props.preview,
		},
		create_element("Frame", {
			ref = content_ref,
			Name = "content",
			AnchorPoint = if props.preview then Vector2.new(0.5, 0.5) else Vector2.new(0.5, 1),
			Position = if props.preview then UDim2.fromOffset(0, 0) else UDim2.new(0.5, 0, 1, -10 - 130 * factor),
			Size = UDim2.fromOffset(660, 100),
			BackgroundColor3 = Color3.new(17 / 255, 17 / 255, 17 / 255),
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
		}, {
			scale = create_element("UIScale", { Scale = factor }),
			corner = create_element("UICorner", { CornerRadius = UDim.new(0, 50) }),
			stroke = create_element(gradient_stroke),
			mode_icon = create_element("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 24, 0.5, 0),
				Size = UDim2.fromOffset(60, 60),
				BackgroundTransparency = 1,
				Image = option.icon,
			}),
			mode_info = create_element("TextLabel", {
				Position = UDim2.fromOffset(108, 0),
				Size = UDim2.new(1, -300, 1, 0),
				BackgroundTransparency = 1,
				Text = text,
				RichText = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 36,
				TextColor3 = Color3.new(1, 1, 1),
				FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
			}),
			cancel_button = create_element("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -20, 0.5, 0),
				Size = UDim2.fromOffset(180, 60),
				BackgroundColor3 = Color3.new(17 / 255, 17 / 255, 17 / 255),
				BackgroundTransparency = 0.5,
				BorderSizePixel = 0,
				Text = if busy then "Cancelling..." else "Cancel",
				TextColor3 = red,
				TextSize = 36,
				FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
				Interactable = not busy and not state.teleporting and not editor_enabled and not props.preview,
				[React.Event.Activated] = cancel,
			}, {
				corner = create_element("UICorner", { CornerRadius = UDim.new(1, 0) }),
				stroke = create_element(gradient_stroke, { colour = red }),
			}),
		})
	)
end

return queue_status
