local ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
local React = require(ReplicatedStorage.Packages.react)
local animated_button = require(script.Parent.Parent.visuals.animated_button)
local button_motion = require(script.Parent.Parent.visuals.button_motion)
local gradient_stroke = require(script.Parent.Parent.visuals.gradient_stroke)
local registry = require(script.Parent.registry)
local ui_blur = require(script.Parent.Parent.blur.ui_blur)

local create_element = React.createElement

const CONFIRM_SECONDS = 3
-- A confirmation this soon after arming comes from the same click, not a second one.
const MINIMUM_CONFIRM_DELAY = 0.2

-- There is no undo, so resetting takes a second click.
local function editor_reset_button(props: { LayoutOrder: number? })
	local armed, set_armed = React.useState(false)
	local armed_at = React.useRef(0)
	local function disarm_later()
		if not armed then
			return
		end
		local active = true
		local function disarm(): ()
			if active then
				set_armed(false)
			end
		end
		task.delay(CONFIRM_SECONDS, disarm)
		local function cancel(): ()
			active = false
		end
		return cancel
	end
	React.useEffect(disarm_later, { armed })
	local function on_activated(): ()
		if not armed then
			armed_at.current = os.clock()
			set_armed(true)
		elseif os.clock() - armed_at.current >= MINIMUM_CONFIRM_DELAY then
			set_armed(false)
			registry.reset()
		end
	end
	return create_element(animated_button, {
		LayoutOrder = props.LayoutOrder,
		Size = UDim2.fromOffset(130, 44),
		BackgroundColor3 = COLOURS.surface,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Text = if armed then "Sure?" else "Reset",
		TextSize = 24,
		TextColor3 = COLOURS.red_400,
		FontFace = FONTS.regular,
		[React.Event.Activated] = on_activated,
	}, {
		feedback = create_element(button_motion),
		corner = create_element("UICorner", { CornerRadius = UDim.new(1, 0) }),
		stroke = create_element(gradient_stroke, { colour = COLOURS.red_400, rotation = -90 }),
		blur = create_element(ui_blur),
	})
end

return editor_reset_button
