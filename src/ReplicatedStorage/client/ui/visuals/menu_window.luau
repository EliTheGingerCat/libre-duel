local ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
local React = require(ReplicatedStorage.Packages.react)
local animated_button = require(script.Parent.animated_button)
local button_motion = require(script.Parent.button_motion)
local gradient_stroke = require(script.Parent.gradient_stroke)
local shadow = require(script.Parent.shadow)
local ui_blur = require(script.Parent.Parent.blur.ui_blur)
local use_ui_motion = require(script.Parent.use_ui_motion)
local use_viewport_scale = require(script.Parent.use_viewport_scale)

local create_element = React.createElement

-- Space kept free around the window so it never touches the screen edges.
const SCREEN_MARGIN = 16

export type props = {
	name: string,
	title: string,
	size: Vector2?,
	enabled: boolean,
	display_order: number?,
	on_close: () -> (),
	children: unknown?,
}

local function menu_window(props: props)
	local size = props.size or Vector2.new(1200, 720)
	local motion = use_ui_motion(if props.enabled then 1 else 0, 0)
	local viewport_scale = math.min(1, use_viewport_scale())
	local screen_ref = React.useRef(nil :: ScreenGui?)
	local fit, set_fit = React.useBinding(1)
	-- The viewport scale is tuned for the HUD, so tall windows can still overflow small screens without this.
	local function track_fit()
		local screen = screen_ref.current
		assert(screen)
		local function update(): ()
			local available = screen.AbsoluteSize - Vector2.new(SCREEN_MARGIN * 2, SCREEN_MARGIN * 2)
			set_fit(math.max(0.001, math.min(available.X / size.X, available.Y / size.Y)))
		end
		local connection = screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
		update()
		local function disconnect(): ()
			connection:Disconnect()
		end
		return disconnect
	end
	React.useLayoutEffect(track_fit, { size.X, size.Y })
	local function window_scale(values: { motion: number, fit: number }): number
		return math.min(viewport_scale, values.fit) * (0.96 + 0.04 * values.motion)
	end
	local function window_position(value: number): UDim2
		return UDim2.new(0.5, 0, 0.5, 12 * (1 - value))
	end
	return create_element("ScreenGui", {
		ref = screen_ref,
		Name = props.name,
		Enabled = props.enabled,
		ResetOnSpawn = false,
		DisplayOrder = props.display_order or 10,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		background = create_element("TextButton", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Text = "",
			Modal = true,
			ZIndex = 0,
			[React.Event.Activated] = props.on_close,
		}),
		window = create_element("TextButton", {
			Text = "",
			AutoButtonColor = false,
			Selectable = false,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = motion:map(window_position),
			Size = UDim2.fromOffset(size.X, size.Y),
			BackgroundColor3 = COLOURS.surface,
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			Active = true,
		}, {
			scale = create_element(
				"UIScale",
				{ Scale = React.joinBindings({ motion = motion, fit = fit }):map(window_scale) }
			),
			corner = create_element("UICorner", { CornerRadius = UDim.new(0, 60) }),
			shadow = create_element(
				shadow,
				{ ShowBehindParent = false, BlurRadius = UDim.new(0, 8), Transparency = 0.3 }
			),
			stroke = create_element(gradient_stroke),
			blur = props.enabled and create_element(ui_blur),
			title = create_element("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 13),
				Size = UDim2.new(1, -100, 0, 48),
				BackgroundTransparency = 1,
				FontFace = FONTS.bold,
				Text = props.title,
				TextSize = 30,
				TextColor3 = Color3.new(1, 1, 1),
				ZIndex = 2,
			}),
			close_button = create_element(animated_button, {
				class_name = "ImageButton",
				Position = UDim2.new(1, -80, 0, 16),
				Size = UDim2.fromOffset(42, 42),
				BackgroundTransparency = 1,
				Image = "rbxassetid://72160170469319",
				ZIndex = 2,
				[React.Event.Activated] = props.on_close,
			}, { feedback = create_element(button_motion) }),
			content = create_element(React.Fragment, {}, props.children),
		}),
	})
end

return menu_window
