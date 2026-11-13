local ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const HUD_DEFAULTS = require(script.Parent.Parent.hud.HUD_DEFAULTS)
const get_mode_definition = require(ReplicatedStorage.shared.modes.get_mode_definition)
local React = require(ReplicatedStorage.Packages.react)
local animated_button = require(script.Parent.Parent.visuals.animated_button)
local button_motion = require(script.Parent.Parent.visuals.button_motion)
local gradient_stroke = require(script.Parent.Parent.visuals.gradient_stroke)
local hud_screen = require(script.Parent.Parent.hud.hud_screen)
local notification_management = require(script.Parent.Parent.notification_management)
local shadow = require(script.Parent.Parent.visuals.shadow)
local use_editable_hud = require(script.Parent.Parent.hud.use_editable_hud)
local use_editor_enabled = require(script.Parent.Parent.hud.use_editor_enabled)
local use_queue_status = require(script.Parent.use_queue_status)
local use_viewport_scale = require(script.Parent.Parent.visuals.use_viewport_scale)

local create_element = React.createElement

const DEFAULTS = HUD_DEFAULTS.QueueStatus

const function queue_status(props: use_editable_hud.props)
	local content_ref = use_editable_hud(queue_status, props)
	local state = use_queue_status()
	local editor_enabled = use_editor_enabled()
	local factor = use_viewport_scale()
	local busy, set_busy = React.useState(false)
	local pending = React.useRef(false)
	local option = get_mode_definition(state.mode or "bridge_solo")
	const function cancel(): ()
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
	local red = COLOURS.danger
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
			AnchorPoint = if props.preview then Vector2.new(0.5, 0.5) else DEFAULTS.anchor,
			Position = if props.preview
				then UDim2.fromOffset(0, 0)
				else DEFAULTS.position + UDim2.fromOffset(0, DEFAULTS.stack_offset * factor),
			Size = UDim2.fromOffset(660, 100),
			BackgroundColor3 = COLOURS.surface,
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
		}, {
			scale = create_element("UIScale", { Scale = factor }),
			shadow = create_element(
				shadow,
				{ ShowBehindParent = false, BlurRadius = UDim.new(0, 8), Transparency = 0.3 }
			),
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
				FontFace = FONTS.regular,
			}),
			cancel_button = create_element(animated_button, {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -20, 0.5, 0),
				Size = UDim2.fromOffset(180, 60),
				BackgroundColor3 = COLOURS.surface,
				BackgroundTransparency = 0.5,
				BorderSizePixel = 0,
				Text = if busy then "Cancelling..." else "Cancel",
				TextColor3 = red,
				TextSize = 36,
				FontFace = FONTS.regular,
				Interactable = not busy and not state.teleporting and not editor_enabled and not props.preview,
				[React.Event.Activated] = cancel,
			}, {
				feedback = create_element(button_motion),
				corner = create_element("UICorner", { CornerRadius = UDim.new(1, 0) }),
				stroke = create_element(gradient_stroke, { colour = red }),
			}),
		})
	)
end

return queue_status
