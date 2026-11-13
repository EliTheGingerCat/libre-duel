local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local get_reference_resolution = require(script.Parent.REFERENCE_RESOLUTIONS)
local input_device = require(ReplicatedStorage.client.util.input_device)
local tween_number = require(script.Parent.Parent.effects.tween_number)

-- Switching devices wobbles the UI into its new size instead of snapping.
const DEVICE_TWEEN = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

const function use_viewport_scale(): number
	local factor, set_factor = React.useState(1)
	const function subscribe()
		local camera = workspace.CurrentCamera
		if not camera then
			return
		end
		local current = 1
		local cancel_tween: (() -> ())? = nil
		const function stop_tween(): ()
			if cancel_tween then
				cancel_tween()
				cancel_tween = nil
			end
		end
		const function set(value: number): ()
			current = value
			set_factor(value)
		end
		const function get_target(): number
			local size = camera.ViewportSize
			local reference = get_reference_resolution("full", input_device.current)
			return math.min(size.X / reference.X, size.Y / reference.Y)
		end
		-- resizing the window follows it directly
		const function update(): ()
			stop_tween()
			set(get_target())
		end
		-- Re-rendering the UI every frame is normally a no, but this tween only runs when the input device changes, which is rare.
		-- If it ever shows up in the profiler, return a binding instead of state.
		const function on_device_changed(): ()
			stop_tween()
			cancel_tween = tween_number(current, get_target(), DEVICE_TWEEN, set)
		end
		local connection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(update)
		local device_connection = input_device.changed:Connect(on_device_changed)
		update()
		const function disconnect(): ()
			connection:Disconnect()
			device_connection:Disconnect()
			stop_tween()
		end
		return disconnect
	end
	React.useEffect(subscribe, {})
	return factor
end

return use_viewport_scale
