local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage.Packages.react)
local cursor_state = require(script.Parent.Parent.cursor_state)

local create_element = React.createElement

local function crosshair()
	local locked, set_locked = React.useState(false)
	local free, set_free = React.useState(false)

	local function bind_cursor()
		-- Runs last so it sees the mouse behaviour the camera scripts settled on this frame.
		local function update_cursor(): ()
			local is_free = cursor_state.is_free()
			local is_locked = not is_free and UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
			UserInputService.MouseIconEnabled = not is_locked
			set_locked(is_locked)
			set_free(is_free)
		end
		RunService:BindToRenderStep("cursor", Enum.RenderPriority.Last.Value, update_cursor)
		local function unbind(): ()
			RunService:UnbindFromRenderStep("cursor")
		end
		return unbind
	end
	React.useEffect(bind_cursor, {})

	return create_element(React.Fragment, nil, {
		crosshair = create_element(
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
		),
		-- A visible modal button is the engine's own way to free the mouse in first person. Forcing
		-- MouseBehavior to Default every frame fights the camera, and when the menu closes the cursor
		-- warps back to the centre and the camera reads that jump as a huge mouse movement.
		cursor_unlock = create_element(
			"ScreenGui",
			{
				Name = "CursorUnlock",
				ResetOnSpawn = false,
				Enabled = free,
			},
			create_element("TextButton", {
				Modal = true,
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(0, 0),
				Text = "",
				Selectable = false,
				AutoButtonColor = false,
			})
		),
	})
end

return crosshair
