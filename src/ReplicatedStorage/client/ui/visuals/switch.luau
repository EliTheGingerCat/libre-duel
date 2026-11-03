local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local surface = require(script.Parent.controls.surface)
local use_ui_motion = require(script.Parent.use_ui_motion)

local function switch(props: { active: boolean?, on_changed: ((boolean) -> ())? })
	local stored, set_stored = React.useState(props.active == true)
	local active = if props.on_changed then props.active == true else stored
	local dragging, set_dragging = React.useState(false)
	local progress, set_progress = React.useBinding(if active then 1 else 0)
	local gesture =
		React.useRef({ value = if active then 1 else 0, origin = Vector2.zero, grab_offset = 0, moved = false })
	local motion = use_ui_motion(if active then 1 else 0, nil, if dragging then nil else gesture.current.value)
	local function choose(next_active: boolean): ()
		if not dragging then
			gesture.current.value = motion:getValue()
		end
		if props.on_changed then
			props.on_changed(next_active)
		else
			set_stored(next_active)
		end
	end
	local function toggle(_button: GuiButton, _input: InputObject): ()
		choose(not active)
	end
	local function amount(values: { motion: number, progress: number }): number
		return if dragging then values.progress else values.motion
	end
	local current = React.joinBindings({ motion = motion, progress = progress }):map(amount)
	local function position(amount: number): UDim2
		return UDim2.new(amount, 24 - 48 * amount, 0.5, 0)
	end
	local function colour(amount: number): Color3
		local yellow = Color3.new(1, 0.85, 0)
		return if amount < 0.5
			then Color3.new(1, 65 / 255, 65 / 255):Lerp(yellow, amount * 2)
			else yellow:Lerp(Color3.new(60 / 255, 1, 0), (amount - 0.5) * 2)
	end
	local function begin(detector: UIDragDetector, point: Vector2): ()
		gesture.current.origin = point
		gesture.current.moved = false
		local thumb = detector.Parent :: GuiObject
		gesture.current.grab_offset = point.X - thumb.AbsolutePosition.X - thumb.AbsoluteSize.X / 2
		gesture.current.value = motion:getValue()
		set_progress(gesture.current.value)
		set_dragging(true)
	end
	local function drag(detector: UIDragDetector, point: Vector2): ()
		gesture.current.moved = gesture.current.moved or (point - gesture.current.origin).Magnitude >= 4
		local thumb = detector.Parent
		assert(thumb)
		local track = thumb.Parent :: GuiObject
		local factor = track.AbsoluteSize.X / 78
		local amount = math.clamp(
			(point.X - gesture.current.grab_offset - track.AbsolutePosition.X - 24 * factor) / math.max(1, 30 * factor),
			0,
			1
		)
		gesture.current.value = amount
		set_progress(amount)
	end
	local function finish(): ()
		choose(if gesture.current.moved then gesture.current.value >= 0.5 else not active)
		set_dragging(false)
	end
	local function key(_button: GuiButton, input: InputObject): ()
		if input.KeyCode == Enum.KeyCode.Left or input.KeyCode == Enum.KeyCode.DPadLeft then
			choose(false)
		elseif input.KeyCode == Enum.KeyCode.Right or input.KeyCode == Enum.KeyCode.DPadRight then
			choose(true)
		end
	end
	return React.createElement("TextButton", {
		Name = "switch",
		Size = UDim2.fromOffset(78, 38),
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = current:map(colour),
		BackgroundTransparency = 0.4,
		[React.Event.Activated] = toggle,
		[React.Event.InputBegan] = key,
	}, {
		surface = React.createElement(surface),
		thumb = React.createElement("TextButton", {
			Name = "thumb",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = current:map(position),
			Size = UDim2.fromOffset(38, 30),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Text = "",
			BorderSizePixel = 0,
			AutoButtonColor = false,
			[React.Event.InputBegan] = key,
		}, {
			corner = React.createElement("UICorner", { CornerRadius = UDim.new(1, 0) }),
			drag = React.createElement("UIDragDetector", {
				CursorIcon = "rbxasset://textures/Cursors/KeyboardMouse/ArrowCursor.png",
				DragStyle = Enum.UIDragDetectorDragStyle.TranslateLine,
				DragAxis = Vector2.new(1, 0),
				ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomOffset,
				[React.Event.DragStart] = begin,
				[React.Event.DragContinue] = drag,
				[React.Event.DragEnd] = finish,
			}),
		}),
	})
end

return switch
