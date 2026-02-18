local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.Packages.react)
local ReactRoblox = require(ReplicatedStorage.Packages["react-roblox"])

local create_element = React.createElement
local useState = React.useState
local useEffect = React.useEffect

local function crosshair()
	local locked, setLocked = useState(false)

	useEffect(function()
		local conn = RunService.RenderStepped:Connect(function()
			local isLocked = UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
			setLocked(isLocked)
			UserInputService.MouseIconEnabled = not isLocked
		end)
		return function()
			conn:Disconnect()
		end
	end, {})

	return create_element(
		"ScreenGui",
		{
			Name = "Crosshair",
			ScreenInsets = "None",
			ResetOnSpawn = false,
			Enabled = locked,
		},
		create_element(
			"ImageLabel",
			{
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.fromOffset(24, 24),
				Image = "rbxassetid://126059733701198",
				ZIndex = -math.huge,
			}
		)
	)
end

return crosshair
