local registry = require(script.Parent.registry)

local function mount_settings(player_gui: PlayerGui, display_order: number, on_close: () -> ())
	local screen = script.Parent.settings_template.screen:Clone()
	screen.DisplayOrder = display_order
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local window = screen:FindFirstChild("window")
	assert(window and window:IsA("Frame"))
	local scale = window:FindFirstChildOfClass("UIScale")
	local title = window:FindFirstChild("title")
	local close_button = window:FindFirstChild("close_button")
	local background = screen:FindFirstChild("background")
	local value = window:FindFirstChild("value", true)
	local decrease = window:FindFirstChild("decrease", true)
	local increase = window:FindFirstChild("increase", true)
	assert(scale)
	assert(title and title:IsA("TextLabel"))
	assert(close_button and close_button:IsA("ImageButton"))
	assert(background and background:IsA("TextButton"))
	assert(value and value:IsA("TextBox"))
	assert(decrease and decrease:IsA("TextButton"))
	assert(increase and increase:IsA("TextButton"))
	screen.Parent = player_gui
	local selected: registry.entry? = nil

	local function update_scale(): ()
		local size = screen.AbsoluteSize
		scale.Scale = math.max(0.001, math.min(1, size.X / 1920, size.Y / 1080))
	end

	local function set_roundness(roundness: number): ()
		local item = selected
		if item then
			item.corners.set(math.round(roundness))
			value.Text = `{item.corners.get()}%`
		end
	end

	local function commit(): ()
		local item = selected
		if item then
			local roundness = tonumber((value.Text:gsub("%%", "")))
			set_roundness(roundness or item.corners.get())
		end
	end

	local function close(): ()
		selected = nil
		screen.Enabled = false
		on_close()
	end

	local function open(item: registry.entry): ()
		selected = item
		title.Text = `{item.screen.Name} settings`
		value.Text = `{item.corners.get()}%`
		update_scale()
		screen.Enabled = true
	end

	local connections = {
		close_button.Activated:Connect(close),
		background.Activated:Connect(close),
		value.FocusLost:Connect(commit),
		decrease.Activated:Connect(function()
			if selected then
				set_roundness(selected.corners.get() - 5)
			end
		end),
		increase.Activated:Connect(function()
			if selected then
				set_roundness(selected.corners.get() + 5)
			end
		end),
		screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(update_scale),
	}

	local function disconnect(): ()
		for _, connection in connections do
			connection:Disconnect()
		end
		screen:Destroy()
	end

	return { open = open, close = close, disconnect = disconnect }
end

return mount_settings
