const RunService = game:GetService("RunService")
const TweenService = game:GetService("TweenService")

const current_camera = workspace.CurrentCamera

-- TweenService really doesn't let you tween standard variables in the big 26...
const roll_value = Instance.new("NumberValue")

local current_tween: Tween? = nil

const function invoke_hurtcam(strength: number, duration_s: number): ()
	if current_tween then
		current_tween:Cancel()
	end
	const tween_info = TweenInfo.new(duration_s, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)

	roll_value.Value = strength

	const tween = TweenService:Create(roll_value, tween_info, { Value = 0 })
	tween:Play()
	current_tween = tween
end

const function apply_roll(): ()
	const x, y, z = current_camera.CFrame:ToEulerAnglesXYZ()
	const position = current_camera.CFrame.Position
	current_camera.CFrame = CFrame.new(position) * CFrame.Angles(x, y, z) * CFrame.Angles(0, 0, math.rad(roll_value.Value))
end

RunService.RenderStepped:Connect(apply_roll)

return invoke_hurtcam
