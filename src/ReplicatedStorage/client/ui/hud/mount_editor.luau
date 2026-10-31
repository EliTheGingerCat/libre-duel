local context_action_service = game:GetService("ContextActionService")
local gui_service = game:GetService("GuiService")
local players = game:GetService("Players")
local run_service = game:GetService("RunService")
local user_input_service = game:GetService("UserInputService")

local create_widget = require(script.Parent.editor_widget)
local editor_state = require(script.Parent.editor_state)
local geometry = require(script.Parent.editor_geometry)
local mount_menus = require(script.Parent.mount_menus)
const KEYBINDS = require(script.Parent.Parent.Parent.util.KEYBINDS)
local registry = require(script.Parent.registry)

type drag_state = {
	view: create_widget.view,
	pointer: Vector2,
	start: geometry.rectangle,
	rect: geometry.rectangle,
	multiplier: number,
	anchor: Vector2,
	handle: Vector2?,
}

local function mount_editor()
	local template = script.Parent.editor_template
	local screen = template.screen:Clone()
	local preview = screen:FindFirstChild("Bounds")
	local new_button = screen:FindFirstChild("new_button")
	assert(preview and preview:IsA("Frame"))
	assert(new_button and new_button:IsA("TextButton"))
	local player_gui = players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	assert(player_gui)
	screen.Parent = player_gui
	local views: { create_widget.view } = {}
	local hovered: create_widget.view? = nil
	local drag: drag_state? = nil
	local saved_mouse_behavior = user_input_service.MouseBehavior
	local saved_mouse_icon = user_input_service.MouseIconEnabled
	local saved_camera: Camera? = nil
	local saved_camera_type = Enum.CameraType.Custom
	local menus = mount_menus(player_gui, screen.DisplayOrder + 1)

	local function get_pointer(): Vector2
		local inset = gui_service:GetGuiInset()
		return user_input_service:GetMouseLocation() - inset - preview.AbsolutePosition
	end

	local function preview_factor(item: registry.entry): number
		return preview.AbsoluteSize.X / math.max(1, item.screen.AbsoluteSize.X)
	end

	local function button_contains(button: ImageButton, pointer: Vector2): boolean
		return geometry.contains({
			position = button.AbsolutePosition - preview.AbsolutePosition,
			size = button.AbsoluteSize,
		}, pointer)
	end

	local function find_hovered(pointer: Vector2): create_widget.view?
		if hovered and not hovered.item.hidden then
			if
				button_contains(hovered.delete_button, pointer)
				or button_contains(hovered.settings_button, pointer)
				or geometry.get_handle(hovered.get_rectangle(), pointer)
			then
				return hovered
			end
		end
		for index = #views, 1, -1 do
			local view = views[index]
			if not view.item.hidden and geometry.contains(view.get_rectangle(), pointer) then
				return view
			end
		end
		return nil
	end

	local function finish_drag(): ()
		local current = drag
		drag = nil
		if
			current
			and preview.AbsoluteSize.X > 0
			and preview.AbsoluteSize.Y > 0
			and table.find(registry.entries, current.view.item)
		then
			current.view.item.layout =
				geometry.get_layout(current.rect, preview.AbsoluteSize, preview_factor(current.view.item))
			current.view.item.refresh()
		end
	end

	local function update_drag(pointer: Vector2): ()
		local current = drag
		if not current or preview.AbsoluteSize.X <= 0 or preview.AbsoluteSize.Y <= 0 then
			return
		end
		local others: { geometry.rectangle } = {}
		for _, view in views do
			if view ~= current.view and not view.item.hidden then
				table.insert(others, view.get_rectangle())
			end
		end
		local delta = pointer - current.pointer
		local rect: geometry.rectangle
		if current.handle then
			rect =
				geometry.resize(current.start, delta, current.handle, others, preview.AbsoluteSize, current.multiplier)
			current.view.item.multiplier = current.multiplier * rect.size.X / current.start.size.X
		else
			rect = geometry.move(current.start, delta, others, preview.AbsoluteSize)
		end
		current.rect = rect
		current.view.item.layout = {
			anchor = current.anchor,
			offset = (rect.position + rect.size * current.anchor - preview.AbsoluteSize * current.anchor)
				/ preview_factor(current.view.item),
		}
		current.view.item.refresh()
	end

	local function update_editor(): ()
		user_input_service.MouseBehavior = Enum.MouseBehavior.Default
		user_input_service.MouseIconEnabled = true
		if menus.is_open() then
			return
		end
		local pointer = get_pointer()
		update_drag(pointer)
		for _, view in views do
			view.refresh()
		end
		hovered = find_hovered(pointer)
		for _, view in views do
			view.hover(view == hovered, pointer)
		end
	end

	local function prepare_menu(): ()
		finish_drag()
		hovered = nil
		for _, view in views do
			view.hover(false, Vector2.zero)
		end
	end

	local function delete_widget(item: registry.entry): ()
		if not editor_state.enabled or menus.is_open() then
			return
		end
		prepare_menu()
		registry.remove(item)
	end

	local function open_settings(item: registry.entry): ()
		if not editor_state.enabled or menus.is_open() then
			return
		end
		prepare_menu()
		menus.open_settings(item)
	end

	local function sync_widgets(): ()
		finish_drag()
		hovered = nil
		for _, view in views do
			view.destroy()
			view.item.preview = nil
			if table.find(registry.entries, view.item) then
				view.item.refresh()
			end
		end
		table.clear(views)
		if not editor_state.enabled then
			return
		end
		for _, item in registry.entries do
			item.preview = preview
			item.refresh()
			table.insert(views, create_widget(item, template.widget_bounds, preview, delete_widget, open_settings))
		end
	end

	local function sink_controls(): Enum.ContextActionResult
		return Enum.ContextActionResult.Sink
	end

	local function set_enabled(enabled: boolean): ()
		finish_drag()
		menus.close()
		editor_state.set_enabled(enabled)
		screen.Enabled = enabled
		if enabled then
			saved_mouse_behavior = user_input_service.MouseBehavior
			saved_mouse_icon = user_input_service.MouseIconEnabled
			saved_camera = workspace.CurrentCamera
			if saved_camera then
				saved_camera_type = saved_camera.CameraType
				saved_camera.CameraType = Enum.CameraType.Scriptable
			end
			context_action_service:BindActionAtPriority(
				"hud_editor_controls",
				sink_controls,
				false,
				Enum.ContextActionPriority.High.Value,
				Enum.KeyCode.W,
				Enum.KeyCode.A,
				Enum.KeyCode.S,
				Enum.KeyCode.D,
				Enum.KeyCode.Up,
				Enum.KeyCode.Down,
				Enum.KeyCode.Left,
				Enum.KeyCode.Right,
				Enum.KeyCode.Space,
				Enum.KeyCode.Thumbstick1,
				Enum.KeyCode.ButtonA
			)
			run_service:BindToRenderStep("hud_editor_cursor", Enum.RenderPriority.Last.Value, update_editor)
		else
			run_service:UnbindFromRenderStep("hud_editor_cursor")
			context_action_service:UnbindAction("hud_editor_controls")
			if saved_camera then
				saved_camera.CameraType = saved_camera_type
				saved_camera = nil
			end
			user_input_service.MouseBehavior = saved_mouse_behavior
			user_input_service.MouseIconEnabled = saved_mouse_icon
		end
		sync_widgets()
	end

	local function toggle_editor(_action_name: string, input_state: Enum.UserInputState): Enum.ContextActionResult
		if user_input_service:GetFocusedTextBox() ~= nil then
			return Enum.ContextActionResult.Pass
		end
		if input_state == Enum.UserInputState.Begin then
			set_enabled(not editor_state.enabled)
		end
		return Enum.ContextActionResult.Sink
	end

	local function on_input_began(input: InputObject): ()
		if not editor_state.enabled or menus.is_open() or input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end
		local pointer = get_pointer()
		hovered = find_hovered(pointer)
		local view = hovered
		if not view then
			return
		end
		if
			view.bounds.Visible
			and (button_contains(view.delete_button, pointer) or button_contains(view.settings_button, pointer))
		then
			return
		end
		local rect = view.get_rectangle()
		if rect.size.X <= 0 or rect.size.Y <= 0 then
			return
		end
		drag = {
			view = view,
			pointer = pointer,
			start = rect,
			rect = rect,
			multiplier = view.item.multiplier,
			anchor = view.item.container.AnchorPoint,
			handle = geometry.get_handle(rect, pointer),
		}
	end

	local function on_input_ended(input: InputObject): ()
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if drag then
				update_drag(get_pointer())
			end
			finish_drag()
		end
	end

	local function on_size_changed(): ()
		finish_drag()
		for _, view in views do
			view.item.refresh()
		end
	end

	local function open_selector(): ()
		if not editor_state.enabled or menus.is_open() then
			return
		end
		prepare_menu()
		menus.open_selector()
	end

	local connections = {
		new_button.Activated:Connect(open_selector),
		user_input_service.InputBegan:Connect(on_input_began),
		user_input_service.InputEnded:Connect(on_input_ended),
		user_input_service.WindowFocusReleased:Connect(finish_drag),
		preview:GetPropertyChangedSignal("AbsoluteSize"):Connect(on_size_changed),
	}
	context_action_service:BindActionAtPriority(
		"hud_editor_toggle",
		toggle_editor,
		false,
		Enum.ContextActionPriority.High.Value + 1,
		KEYBINDS.hud_editor
	)
	local unsubscribe = registry.subscribe(sync_widgets)

	local function disconnect(): ()
		set_enabled(false)
		context_action_service:UnbindAction("hud_editor_toggle")
		menus.disconnect()
		unsubscribe()
		for _, connection in connections do
			connection:Disconnect()
		end
		screen:Destroy()
	end
	return disconnect
end

return mount_editor
