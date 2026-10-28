local run_service = game:GetService("RunService")
local user_input_service = game:GetService("UserInputService")

type mouse_button = {
	label: TextLabel,
	name: string,
	pressed: boolean,
	clicks: { number },
}

local released_colour = Color3.new(17 / 255, 17 / 255, 17 / 255)
local pressed_key_colour = Color3.new(80 / 255, 80 / 255, 80 / 255)
local pressed_mouse_colour = Color3.new(40 / 255, 40 / 255, 40 / 255)

local function mount_input(keystrokes: Frame, mousestrokes: Frame)
	local keys: { [Enum.KeyCode]: GuiObject } = {}
	for _, key_code in { Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Space } do
		local key = keystrokes:FindFirstChild(key_code.Name)
		assert(key and key:IsA("GuiObject"))
		keys[key_code] = key
	end
	local left = mousestrokes:FindFirstChild("Lmb")
	local right = mousestrokes:FindFirstChild("Rmb")
	assert(left and left:IsA("TextLabel"))
	assert(right and right:IsA("TextLabel"))
	local buttons: { [Enum.UserInputType]: mouse_button } = {
		[Enum.UserInputType.MouseButton1] = {
			label = left,
			name = "Left",
			pressed = false,
			clicks = {},
		},
		[Enum.UserInputType.MouseButton2] = {
			label = right,
			name = "Right",
			pressed = false,
			clicks = {},
		},
	}
	local top = mousestrokes:FindFirstChild("Top")
	assert(top and top:IsA("ImageLabel"))
	local point = top:FindFirstChild("Point")
	assert(point and point:IsA("Frame"))
	local pending_delta = Vector2.zero
	local displayed_delta = Vector2.zero
	point.AnchorPoint = Vector2.new(0.5, 0.5)

	local function update_button(button: mouse_button): ()
		local count = #button.clicks
		local text = if count > 0 then `{count} CPS` else button.name
		if button.label.Text ~= text then
			button.label.Text = text
		end
		button.label.BackgroundColor3 = if button.pressed then pressed_mouse_colour else released_colour
	end

	local function reset_input(): ()
		for _, key in keys do
			key.BackgroundColor3 = released_colour
		end
		for _, button in buttons do
			button.pressed = false
			table.clear(button.clicks)
			update_button(button)
		end
		pending_delta = Vector2.zero
		displayed_delta = Vector2.zero
		point.Position = UDim2.fromScale(0.5, 0.5)
	end

	local function on_input_began(input: InputObject, processed: boolean): ()
		local key = keys[input.KeyCode]
		if key and not processed and user_input_service:GetFocusedTextBox() == nil then
			key.BackgroundColor3 = pressed_key_colour
		end
		local button = buttons[input.UserInputType]
		if button then
			button.pressed = true
			table.insert(button.clicks, os.clock())
			update_button(button)
		end
	end

	local function on_input_ended(input: InputObject): ()
		local key = keys[input.KeyCode]
		if key then
			key.BackgroundColor3 = released_colour
		end
		local button = buttons[input.UserInputType]
		if button then
			button.pressed = false
			update_button(button)
		end
	end

	local function on_input_changed(input: InputObject): ()
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			pending_delta += Vector2.new(input.Delta.X, input.Delta.Y)
		end
	end

	local function on_render(delta_time: number): ()
		local target =
			Vector2.new(math.clamp(pending_delta.X / 40, -0.42, 0.42), math.clamp(pending_delta.Y / 40, -0.38, 0.38))
		pending_delta = Vector2.zero
		displayed_delta = displayed_delta:Lerp(target, 1 - math.exp(-25 * delta_time))
		point.Position = UDim2.fromScale(0.5 + displayed_delta.X, 0.5 + displayed_delta.Y)

		local cutoff = os.clock() - 1
		for _, button in buttons do
			local expired = 0
			for _, time in button.clicks do
				if time > cutoff then
					break
				end
				expired += 1
			end
			if expired > 0 then
				for _ = 1, expired do
					table.remove(button.clicks, 1)
				end
				update_button(button)
			end
		end
	end

	reset_input()
	local connections = {
		user_input_service.InputBegan:Connect(on_input_began),
		user_input_service.InputEnded:Connect(on_input_ended),
		user_input_service.InputChanged:Connect(on_input_changed),
		user_input_service.WindowFocusReleased:Connect(reset_input),
		user_input_service.TextBoxFocused:Connect(reset_input),
		run_service.RenderStepped:Connect(on_render),
	}

	local function disconnect(): ()
		for _, connection in connections do
			connection:Disconnect()
		end
	end

	return disconnect
end

return mount_input
