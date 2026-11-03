local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage.Packages.react)
local cursor_state = require(script.Parent.Parent.cursor_state)

local create_element = React.createElement

local function crosshair()
	local locked, set_locked = React.useState(false)

	local function bind_cursor()
		-- Runs last so it overrides the camera scripts, which lock the mouse every frame in first person.
		local function update_cursor(): ()
			local free = cursor_state.is_free()
			if free then
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			end
			local is_locked = not free and UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
			UserInputService.MouseIconEnabled = not is_locked
			set_locked(is_locked)
		end
		RunService:BindToRenderStep("cursor", Enum.RenderPriority.Last.Value, update_cursor)
		local function unbind(): ()
			RunService:UnbindFromRenderStep("cursor")
		end
		return unbind
	end
	React.useEffect(bind_cursor, {})

	return create_element(
		"ScreenGui",
		{
			Name = "Crosshair",
			ScreenInsets = "None",
			ResetOnSpawn = false,
			Enabled = locked,
		},
		create_element("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.fromOffset(24, 24),
			Image = "rbxassetid://126059733701198",
			ZIndex = -math.huge,
		})
	)
end

return crosshair
