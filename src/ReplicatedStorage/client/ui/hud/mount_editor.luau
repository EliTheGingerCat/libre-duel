local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local create_widget = require(script.Parent.editor_widget)
local editor_drag = require(script.Parent.editor_drag)
local editor_state = require(script.Parent.editor_state)
local get_drag_offset = require(script.Parent.Parent.visuals.controls.get_drag_offset)
local geometry = require(script.Parent.editor_geometry)
local mount_menus = require(script.Parent.mount_menus)
const KEYBINDS = require(script.Parent.Parent.Parent.util.KEYBINDS)
local registry = require(script.Parent.registry)

local function mount_editor(screen: ScreenGui, set_content_visible: (boolean) -> ())
	local preview = screen:FindFirstChild("Bounds")
	local new_button = screen:FindFirstChild("new_button")
	assert(preview and preview:IsA("Frame"))
	assert(new_button and new_button:IsA("TextButton"))
	local player_gui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	assert(player_gui)
	screen.Parent = player_gui
	local views: { create_widget.view } = {}
	local hovered: create_widget.view? = nil
	local drag = editor_drag(preview, screen, views)
	local saved_mouse_behavior = UserInputService.MouseBehavior
	local saved_mouse_icon = UserInputService.MouseIconEnabled
	local function on_menu_changed(open: boolean): ()
		set_content_visible(not open)
	end
	local menus = mount_menus(player_gui, screen.DisplayOrder + 1, on_menu_changed)

	local function get_pointer(): Vector2
		local inset = GuiService:GetGuiInset()
		return UserInputService:GetMouseLocation() - inset - preview.AbsolutePosition
	end

	local function button_contains(button: ImageButton?, pointer: Vector2): boolean
		if not button then
			return false
		end
		return geometry.contains({
			position = button.AbsolutePosition - preview.AbsolutePosition,
			size = button.AbsoluteSize,
		}, pointer)
	end

	local function find_hovered(pointer: Vector2): create_widget.view?
		if hovered and not hovered.item.hidden then
			if
				button_contains(hovered.delete_button.current, pointer)
				or button_contains(hovered.settings_button.current, pointer)
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

	local function begin_drag(view: create_widget.view, source: UIDragDetector, position: Vector2, handle: Vector2?): ()
		if not editor_state.enabled or menus.is_open() then
			return
		end
		if drag.begin(view, source, get_drag_offset(preview, position), handle) then
			hovered = view
		end
	end
	local function update_drag(source: UIDragDetector, position: Vector2): ()
		drag.update(source, get_drag_offset(preview, position))
	end
	local function finish_drag_input(source: UIDragDetector, position: Vector2): ()
		drag.finish_input(source, get_drag_offset(preview, position))
	end

	local function update_editor(): ()
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
		if menus.is_open() then
			return
		end
		local active_view = drag.get_view()
		local input_pointer = drag.get_pointer()
		local touch = UserInputService:GetLastInputType() == Enum.UserInputType.Touch
		local pointer = if (active_view or touch) and input_pointer then input_pointer else get_pointer()
		for _, view in views do
			view.refresh()
		end
		hovered = active_view or find_hovered(pointer)
		for _, view in views do
			view.hover(view == hovered, pointer)
		end
	end

	local function prepare_menu(): ()
		drag.finish()
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
		drag.finish()
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
			table.insert(
				views,
				create_widget(item, preview, {
					delete = delete_widget,
					settings = open_settings,
					drag_start = begin_drag,
					drag_move = update_drag,
					drag_finish = finish_drag_input,
				})
			)
		end
	end

	local function sink_controls(): Enum.ContextActionResult
		return Enum.ContextActionResult.Sink
	end

	local function set_enabled(enabled: boolean): ()
		drag.finish()
		menus.close()
		editor_state.set_enabled(enabled)
		screen.Enabled = enabled
		if enabled then
			saved_mouse_behavior = UserInputService.MouseBehavior
			saved_mouse_icon = UserInputService.MouseIconEnabled
			ContextActionService:BindActionAtPriority(
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
			RunService:BindToRenderStep("hud_editor_cursor", Enum.RenderPriority.Last.Value, update_editor)
		else
			RunService:UnbindFromRenderStep("hud_editor_cursor")
			ContextActionService:UnbindAction("hud_editor_controls")
			UserInputService.MouseBehavior = saved_mouse_behavior
			UserInputService.MouseIconEnabled = saved_mouse_icon
		end
		sync_widgets()
	end

	local function toggle_editor(_action_name: string, input_state: Enum.UserInputState): Enum.ContextActionResult
		if UserInputService:GetFocusedTextBox() ~= nil then
			return Enum.ContextActionResult.Pass
		end
		if input_state == Enum.UserInputState.Begin then
			set_enabled(not editor_state.enabled)
		end
		return Enum.ContextActionResult.Sink
	end

	local function on_size_changed(): ()
		drag.finish()
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
		UserInputService.WindowFocusReleased:Connect(drag.finish),
		preview:GetPropertyChangedSignal("AbsoluteSize"):Connect(on_size_changed),
	}
	ContextActionService:BindActionAtPriority(
		"hud_editor_toggle",
		toggle_editor,
		false,
		Enum.ContextActionPriority.High.Value + 1,
		KEYBINDS.hud_editor
	)
	local unsubscribe = registry.subscribe(sync_widgets)

	local function disconnect(): ()
		set_enabled(false)
		ContextActionService:UnbindAction("hud_editor_toggle")
		menus.disconnect()
		unsubscribe()
		for _, connection in connections do
			connection:Disconnect()
		end
	end
	return disconnect
end

return mount_editor
