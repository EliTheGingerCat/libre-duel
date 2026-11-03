local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage.Packages.react)
local get_drag_offset = require(script.Parent.get_drag_offset)

type props = { on_activated: ((GuiButton, InputObject?) -> ())? }

local function button_input(props: props)
	local ref = React.useRef(nil :: UIDragDetector?)
	local input = React.useRef(nil :: InputObject?)
	local origin = React.useRef(Vector2.zero)
	local armed = React.useRef(false)
	local moved = React.useRef(false)
	local function mount()
		local detector = ref.current
		assert(detector)
		local button = detector.Parent
		assert(button and button:IsA("GuiButton"))
		local function capture(next_input: InputObject): ()
			input.current = next_input
		end
		local function cancel(): ()
			armed.current = false
		end
		local connections = { button.InputBegan:Connect(capture), UserInputService.WindowFocusReleased:Connect(cancel) }
		local function disconnect(): ()
			for _, connection in connections do
				connection:Disconnect()
			end
		end
		return disconnect
	end
	React.useLayoutEffect(mount, {})
	local function begin(_detector: UIDragDetector, position: Vector2): ()
		origin.current = position
		armed.current = true
		moved.current = false
	end
	local function drag(_detector: UIDragDetector, position: Vector2): ()
		moved.current = moved.current or (position - origin.current).Magnitude >= 8
	end
	local function finish(detector: UIDragDetector, position: Vector2): ()
		local clicked = armed.current and not moved.current and (position - origin.current).Magnitude < 8
		armed.current = false
		local button = detector.Parent
		assert(button and button:IsA("GuiButton"))
		local source = input.current
		if
			source
			and source.UserInputType ~= Enum.UserInputType.MouseButton1
			and source.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end
		local point = get_drag_offset(button, position)
		local inside = point.X >= 0
			and point.Y >= 0
			and point.X <= button.AbsoluteSize.X
			and point.Y <= button.AbsoluteSize.Y
		if clicked and inside and button.Interactable and button.Visible and props.on_activated then
			props.on_activated(button, source)
		end
	end
	return React.createElement("UIDragDetector", {
		Name = "drag_detector",
		ref = ref,
		ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomOffset,
		[React.Event.DragStart] = begin,
		[React.Event.DragContinue] = drag,
		[React.Event.DragEnd] = finish,
	})
end

return button_input
