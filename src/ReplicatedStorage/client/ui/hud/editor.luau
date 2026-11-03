local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local gradient_stroke = require(script.Parent.Parent.visuals.gradient_stroke)
local mount_editor = require(script.Parent.mount_editor)

local create_element = React.createElement

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
			FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
			Text = 'Welcome to the HUD editor!\n<font size="24">Try dragging around some HUD elements.</font>\n<font size="24">The white border represents the bounds of the screen.</font>',
		}),
		new_button = create_element("TextButton", {
			Visible = content_visible,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 0.99),
			Size = UDim2.fromOffset(200, 50),
			BackgroundColor3 = Color3.fromRGB(17, 17, 17),
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			Text = "⊕ New",
			TextSize = 36,
			TextColor3 = green,
			FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
		}, {
			corner = create_element("UICorner", { CornerRadius = UDim.new(1, 0) }),
			stroke = create_element(gradient_stroke, { colour = green, rotation = -90 }),
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
