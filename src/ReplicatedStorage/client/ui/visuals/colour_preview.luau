local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage.Packages.react)
local ReactRoblox = require(ReplicatedStorage.Packages["react-roblox"])
local alpha_grid = require(script.Parent.controls.alpha_grid)
local animated_button = require(script.Parent.animated_button)
local button_motion = require(script.Parent.button_motion)
local picker = require(script.Parent.colour_picker.picker)
local surface = require(script.Parent.controls.surface)
local use_ui_motion = require(script.Parent.use_ui_motion)
local use_viewport_scale = require(script.Parent.use_viewport_scale)

const RADIUS = 19

local function colour_preview(props: { colour: Color3?, alpha: number?, on_changed: ((Color3, number) -> ())? })
	local stored, set_stored = React.useState(props.colour or Color3.new(1, 0, 0))
	local stored_alpha, set_stored_alpha = React.useState(props.alpha or 1)
	local position, set_position = React.useState(nil :: Vector2?)
	local colour = if props.on_changed then props.colour or stored else stored
	local alpha = if props.on_changed then props.alpha or 1 else stored_alpha
	local scale = math.min(1, use_viewport_scale())
	local motion = use_ui_motion(if position then 1 else 0, 0)
	local function animated_scale(value: number): number
		return scale * (0.96 + 0.04 * value)
	end
	local function changed(next_colour: Color3, next_alpha: number): ()
		if props.on_changed then
			props.on_changed(next_colour, next_alpha)
		else
			set_stored(next_colour)
			set_stored_alpha(next_alpha)
		end
	end
	local function close(): ()
		set_position(nil)
	end
	local function open(button: GuiButton, input: InputObject?): ()
		local point = UserInputService:GetMouseLocation()
		if input and input.UserInputType == Enum.UserInputType.Touch then
			point = Vector2.new(input.Position.X, input.Position.Y)
		elseif input and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			point = button.AbsolutePosition + GuiService:GetGuiInset() + button.AbsoluteSize / 2
		end
		set_position(point)
	end
	local function subscribe()
		if not position then
			return
		end
		local function key(input: InputObject, processed: boolean): ()
			if not processed and (input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB) then
				close()
			end
		end
		local connection = UserInputService.InputBegan:Connect(key)
		local function disconnect(): ()
			connection:Disconnect()
		end
		return disconnect
	end
	React.useEffect(subscribe, { position })
	local viewport = if workspace.CurrentCamera then workspace.CurrentCamera.ViewportSize else Vector2.new(1920, 1080)
	local point = position or Vector2.zero
	local clamped = Vector2.new(
		math.clamp(point.X, 8, math.max(8, viewport.X - 300 * scale - 8)),
		math.clamp(point.Y, 8, math.max(8, viewport.Y - 425 * scale - 8))
	)
	return React.createElement(React.Fragment, {}, {
		preview = React.createElement(animated_button, {
			Name = "colour_preview",
			Size = UDim2.fromOffset(78, 38),
			BackgroundTransparency = 1,
			Text = "",
			[React.Event.Activated] = open,
		}, {
			motion = React.createElement(button_motion, { animate_colour = false }),
			surface = React.createElement(surface, { radius = RADIUS }),
			grid = React.createElement(alpha_grid, { radius = RADIUS }, {
				colour = React.createElement("Frame", {
					Size = UDim2.fromScale(1, 1),
					BackgroundColor3 = colour,
					BackgroundTransparency = 1 - alpha,
					BorderSizePixel = 0,
				}, { corner = React.createElement("UICorner", { CornerRadius = UDim.new(0, RADIUS) }) }),
			}),
		}),
		popup = position and ReactRoblox.createPortal(
			React.createElement("ScreenGui", {
				Name = "ColourPicker",
				ResetOnSpawn = false,
				IgnoreGuiInset = true,
				DisplayOrder = 40,
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			}, {
				outside = React.createElement("TextButton", {
					ZIndex = 0,
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					Text = "",
					[React.Event.Activated] = close,
				}),
				anchor = React.createElement("Frame", {
					ZIndex = 1,
					Position = UDim2.fromOffset(clamped.X, clamped.Y),
					Size = UDim2.fromOffset(300, 425),
					BackgroundTransparency = 1,
				}, {
					scale = React.createElement("UIScale", { Scale = motion:map(animated_scale) }),
					picker = React.createElement(picker, { colour = colour, alpha = alpha, on_changed = changed }),
				}),
			}),
			Players.LocalPlayer:WaitForChild("PlayerGui")
		),
	})
end

return colour_preview
