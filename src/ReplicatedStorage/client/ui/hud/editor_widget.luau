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

local function create_widget(
	item: registry.entry,
	preview: Frame,
	on_delete: (registry.entry) -> (),
	on_settings: (registry.entry) -> ()
): view
	local bounds_ref = React.createRef()
	local delete_ref = React.createRef()
	local settings_ref = React.createRef()
	local portal = mount_portal(preview)
	local function delete(): ()
		on_delete(item)
	end
	local function settings(): ()
		on_settings(item)
	end
	portal.render(React.createElement(widget_bounds, {
		bounds_ref = bounds_ref,
		delete_ref = delete_ref,
		settings_ref = settings_ref,
		on_delete = delete,
		on_settings = settings,
	}))
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
		bounds.Position = UDim2.fromOffset(rect.position.X, rect.position.Y)
		bounds.Size = UDim2.fromOffset(rect.size.X, rect.size.Y)
	end
	local function hover(hovered: boolean, pointer: Vector2): ()
		local bounds = bounds_ref.current
		if not bounds then
			return
		end
		bounds.Visible = hovered and not item.hidden
		local direction = if hovered then geometry.get_handle(get_rectangle(), pointer) else nil
		for _, child in bounds:GetChildren() do
			if child:IsA("Frame") then
				local stroke = child:FindFirstChildOfClass("UIStroke")
				if stroke then
					local handle = Vector2.new(child.Position.X.Scale * 2 - 1, child.Position.Y.Scale * 2 - 1)
					stroke.Thickness = if direction == handle then 6 else 5
				end
			end
		end
	end
	return {
		item = item,
		bounds = bounds_ref,
		delete_button = delete_ref,
		settings_button = settings_ref,
		refresh = refresh,
		hover = hover,
		get_rectangle = get_rectangle,
		destroy = portal.disconnect,
	}
end

return create_widget
