local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local gradient_stroke = require(script.Parent.Parent.visuals.gradient_stroke)
local menu_window = require(script.Parent.Parent.visuals.menu_window)
local registry = require(script.Parent.registry)

local create_element = React.createElement

local function step_button(props: { text: string, position: UDim2, on_activate: () -> () })
	return create_element("TextButton", {
		Position = props.position,
		Size = UDim2.fromOffset(70, 56),
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.new(54 / 255, 54 / 255, 54 / 255),
		Text = props.text,
		TextSize = 30,
		TextColor3 = Color3.new(1, 1, 1),
		FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
		[React.Event.Activated] = props.on_activate,
	}, {
		corner = create_element("UICorner", { CornerRadius = UDim.new(0, 14) }),
		stroke = create_element(gradient_stroke),
	})
end

local function settings(props: { selected: registry.entry?, display_order: number, on_close: () -> () })
	local selected = props.selected
	local text, set_text = React.useState("100%")
	local function update_selected(): ()
		if selected then
			set_text(`{selected.corners.get()}%`)
		end
	end
	React.useEffect(update_selected, { selected })
	local function set_roundness(value: number): ()
		if selected then
			selected.corners.set(math.round(value))
			set_text(`{selected.corners.get()}%`)
		end
	end
	local function decrease(): ()
		if selected then
			set_roundness(selected.corners.get() - 5)
		end
	end
	local function increase(): ()
		if selected then
			set_roundness(selected.corners.get() + 5)
		end
	end
	local function on_text_changed(box: TextBox): ()
		set_text(box.Text)
	end
	local function commit(box: TextBox): ()
		if selected then
			set_roundness(tonumber((box.Text:gsub("%%", ""))) or selected.corners.get())
		end
	end
	return create_element(
		menu_window,
		{
			name = "HudSettings",
			title = if selected then `{selected.screen.Name} settings` else "HUD settings",
			size = Vector2.new(600, 320),
			enabled = selected ~= nil,
			display_order = props.display_order,
			on_close = props.on_close,
		},
		create_element("Frame", {
			Name = "controls",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 90),
			Size = UDim2.new(1, -100, 0, 180),
			BackgroundTransparency = 1,
		}, {
			label = create_element("TextLabel", {
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundTransparency = 1,
				Text = "Corner roundness",
				TextSize = 28,
				TextColor3 = Color3.new(1, 1, 1),
				FontFace = Font.fromId(11702779409, Enum.FontWeight.Bold),
			}),
			hint = create_element("TextLabel", {
				Position = UDim2.fromOffset(0, 122),
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundTransparency = 1,
				Text = "0% square · 100% fully rounded",
				TextSize = 20,
				TextColor3 = Color3.new(1, 1, 1),
				FontFace = Font.fromId(11702779409, Enum.FontWeight.Bold),
			}),
			decrease = create_element(
				step_button,
				{ text = "−", position = UDim2.fromOffset(0, 54), on_activate = decrease }
			),
			increase = create_element(
				step_button,
				{ text = "+", position = UDim2.new(1, -70, 0, 54), on_activate = increase }
			),
			value = create_element("TextBox", {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 54),
				Size = UDim2.new(1, -180, 0, 56),
				BackgroundColor3 = Color3.new(54 / 255, 54 / 255, 54 / 255),
				BorderSizePixel = 0,
				ClearTextOnFocus = false,
				Text = text,
				TextSize = 30,
				TextColor3 = Color3.new(1, 1, 1),
				FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
				[React.Change.Text] = on_text_changed,
				[React.Event.FocusLost] = commit,
			}, {
				corner = create_element("UICorner", { CornerRadius = UDim.new(0, 14) }),
				stroke = create_element(gradient_stroke),
			}),
		})
	)
end

return settings
