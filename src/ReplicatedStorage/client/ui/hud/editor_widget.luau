local geometry = require(script.Parent.editor_geometry)
local registry = require(script.Parent.registry)

type handle = {
	direction: Vector2,
	stroke: UIStroke,
}

export type view = {
	item: registry.entry,
	bounds: Frame,
	delete_button: ImageButton,
	settings_button: ImageButton,
	refresh: () -> (),
	hover: (boolean, Vector2) -> (),
	get_rectangle: () -> geometry.rectangle,
	destroy: () -> (),
}

local function create_widget(
	item: registry.entry,
	template: Frame,
	preview: Frame,
	on_delete: (registry.entry) -> (),
	on_settings: (registry.entry) -> ()
): view
	local bounds = template:Clone()
	bounds.AnchorPoint = Vector2.zero
	bounds.Parent = preview
	bounds.Visible = false
	bounds.ZIndex = 20
	local delete_button = bounds:FindFirstChild("Delete")
	local settings_button = bounds:FindFirstChild("Settings")
	assert(delete_button and delete_button:IsA("ImageButton"))
	assert(settings_button and settings_button:IsA("ImageButton"))
	local handles: { handle } = {}
	for _, child in bounds:GetDescendants() do
		if child:IsA("GuiObject") then
			child.ZIndex = 21
		end
	end
	for _, child in bounds:GetChildren() do
		if child:IsA("Frame") then
			local stroke = child:FindFirstChildOfClass("UIStroke")
			if stroke then
				table.insert(handles, {
					direction = Vector2.new(child.Position.X.Scale * 2 - 1, child.Position.Y.Scale * 2 - 1),
					stroke = stroke,
				})
			end
		end
	end

	local function get_rectangle(): geometry.rectangle
		return {
			position = item.container.AbsolutePosition - preview.AbsolutePosition,
			size = item.container.AbsoluteSize,
		}
	end

	local function refresh(): ()
		local rect = get_rectangle()
		bounds.Position = UDim2.fromOffset(rect.position.X, rect.position.Y)
		bounds.Size = UDim2.fromOffset(rect.size.X, rect.size.Y)
	end

	local function hover(hovered: boolean, pointer: Vector2): ()
		bounds.Visible = hovered and not item.hidden
		local direction = if hovered then geometry.get_handle(get_rectangle(), pointer) else nil
		for _, handle in handles do
			handle.stroke.Thickness = if direction == handle.direction then 6 else 5
		end
	end

	local delete_connection = delete_button.Activated:Connect(function()
		on_delete(item)
	end)
	local settings_connection = settings_button.Activated:Connect(function()
		on_settings(item)
	end)
	local function destroy(): ()
		delete_connection:Disconnect()
		settings_connection:Disconnect()
		bounds:Destroy()
	end

	return {
		item = item,
		bounds = bounds,
		delete_button = delete_button,
		settings_button = settings_button,
		refresh = refresh,
		hover = hover,
		get_rectangle = get_rectangle,
		destroy = destroy,
	}
end

return create_widget
