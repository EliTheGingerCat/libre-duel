local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage.Packages.react)

-- Add as a child of a button; activation stays with the owning component.
local function button_motion()
	local ref = React.useRef(nil :: UIScale?)
	local function mount()
		local scale = ref.current
		assert(scale)
		local button = scale.Parent
		assert(button and button:IsA("GuiButton"))
		local resting_colour = button.BackgroundColor3
		local resting_position = button.Position
		local resting_size = button.Size
		local stretch_size = resting_size
		local auto_colour = button.AutoButtonColor
		button.AutoButtonColor = false
		local hovered, focused = false, false
		local pressed: InputObject? = nil
		local scale_tween: Tween? = nil
		local light_tween: Tween? = nil
		local position_tween: Tween? = nil
		local drag_connection: RBXScriptConnection? = nil
		local size_connection: RBXScriptConnection? = nil

		local function stop_tug(released: boolean?): ()
			if drag_connection then
				drag_connection:Disconnect()
				drag_connection = nil
			end
			if position_tween then
				if size_connection then
					size_connection:Disconnect()
					size_connection = nil
				end
				position_tween:Cancel()
				position_tween:Destroy()
				position_tween = nil
			end
			if GuiService.ReducedMotionEnabled then
				button.Position = resting_position
				button.Size = resting_size
			elseif button.Position ~= resting_position or button.Size ~= resting_size then
				position_tween = TweenService:Create(
					button,
					TweenInfo.new(
						if released then 0.4 else 0.2,
						if released then Enum.EasingStyle.Back else Enum.EasingStyle.Quint,
						Enum.EasingDirection.Out
					),
					{ Position = resting_position, Size = stretch_size }
				)
				local function restore_size(state: Enum.PlaybackState): ()
					if state == Enum.PlaybackState.Completed then
						button.Size = resting_size
					end
				end
				size_connection = position_tween.Completed:Once(restore_size)
				position_tween:Play()
			end
		end

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
			local down = active and pressed ~= nil
			if not down or GuiService.ReducedMotionEnabled then
				stop_tug(released)
			end
			local lit = active and (hovered or focused or down)
			local amount = if down then 0.12 elseif lit then 0.055 else 0
			local factor = if down then 1.035 elseif lit then 1.02 else 1
			local colour = resting_colour:Lerp(Color3.new(1, 1, 1), amount)
			if GuiService.ReducedMotionEnabled then
				scale.Scale = 1
				button.BackgroundColor3 = colour
				return
			end
			local info = TweenInfo.new(if down then 0.09 else 0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			local scale_info = if released and active
				then TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				else info
			scale_tween = TweenService:Create(scale, scale_info, { Scale = factor })
			light_tween = TweenService:Create(button, info, { BackgroundColor3 = colour })
			scale_tween:Play()
			light_tween:Play()
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
			pressed = nil
			update()
		end
		local function begin(input: InputObject): ()
			if pressed or not button.Interactable or not button.Visible then
				return
			end
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
				or input.KeyCode == Enum.KeyCode.ButtonA
			then
				pressed = input
				stop_tug()
				if position_tween then
					if size_connection then
						size_connection:Disconnect()
						size_connection = nil
					end
					position_tween:Cancel()
					position_tween:Destroy()
					position_tween = nil
				end
				if not GuiService.ReducedMotionEnabled and input.KeyCode ~= Enum.KeyCode.ButtonA then
					local origin = Vector2.new(input.Position.X, input.Position.Y)
					local parent_scale = 1
					local ancestor = button.Parent
					while ancestor do
						local ancestor_scale = ancestor:FindFirstChildOfClass("UIScale")
						if ancestor_scale then
							parent_scale *= ancestor_scale.Scale
						end
						ancestor = ancestor.Parent
					end
					local slot = button.Parent
					assert(slot and slot:IsA("GuiObject"))
					local base_size = slot.AbsoluteSize / math.max(parent_scale, 0.001)
					-- An explicit size also lets automatically sized text buttons stretch.
					stretch_size = UDim2.fromOffset(base_size.X, base_size.Y)
					local function drag(changed: InputObject): ()
						if
							(input.UserInputType == Enum.UserInputType.Touch and changed ~= input)
							or (
								input.UserInputType == Enum.UserInputType.MouseButton1
								and changed.UserInputType ~= Enum.UserInputType.MouseMovement
							)
						then
							return
						end
						local delta = (Vector2.new(changed.Position.X, changed.Position.Y) - origin)
							/ math.max(parent_scale, 0.001)
						-- Resistance increases with distance and approaches a 24-pixel limit.
						local offset = delta / (8 + delta.Magnitude / 24)
						button.Position = resting_position + UDim2.fromOffset(offset.X * 0.5, offset.Y * 0.5)
						local stretch = Vector2.new(math.abs(offset.X), math.abs(offset.Y)) / 24 * 0.025
						button.Size = UDim2.fromOffset(base_size.X * (1 + stretch.X), base_size.Y * (1 + stretch.Y))
					end
					drag_connection = UserInputService.InputChanged:Connect(drag)
				end
				update()
			end
		end
		local function finish(input: InputObject): ()
			if input == pressed then
				pressed = nil
				update(true)
			end
		end
		local function reset(): ()
			hovered = false
			focused = false
			pressed = nil
			update()
		end
		local connections = {
			button.MouseEnter:Connect(enter),
			button.MouseLeave:Connect(leave),
			button.SelectionGained:Connect(focus),
			button.SelectionLost:Connect(blur),
			button.InputBegan:Connect(begin),
			UserInputService.InputEnded:Connect(finish),
			UserInputService.WindowFocusReleased:Connect(reset),
			button:GetPropertyChangedSignal("Interactable"):Connect(reset),
			button:GetPropertyChangedSignal("Visible"):Connect(reset),
			GuiService:GetPropertyChangedSignal("ReducedMotionEnabled"):Connect(update),
		}
		local function disconnect(): ()
			if size_connection then
				size_connection:Disconnect()
			end
			if drag_connection then
				drag_connection:Disconnect()
			end
			if position_tween then
				position_tween:Cancel()
				position_tween:Destroy()
			end
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
			button.Position = resting_position
			button.Size = resting_size
			button.AutoButtonColor = auto_colour
		end
		return disconnect
	end
	React.useLayoutEffect(mount, {})
	return React.createElement("UIScale", { ref = ref })
end

return button_motion
