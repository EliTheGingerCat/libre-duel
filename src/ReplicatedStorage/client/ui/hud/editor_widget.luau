local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local geometry = require(script.Parent.editor_geometry)
local mount_portal = require(script.Parent.mount_portal)
local registry = require(script.Parent.registry)
local widget_bounds = require(script.Parent.widget_bounds)

export type view = {
	item: registry.entry,
	bounds: { current: Frame? },
	delete_button: { current: ImageButton? },
	settings_button: { current: ImageButton? },
	refresh: () -> (),
	hover: (boolean, Vector2) -> (),
	get_rectangle: () -> geometry.rectangle,
	destroy: () -> (),
}

export type actions = {
	delete: (registry.entry) -> (),
	settings: (registry.entry) -> (),
	drag_start: (view, UIDragDetector, Vector2, Vector2?) -> (),
	drag_move: (UIDragDetector, Vector2) -> (),
	drag_finish: (UIDragDetector, Vector2) -> (),
}

local function create_widget(item: registry.entry, preview: Frame, actions: actions): view
	local bounds_ref = React.createRef()
	local move_ref = React.createRef()
	local view: view
	local delete_ref = React.createRef()
	local settings_ref = React.createRef()
	local portal = mount_portal(preview)
	local function delete(): ()
		actions.delete(item)
	end
	local function settings(): ()
		actions.settings(item)
	end
	local function drag_start(source: UIDragDetector, position: Vector2, handle: Vector2?): ()
		actions.drag_start(view, source, position, handle)
	end

	local function get_rectangle(): geometry.rectangle
		return {
			position = item.container.AbsolutePosition - preview.AbsolutePosition,
			size = item.container.AbsoluteSize,
		}
	end
	local function refresh(): ()
		local bounds = bounds_ref.current
		if not bounds then
			return
		end
		local rect = get_rectangle()
		bounds.Visible = not item.hidden
		bounds.Position = UDim2.fromOffset(rect.position.X, rect.position.Y)
		bounds.Size = UDim2.fromOffset(rect.size.X, rect.size.Y)
	end
	local function hover(hovered: boolean, pointer: Vector2): ()
		local bounds = bounds_ref.current
		if not bounds then
			return
		end
		local visible = hovered and not item.hidden
		local move = move_ref.current
		if move then
			move.BackgroundTransparency = if visible then 0.8 else 1
			local stroke = move:FindFirstChildOfClass("UIStroke")
			if stroke then
				stroke.Enabled = visible
			end
		end
		local direction = if visible then geometry.get_handle(get_rectangle(), pointer) else nil
		for _, child in bounds:GetChildren() do
			if child:IsA("Frame") and child.Name:match("^handle_") then
				child.Visible = visible
				local marker = child:FindFirstChild("marker")
				local stroke = if marker then marker:FindFirstChildOfClass("UIStroke") else nil
				if stroke then
					local handle = Vector2.new(child.Position.X.Scale * 2 - 1, child.Position.Y.Scale * 2 - 1)
					stroke.Thickness = if direction == handle then 6 else 5
				end
			elseif child:IsA("ImageButton") then
				child.Visible = visible
			end
		end
	end
	view = {
		item = item,
		bounds = bounds_ref,
		delete_button = delete_ref,
		settings_button = settings_ref,
		refresh = refresh,
		hover = hover,
		get_rectangle = get_rectangle,
		destroy = portal.disconnect,
	}
	portal.render(React.createElement(widget_bounds, {
		bounds_ref = bounds_ref,
		move_ref = move_ref,
		delete_ref = delete_ref,
		settings_ref = settings_ref,
		rectangle = get_rectangle(),
		hidden = item.hidden,
		on_delete = delete,
		on_settings = settings,
		on_drag_start = drag_start,
		on_drag_move = actions.drag_move,
		on_drag_finish = actions.drag_finish,
	}))
	return view
end

return create_widget
