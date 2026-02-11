local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.vendor.ReactLua.React)

local create_element = React.createElement
local local_camera = workspace.CurrentCamera
local use_effect = React.useEffect
local use_state = React.useState

local intended_resolution = Vector2.new(1920, 1080)

local function scale_element()
	local scale, set_scale = use_state(1)

	use_effect(function()
		local function update_scale()
			local current_resolution = local_camera.ViewportSize

			set_scale(math.min(
				current_resolution.X / intended_resolution.X,
				current_resolution.Y / intended_resolution.Y
			))
		end

		update_scale()

		local connection = local_camera:GetPropertyChangedSignal("ViewportSize"):Connect(update_scale)

		local function destroy()
			connection:Disconnect()
		end

		return destroy
	end, {})

	return create_element("UIScale", {
		Scale = scale,
	})
end

return scale_element
