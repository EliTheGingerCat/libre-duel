local registry = require(script.Parent.registry)

const WIDGET_NAMES: { [string]: string } = {
	Keystrokes = "Keystrokes",
	Mousestrokes = "Mousestrokes",
	ReachCounter = "Reach Counter",
	ComboCounter = "Combo Counter",
	FpsCounter = "FPS Counter",
	Paperdoll = "Paperdoll",
}
const WIDGET_ORDER = { "Keystrokes", "Mousestrokes", "FpsCounter", "ReachCounter", "ComboCounter", "Paperdoll" }

local function mount_selector(player_gui: PlayerGui, display_order: number, on_close: () -> ())
	local template = script.Parent.selector_template
	local screen = template.screen:Clone()
	screen.DisplayOrder = display_order
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local window = screen:FindFirstChild("window")
	assert(window and window:IsA("Frame"))
	local scale = window:FindFirstChildOfClass("UIScale")
	local close_button = window:FindFirstChild("close_button")
	local background = screen:FindFirstChild("background")
	local list = window:FindFirstChild("list", true)
	assert(scale)
	assert(close_button and close_button:IsA("ImageButton"))
	assert(background and background:IsA("TextButton"))
	assert(list and list:IsA("ScrollingFrame"))
	screen.Parent = player_gui
	local tiles: { TextButton } = {}
	local tile_connections: { RBXScriptConnection } = {}
	local resize_previews: { () -> () } = {}

	local function clear_tiles(): ()
		for _, connection in tile_connections do
			connection:Disconnect()
		end
		for _, tile in tiles do
			tile:Destroy()
		end
		table.clear(tile_connections)
		table.clear(tiles)
		table.clear(resize_previews)
	end

	local function close(): ()
		screen.Enabled = false
		clear_tiles()
		on_close()
	end

	local function update_scale(): ()
		local size = screen.AbsoluteSize
		scale.Scale = math.max(0.001, math.min(1, size.X / 1920, size.Y / 1080))
		for _, resize in resize_previews do
			resize()
		end
	end

	local function rebuild(): ()
		clear_tiles()
		if not screen.Enabled then
			return
		end
		for index, item in registry.entries do
			local tile = template.tile:Clone()
			tile.Name = item.screen.Name
			tile.Text = WIDGET_NAMES[item.screen.Name] or item.screen.Name
			tile.LayoutOrder = table.find(WIDGET_ORDER, item.screen.Name) or #WIDGET_ORDER + index
			local preview = tile:FindFirstChild("preview")
			assert(preview and preview:IsA("Frame"))
			local content = item.content:Clone()
			content.AnchorPoint = Vector2.new(0.5, 0.5)
			content.Position = UDim2.fromScale(0.5, 0.5)
			content.Visible = true
			content.Active = false
			local content_scale = content:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
			content_scale.Scale = 1
			content_scale.Parent = content
			for _, descendant in content:GetDescendants() do
				if descendant:IsA("GuiObject") then
					descendant.Active = false
					descendant.Selectable = false
				end
			end
			content.Parent = preview
			tile.Parent = list
			table.insert(tiles, tile)

			local function resize(): ()
				local available = preview.AbsoluteSize / scale.Scale - Vector2.new(48, 24)
				local size = Vector2.new(content.Size.X.Offset, content.Size.Y.Offset)
				content_scale.Scale =
					math.max(0.001, math.min(1, available.X / math.max(1, size.X), available.Y / math.max(1, size.Y)))
			end
			local function select_widget(): ()
				item.hidden = false
				item.refresh()
				close()
			end
			table.insert(resize_previews, resize)
			table.insert(tile_connections, preview:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize))
			table.insert(tile_connections, tile.Activated:Connect(select_widget))
			resize()
		end
	end

	local function set_enabled(enabled: boolean): ()
		screen.Enabled = enabled
		if enabled then
			list.CanvasPosition = Vector2.zero
			update_scale()
		end
		rebuild()
	end

	update_scale()
	local connections = {
		close_button.Activated:Connect(close),
		background.Activated:Connect(close),
		screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(update_scale),
	}
	local unsubscribe = registry.subscribe(rebuild)

	local function disconnect(): ()
		unsubscribe()
		clear_tiles()
		for _, connection in connections do
			connection:Disconnect()
		end
		screen:Destroy()
	end

	return {
		set_enabled = set_enabled,
		disconnect = disconnect,
	}
end

return mount_selector
