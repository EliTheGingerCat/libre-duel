const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")
const UserInputService = game:GetService("UserInputService")

const POPUP_LAYOUT = require(script.Parent.Parent.POPUP_LAYOUT)
const React = require(ReplicatedStorage.Packages.react)
const create_popup_progress_transparency = require(script.Parent.create_popup_progress_transparency)
const tween_number = require(script.Parent.Parent.Parent.effects.tween_number)

const create_element = React.createElement

const DRAIN_TWEEN_INFO =
	TweenInfo.new(POPUP_LAYOUT.PROGRESS_DRAIN_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

-- fills while its parent button is held and calls on_completed once full, letting go early drains it again
const function popup_button_hold_progress(props: {
	colour: Color3,
	hold_time: number,
	on_completed: () -> (),
})
	const frame_ref = React.useRef(nil :: Frame?)
	const progress, set_progress = React.useBinding(0)

	const function mount()
		const frame = frame_ref.current
		assert(frame)
		const button = frame.Parent
		assert(button and button:IsA("GuiButton"))
		const drag_detector = button:FindFirstChildOfClass("UIDragDetector")
		assert(drag_detector)

		local is_held = false
		local is_completed = false
		local cancel_drain: (() -> ())? = nil
		local fill_connection: RBXScriptConnection? = nil

		const function stop_drain(): ()
			if cancel_drain then
				cancel_drain()
				cancel_drain = nil
			end
		end

		const function stop_fill(): ()
			if fill_connection then
				fill_connection:Disconnect()
				fill_connection = nil
			end
		end

		-- filled by elapsed time instead of a tween so reduced motion cannot skip the hold
		const function fill(delta_time: number): ()
			const next_progress = math.min(progress:getValue() + delta_time / props.hold_time, 1)
			set_progress(next_progress)
			if next_progress >= 1 then
				stop_fill()
				is_completed = true
				props.on_completed()
			end
		end

		const function begin_hold(): ()
			if is_held or is_completed or not button.Interactable or not button.Visible then
				return
			end
			is_held = true
			stop_drain()
			fill_connection = RunService.Heartbeat:Connect(fill)
		end

		const function end_hold(): ()
			if not is_held then
				return
			end
			is_held = false
			stop_fill()
			if is_completed then
				return
			end
			cancel_drain = tween_number(progress:getValue(), 0, DRAIN_TWEEN_INFO, set_progress)
		end

		const function begin_gamepad_hold(input: InputObject): ()
			if input.KeyCode == Enum.KeyCode.ButtonA then
				begin_hold()
			end
		end

		const function end_gamepad_hold(input: InputObject): ()
			if input.KeyCode == Enum.KeyCode.ButtonA then
				end_hold()
			end
		end

		const connections = {
			drag_detector.DragStart:Connect(begin_hold),
			drag_detector.DragEnd:Connect(end_hold),
			button.InputBegan:Connect(begin_gamepad_hold),
			UserInputService.InputEnded:Connect(end_gamepad_hold),
			UserInputService.WindowFocusReleased:Connect(end_hold),
			button.SelectionLost:Connect(end_hold),
		}

		const function disconnect(): ()
			for _, connection in connections do
				connection:Disconnect()
			end
			stop_fill()
			stop_drain()
		end

		return disconnect
	end
	React.useLayoutEffect(mount, {})

	return create_element("Frame", {
		Name = "progress",
		ref = frame_ref,
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
	}, {
		corner = create_element("UICorner", { CornerRadius = UDim.new(0, POPUP_LAYOUT.ROW_CORNER_RADIUS) }),
		gradient = create_element("UIGradient", {
			Color = ColorSequence.new(props.colour),
			Transparency = progress:map(create_popup_progress_transparency),
		}),
	})
end

return popup_button_hold_progress
