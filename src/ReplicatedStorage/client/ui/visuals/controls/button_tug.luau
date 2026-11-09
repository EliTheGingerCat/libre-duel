local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

local scale_animation_time = require(script.Parent.Parent.Parent.effects.scale_animation_time)

type controller = {
	begin: (Vector2) -> (),
	drag: (Vector2) -> (),
	restore: (boolean?) -> (),
	disconnect: () -> (),
}

local function button_tug(button: GuiButton): controller
	local resting_position, resting_size = button.Position, button.Size
	local origin, base_size = Vector2.zero, Vector2.zero
	local parent_scale = 1
	local tween: Tween? = nil
	local completion: RBXScriptConnection? = nil
	local function cancel(): ()
		if completion then
			completion:Disconnect()
			completion = nil
		end
		if tween then
			tween:Cancel()
			tween:Destroy()
			tween = nil
		end
	end
	local function begin(position: Vector2): ()
		cancel()
		origin = position
		parent_scale = 1
		local ancestor = button.Parent
		while ancestor do
			local scale = ancestor:FindFirstChildOfClass("UIScale")
			if scale then
				parent_scale *= scale.Scale
			end
			ancestor = ancestor.Parent
		end
		local slot = button.Parent
		assert(slot and slot:IsA("GuiObject"))
		base_size = slot.AbsoluteSize / math.max(parent_scale, 0.001)
	end
	local function drag(position: Vector2): ()
		if GuiService.ReducedMotionEnabled then
			return
		end
		local delta = (position - origin) / math.max(parent_scale, 0.001)
		local offset = delta / (8 + delta.Magnitude / 24)
		button.Position = resting_position + UDim2.fromOffset(offset.X * 0.5, offset.Y * 0.5)
		local stretch = Vector2.new(math.abs(offset.X), math.abs(offset.Y)) / 24 * 0.025
		button.Size = UDim2.fromOffset(base_size.X * (1 + stretch.X), base_size.Y * (1 + stretch.Y))
	end
	local function restore(released: boolean?): ()
		cancel()
		if GuiService.ReducedMotionEnabled then
			button.Position = resting_position
			button.Size = resting_size
		elseif button.Position ~= resting_position or button.Size ~= resting_size then
			local target_size = if base_size == Vector2.zero
				then resting_size
				else UDim2.fromOffset(base_size.X, base_size.Y)
			local next_tween = TweenService:Create(
				button,
				TweenInfo.new(
					scale_animation_time(if released then 0.4 else 0.2),
					if released then Enum.EasingStyle.Back else Enum.EasingStyle.Quint,
					Enum.EasingDirection.Out
				),
				{ Position = resting_position, Size = target_size }
			)
			local function complete(state: Enum.PlaybackState): ()
				if state == Enum.PlaybackState.Completed then
					button.Size = resting_size
				end
			end
			tween = next_tween
			completion = next_tween.Completed:Once(complete)
			next_tween:Play()
		end
	end
	local function disconnect(): ()
		cancel()
		button.Position = resting_position
		button.Size = resting_size
	end
	return { begin = begin, drag = drag, restore = restore, disconnect = disconnect }
end

return button_tug
