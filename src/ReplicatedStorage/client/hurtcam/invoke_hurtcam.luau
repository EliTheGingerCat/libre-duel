const TweenService = game:GetService("TweenService")

local CurrentCamera = game.Workspace.CurrentCamera

-- TweenService really doesn't let you tween standard variables in the big 26...
local NumberValue = Instance.new("NumberValue")

local current_tween: Tween? = nil

const function invoke_hurtcam(strength: number, duration_s: number)
    if current_tween then current_tween:Cancel() end
    local tweenInfo = TweenInfo.new(duration_s, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)

    NumberValue.Value = strength

    local goal = {}
    goal.Value = 0

    local tween = TweenService:Create(NumberValue, tweenInfo, goal)
    tween:Play()
    current_tween = tween
end

game:GetService("RunService").RenderStepped:connect(function()
	local x,y,z = CurrentCamera.CFrame:ToEulerAnglesXYZ()
    CurrentCamera.CFrame = CFrame.new(CurrentCamera.CFrame.Position) * CFrame.Angles(x,y,0)
    CurrentCamera.CFrame = CFrame.new(CurrentCamera.CFrame.Position) * CFrame.Angles(x,y,z) * CFrame.Angles(0,0,math.rad(NumberValue.Value))
end)

return invoke_hurtcam
