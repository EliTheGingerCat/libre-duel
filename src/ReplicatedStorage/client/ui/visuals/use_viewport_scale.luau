local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local get_reference_resolution = require(script.Parent.REFERENCE_RESOLUTIONS)
local input_device = require(ReplicatedStorage.client.util.input_device)

local function use_viewport_scale(): number
	local factor, set_factor = React.useState(1)
	local function subscribe()
		local camera = workspace.CurrentCamera
		if not camera then
			return
		end
		local function update(): ()
			local size = camera.ViewportSize
			local reference = get_reference_resolution("full", input_device.current)
			set_factor(math.min(size.X / reference.X, size.Y / reference.Y))
		end
		local connection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(update)
		local device_connection = input_device.changed:Connect(update)
		update()
		local function disconnect(): ()
			connection:Disconnect()
			device_connection:Disconnect()
		end
		return disconnect
	end
	React.useEffect(subscribe, {})
	return factor
end

return use_viewport_scale
