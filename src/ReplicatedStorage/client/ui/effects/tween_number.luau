local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

local scale_animation_time = require(script.Parent.scale_animation_time)

-- Tweens a plain number, for values that aren't instance properties. Returns a function that stops it early.
local function tween_number(from: number, to: number, info: TweenInfo, on_step: (number) -> ()): () -> ()
	local time = scale_animation_time(info.Time)
	if GuiService.ReducedMotionEnabled or time <= 0 then
		on_step(to)
		local function nothing(): () end
		return nothing
	end
	local value = Instance.new("NumberValue")
	value.Value = from
	local function step(current: number): ()
		on_step(current)
	end
	local connection = value.Changed:Connect(step)
	local tween =
		TweenService:Create(value, TweenInfo.new(time, info.EasingStyle, info.EasingDirection), { Value = to })
	tween:Play()
	local function cancel(): ()
		connection:Disconnect()
		tween:Cancel()
		tween:Destroy()
		value:Destroy()
	end
	return cancel
end

return tween_number
