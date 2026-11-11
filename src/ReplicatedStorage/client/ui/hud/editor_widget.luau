local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local geometry = require(script.Parent.editor_geometry)
local mount_portal = require(script.Parent.mount_portal)
local registry = require(script.Parent.registry)
local widget_bounds = require(script.Parent.widget_bounds)

-- Below this size the actions would cover the widget, so they move outside it.
const COMPACT_SIZE = Vector2.new(108, 72)
const ACTION_WIDTH = 72
const ACTION_DISTANCE = 38
const ACTION_HALF_HEIGHT = 18
const HANDLE_OUTSET = 9
-- Below this size the handles would cover the whole widget, leaving nothing to drag it by.
const HANDLE_ROOM = 36
-- Below this length a side dot would run into the corner dots next to it.
const SIDE_DOT_ROOM = 30
-- Covers the handles and the gap up to the actions, so hover survives the trip between them.
const HOVER_MARGIN = 20

export type view = {
	item: registry.entry,
	bounds: { current: Frame? },
	delete_button: { current: ImageButton? },
	settings_button: { current: ImageButton? },
	refresh: () -> (),
	hover: (boolean, Vector2, boolean) -> (),
	get_rectangle: () -> geometry.rectangle,
	in_hover_margin: (Vector2) -> boolean,
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
	local function is_compact(rect: geometry.rectangle): boolean
		return rect.size.X < COMPACT_SIZE.X or rect.size.Y < COMPACT_SIZE.Y
	end
	local function in_hover_margin(pointer: Vector2): boolean
		local rect = get_rectangle()
		if not is_compact(rect) then
			return false
		end
		local margin = Vector2.one * HOVER_MARGIN
		return geometry.contains({ position = rect.position - margin, size = rect.size + margin * 2 }, pointer)
	end
	local function get_action_position(rect: geometry.rectangle): UDim2
		if not is_compact(rect) then
			return UDim2.fromScale(0.5, 0.5)
		end
		-- Stays on screen: flips below when there is no room above, and slides away from the sides.
		local centre = rect.position.X + rect.size.X / 2
		local half_width = ACTION_WIDTH / 2
		local shift = math.clamp(centre, half_width, math.max(half_width, preview.AbsoluteSize.X - half_width)) - centre
		if rect.position.Y >= ACTION_DISTANCE + ACTION_HALF_HEIGHT then
			return UDim2.new(0.5, shift, 0, -ACTION_DISTANCE)
		end
		return UDim2.new(0.5, shift, 1, ACTION_DISTANCE)
	end
	local function refresh(): ()
		local bounds = bounds_ref.current
		if not bounds then
			return
		end
		local rect = get_rectangle()
		bounds.Visible = registry.is_shown(item)
		bounds.Position = UDim2.fromOffset(rect.position.X, rect.position.Y)
		bounds.Size = UDim2.fromOffset(rect.size.X, rect.size.Y)
	end
	local function hover(hovered: boolean, pointer: Vector2, dragging: boolean): ()
		local bounds = bounds_ref.current
		if not bounds then
			return
		end
		local visible = hovered and registry.is_shown(item)
		local move = move_ref.current
		if move then
			move.BackgroundTransparency = if dragging then 0.7 elseif visible then 0.8 else 1
			local stroke = move:FindFirstChildOfClass("UIStroke")
			if stroke then
				stroke.Transparency = if visible then 0 else 0.6
			end
		end
		local rect = get_rectangle()
		local tiny = rect.size.X < HANDLE_ROOM or rect.size.Y < HANDLE_ROOM
		local action_position = get_action_position(rect)
		local direction = if visible then geometry.get_handle(rect, pointer) else nil
		for _, child in bounds:GetChildren() do
			if child:IsA("Frame") and child.Name:match("^handle_") then
				local handle = Vector2.new(child.Position.X.Scale * 2 - 1, child.Position.Y.Scale * 2 - 1)
				local crowded = (handle.X == 0 and rect.size.X < SIDE_DOT_ROOM)
					or (handle.Y == 0 and rect.size.Y < SIDE_DOT_ROOM)
				-- The grab area moves outside a tiny widget, while its dot stays on the outline.
				local outset = if tiny then handle * HANDLE_OUTSET else Vector2.zero
				child.Visible = visible and not crowded
				child.Position = UDim2.new(child.Position.X.Scale, outset.X, child.Position.Y.Scale, outset.Y)
				local marker = child:FindFirstChild("marker")
				if marker and marker:IsA("Frame") then
					marker.Position = UDim2.new(0.5, -outset.X, 0.5, -outset.Y)
				end
				local stroke = if marker then marker:FindFirstChildOfClass("UIStroke") else nil
				if stroke then
					stroke.Thickness = if direction == handle then 6 else 5
				end
			elseif child:IsA("ImageButton") then
				child.Visible = visible and not dragging
				child.Position = action_position
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
		in_hover_margin = in_hover_margin,
		destroy = portal.disconnect,
	}
	portal.render(React.createElement(widget_bounds, {
		bounds_ref = bounds_ref,
		move_ref = move_ref,
		delete_ref = delete_ref,
		settings_ref = settings_ref,
		rectangle = get_rectangle(),
		hidden = not registry.is_shown(item),
		on_delete = delete,
		on_settings = settings,
		on_drag_start = drag_start,
		on_drag_move = actions.drag_move,
		on_drag_finish = actions.drag_finish,
	}))
	return view
end

return create_widget
