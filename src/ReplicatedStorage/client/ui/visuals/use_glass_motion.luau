local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local React = require(ReplicatedStorage.Packages.react)

-- Bindings update the native properties without rendering React on every frame.
local function use_glass_motion(target: number, initial: number?)
	local value = React.useRef(nil :: NumberValue?)
	local binding, update = React.useBinding(initial or target)

	local function mount()
		local driver = Instance.new("NumberValue")
		driver.Value = initial or target
		value.current = driver
		local connection = driver.Changed:Connect(update)
		local function disconnect(): ()
			connection:Disconnect()
			driver:Destroy()
			value.current = nil
		end
		return disconnect
	end
	React.useLayoutEffect(mount, {})

	local function animate()
		local driver = value.current
		assert(driver)
		local tween =
			TweenService:Create(driver, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Value = target,
			})
		local function apply_preference(): ()
			if GuiService.ReducedMotionEnabled then
				tween:Cancel()
				driver.Value = target
			else
				tween:Play()
			end
		end
		local connection = GuiService:GetPropertyChangedSignal("ReducedMotionEnabled"):Connect(apply_preference)
		apply_preference()
		local function disconnect(): ()
			connection:Disconnect()
			tween:Cancel()
			tween:Destroy()
		end
		return disconnect
	end
	React.useLayoutEffect(animate, { target })
	return binding
end

return use_glass_motion
