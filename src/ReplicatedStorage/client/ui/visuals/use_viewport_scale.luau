local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)

local function use_viewport_scale(): number
	local factor, set_factor = React.useState(1)
	local function subscribe()
		local camera = workspace.CurrentCamera
		if not camera then
			return
		end
		local function update(): ()
			local size = camera.ViewportSize
			set_factor(math.min(size.X / 1920, size.Y / 1080))
		end
		local connection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(update)
		update()
		local function disconnect(): ()
			connection:Disconnect()
		end
		return disconnect
	end
	React.useEffect(subscribe, {})
	return factor
end

return use_viewport_scale
