local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage.Packages.react)
local button_tug = require(script.Parent.controls.button_tug)
local scale_animation_time = require(script.Parent.Parent.effects.scale_animation_time)

local function button_motion(props: { animate_colour: boolean? })
	local ref = React.useRef(nil :: UIScale?)
	local function mount()
		local scale = ref.current
		assert(scale)
		local button = scale.Parent
		assert(button and button:IsA("GuiButton"))
		local resting_colour = button.BackgroundColor3
		local tug = button_tug(button)
		local auto_colour = button.AutoButtonColor
		button.AutoButtonColor = false
		local hovered, focused = false, false
		local pressed = false
		local scale_tween: Tween? = nil
		local light_tween: Tween? = nil
		local function update(released: boolean?): ()
			if scale_tween then
				scale_tween:Cancel()
				scale_tween:Destroy()
			end
			if light_tween then
				light_tween:Cancel()
				light_tween:Destroy()
			end
			local active = button.Interactable and button.Visible
			local down = active and pressed
			if not down or GuiService.ReducedMotionEnabled then
				tug.restore(released)
			end
			local lit = active and (hovered or focused or down)
			local amount = if down then 0.12 elseif lit then 0.055 else 0
			local factor = if down then 1.035 elseif lit then 1.02 else 1
			local colour = resting_colour:Lerp(Color3.new(1, 1, 1), amount)
			if GuiService.ReducedMotionEnabled then
				scale.Scale = 1
				if props.animate_colour ~= false then
					button.BackgroundColor3 = colour
				end
				return
			end
			local info = TweenInfo.new(
				scale_animation_time(if down then 0.09 else 0.24),
				Enum.EasingStyle.Quint,
				Enum.EasingDirection.Out
			)
			local scale_info = if released and active
				then TweenInfo.new(scale_animation_time(0.45), Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				else info
			local next_scale_tween = TweenService:Create(scale, scale_info, { Scale = factor })
			scale_tween = next_scale_tween
			if props.animate_colour ~= false then
				light_tween = TweenService:Create(button, info, { BackgroundColor3 = colour })
			end
			next_scale_tween:Play()
			if light_tween then
				light_tween:Play()
			end
		end
		local function enter(): ()
			hovered = true
			update()
		end
		local function leave(): ()
			hovered = false
			update()
		end
		local function focus(): ()
			focused = true
			update()
		end
		local function blur(): ()
			focused = false
			pressed = false
			update()
		end
		local function begin(position: Vector2): ()
			if pressed or not button.Interactable or not button.Visible then
				return
			end
			pressed = true
			tug.begin(position)
			update()
		end
		local function drag(position: Vector2): ()
			if pressed then
				tug.drag(position)
			end
		end
		local function finish(): ()
			pressed = false
			update(true)
		end
		local function begin_key(input: InputObject): ()
			if input.KeyCode == Enum.KeyCode.ButtonA then
				begin(Vector2.zero)
			end
		end
		local function finish_key(input: InputObject): ()
			if input.KeyCode == Enum.KeyCode.ButtonA then
				finish()
			end
		end
		local function reset(): ()
			hovered = false
			focused = false
			pressed = false
			update()
		end
		local detector = button:FindFirstChildOfClass("UIDragDetector")
		assert(detector)
		local connections = {
			detector.DragStart:Connect(begin),
			detector.DragContinue:Connect(drag),
			detector.DragEnd:Connect(finish),
			button.MouseEnter:Connect(enter),
			button.MouseLeave:Connect(leave),
			button.SelectionGained:Connect(focus),
			button.SelectionLost:Connect(blur),
			button.InputBegan:Connect(begin_key),
			UserInputService.InputEnded:Connect(finish_key),
			UserInputService.WindowFocusReleased:Connect(reset),
			button:GetPropertyChangedSignal("Interactable"):Connect(reset),
			button:GetPropertyChangedSignal("Visible"):Connect(reset),
			GuiService:GetPropertyChangedSignal("ReducedMotionEnabled"):Connect(update),
		}
		local function disconnect(): ()
			tug.disconnect()
			for _, connection in connections do
				connection:Disconnect()
			end
			if scale_tween then
				scale_tween:Cancel()
				scale_tween:Destroy()
			end
			if light_tween then
				light_tween:Cancel()
				light_tween:Destroy()
			end
			button.BackgroundColor3 = resting_colour
			button.AutoButtonColor = auto_colour
		end
		return disconnect
	end
	React.useLayoutEffect(mount, {})
	return React.createElement("UIScale", { ref = ref })
end

return button_motion
