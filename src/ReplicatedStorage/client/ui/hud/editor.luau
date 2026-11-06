local ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
local React = require(ReplicatedStorage.Packages.react)
local animated_button = require(script.Parent.Parent.visuals.animated_button)
local button_motion = require(script.Parent.Parent.visuals.button_motion)
local editor_reset_button = require(script.Parent.editor_reset_button)
local editor_state = require(script.Parent.editor_state)
local gradient_stroke = require(script.Parent.Parent.visuals.gradient_stroke)
local mount_editor = require(script.Parent.mount_editor)
local ui_blur = require(script.Parent.Parent.blur.ui_blur)

local create_element = React.createElement

local function leave_editor(): ()
	editor_state.request_enabled(false)
end

local function open_selector(): ()
	editor_state.request_selector()
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
		dim = create_element("Frame", {
			Position = UDim2.fromOffset(0, -100),
			Size = UDim2.new(1, 0, 1, 200),
			BackgroundColor3 = COLOURS.surface,
			BackgroundTransparency = 0.45,
			BorderSizePixel = 0,
			ZIndex = 0,
		}),
		hint = create_element("TextLabel", {
			Visible = content_visible,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.95),
			Size = UDim2.fromScale(0.8, 0.08),
			BackgroundTransparency = 1,
			TextSize = 22,
			TextWrapped = true,
			TextColor3 = COLOURS.grey_200,
			FontFace = FONTS.regular,
			Text = "Try dragging stuff around!",
		}),
		toolbar = create_element("Frame", {
			Visible = content_visible,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.05),
			Size = UDim2.new(0.8, 0, 0, 44),
			BackgroundTransparency = 1,
		}, {
			layout = create_element("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 12),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			new_button = create_element(animated_button, {
				LayoutOrder = 1,
				Size = UDim2.fromOffset(190, 44),
				BackgroundColor3 = COLOURS.surface,
				BackgroundTransparency = 0.5,
				BorderSizePixel = 0,
				Text = "⊕ Add element",
				TextSize = 24,
				TextColor3 = green,
				FontFace = FONTS.regular,
				[React.Event.Activated] = open_selector,
			}, {
				feedback = create_element(button_motion),
				corner = create_element("UICorner", { CornerRadius = UDim.new(1, 0) }),
				stroke = create_element(gradient_stroke, { colour = green, rotation = -90 }),
				blur = create_element(ui_blur),
			}),
			reset_button = create_element(editor_reset_button, { LayoutOrder = 2 }),
			done_button = create_element(animated_button, {
				LayoutOrder = 3,
				Size = UDim2.fromOffset(130, 44),
				BackgroundColor3 = COLOURS.surface,
				BackgroundTransparency = 0.5,
				BorderSizePixel = 0,
				Text = "Done",
				TextSize = 24,
				TextColor3 = COLOURS.grey_100,
				FontFace = FONTS.regular,
				[React.Event.Activated] = leave_editor,
			}, {
				feedback = create_element(button_motion),
				corner = create_element("UICorner", { CornerRadius = UDim.new(1, 0) }),
				stroke = create_element(gradient_stroke, { colour = COLOURS.grey_100, rotation = -90 }),
				blur = create_element(ui_blur),
			}),
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
			guide_x = create_element("Frame", {
				Visible = false,
				AnchorPoint = Vector2.new(0.5, 0),
				Size = UDim2.new(0, 1, 1, 0),
				BorderSizePixel = 0,
				ZIndex = 30,
			}),
			guide_y = create_element("Frame", {
				Visible = false,
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(1, 0, 0, 1),
				BorderSizePixel = 0,
				ZIndex = 30,
			}),
		}),
	})
end

return editor
