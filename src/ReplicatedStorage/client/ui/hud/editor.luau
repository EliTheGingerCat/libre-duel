local ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
local React = require(ReplicatedStorage.Packages.react)
local animated_button = require(script.Parent.Parent.visuals.animated_button)
local button_motion = require(script.Parent.Parent.visuals.button_motion)
local editor_state = require(script.Parent.editor_state)
local gradient_stroke = require(script.Parent.Parent.visuals.gradient_stroke)
local mount_editor = require(script.Parent.mount_editor)
local ui_blur = require(script.Parent.Parent.blur.ui_blur)

local create_element = React.createElement

local function leave_editor(): ()
	editor_state.request_enabled(false)
end

local function editor()
	local ref = React.useRef(nil :: ScreenGui?)
	local content_visible, set_content_visible = React.useBinding(true)
	local function mount()
		local screen = ref.current
		assert(screen)
		return mount_editor(screen, set_content_visible)
	end
	React.useLayoutEffect(mount, {})
	local green = Color3.new(0, 222 / 255, 33 / 255)
	return create_element("ScreenGui", {
		ref = ref,
		Name = "HudEditor",
		Enabled = false,
		ResetOnSpawn = false,
		DisplayOrder = 100,
	}, {
		instructions = create_element("TextLabel", {
			Visible = content_visible,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.7, 0.18),
			BackgroundTransparency = 1,
			RichText = true,
			TextSize = 48,
			TextColor3 = Color3.new(1, 1, 1),
			FontFace = FONTS.regular,
			Text = 'Welcome to the HUD editor!\n<font size="24">Try dragging around some HUD elements.</font>\n<font size="24">The white border represents the bounds of the screen.</font>',
		}),
		back_button = create_element(animated_button, {
			Visible = content_visible,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(0.9, 0.05),
			Size = UDim2.fromOffset(200, 50),
			BackgroundColor3 = COLOURS.surface,
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			Text = "Back",
			TextSize = 36,
			TextColor3 = COLOURS.danger,
			FontFace = FONTS.regular,
			[React.Event.Activated] = leave_editor,
		}, {
			feedback = create_element(button_motion),
			corner = create_element("UICorner", { CornerRadius = UDim.new(1, 0) }),
			stroke = create_element(gradient_stroke, { colour = COLOURS.danger, rotation = -90 }),
			blur = create_element(ui_blur),
			-- Shifts the text right to centre it together with the icon.
			padding = create_element("UIPadding", { PaddingLeft = UDim.new(0, 38) }),
			icon = create_element("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0.5, -76, 0.5, 0),
				Size = UDim2.fromOffset(30, 30),
				BackgroundTransparency = 1,
				Image = "rbxassetid://84702625541122",
				ImageColor3 = COLOURS.danger,
			}),
		}),
		new_button = create_element("TextButton", {
			Visible = content_visible,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.05),
			Size = UDim2.fromOffset(200, 50),
			BackgroundColor3 = COLOURS.surface,
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			Text = "⊕ New",
			TextSize = 36,
			TextColor3 = green,
			FontFace = FONTS.regular,
		}, {
			corner = create_element("UICorner", { CornerRadius = UDim.new(1, 0) }),
			stroke = create_element(gradient_stroke, { colour = green, rotation = -90 }),
			blur = create_element(ui_blur),
		}),
		Bounds = create_element("Frame", {
			Visible = content_visible,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.8, 0.8),
			BackgroundTransparency = 1,
		}, {
			corner = create_element("UICorner", { CornerRadius = UDim.new(0, 8) }),
			stroke = create_element("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 1 }),
		}),
	})
end

return editor
