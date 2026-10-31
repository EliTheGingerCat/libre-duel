local geometry = require(script.Parent.editor_geometry)
local widget_copies = require(script.Parent.widget_copies)
local widget_corners = require(script.Parent.widget_corners)

export type factory = widget_copies.factory

export type entry = {
	content: GuiObject,
	container: Frame,
	screen: ScreenGui,
	scale: UIScale,
	layout: geometry.layout?,
	multiplier: number,
	hidden: boolean,
	preview: Frame?,
	corners: widget_corners.controller,
	create: factory?,
	on_remove: (() -> ())?,
	refresh: () -> (),
}

local entries: { entry } = {}
local listeners: { () -> () } = {}

local function notify(): ()
	for _, callback in table.clone(listeners) do
		callback()
	end
end

local function subscribe(callback: () -> ())
	table.insert(listeners, callback)
	local function disconnect(): ()
		local index = table.find(listeners, callback)
		if index then
			table.remove(listeners, index)
		end
	end
	return disconnect
end

local function register(content: GuiObject, screen: ScreenGui, create: factory?, on_remove: (() -> ())?)
	local default_position = content.Position
	local default_anchor = content.AnchorPoint
	local container = Instance.new("Frame")
	container.Name = "hud_widget"
	container.BackgroundTransparency = 1
	container.Size = UDim2.fromOffset(content.AbsoluteSize.X, content.AbsoluteSize.Y)
	container.Parent = screen
	local scale = Instance.new("UIScale")
	scale.Parent = container
	content.AnchorPoint = Vector2.zero
	content.Position = UDim2.fromOffset(0, 0)
	content.Parent = container

	local item: entry
	local function refresh(): ()
		local preview = item.preview
		local factor = if preview
			then math.max(0.001, preview.AbsoluteSize.X / math.max(1, screen.AbsoluteSize.X))
			else 1
		container.Parent = preview or screen
		scale.Scale = item.multiplier * factor
		container.Visible = not item.hidden
		local layout = item.layout
		if layout then
			container.AnchorPoint = layout.anchor
			container.Position =
				UDim2.new(layout.anchor.X, layout.offset.X * factor, layout.anchor.Y, layout.offset.Y * factor)
		else
			container.AnchorPoint = default_anchor
			container.Position = UDim2.new(
				default_position.X.Scale,
				default_position.X.Offset * factor,
				default_position.Y.Scale,
				default_position.Y.Offset * factor
			)
		end
	end
	item = {
		content = content,
		container = container,
		screen = screen,
		scale = scale,
		layout = if on_remove then { anchor = Vector2.new(0.5, 0.5), offset = Vector2.zero } else nil,
		multiplier = 1,
		hidden = false,
		preview = nil,
		corners = widget_corners(content),
		create = create,
		on_remove = on_remove,
		refresh = refresh,
	}

	local function on_size_changed(): ()
		local size = content.AbsoluteSize / math.max(0.001, scale.Scale)
		local current = container.Size
		if math.abs(current.X.Offset - size.X) > 0.01 or math.abs(current.Y.Offset - size.Y) > 0.01 then
			container.Size = UDim2.fromOffset(size.X, size.Y)
		end
	end

	local function on_position_changed(): ()
		if content.Position ~= UDim2.fromOffset(0, 0) then
			default_position = content.Position
			content.Position = UDim2.fromOffset(0, 0)
			refresh()
		end
	end

	local size_connection = content:GetPropertyChangedSignal("AbsoluteSize"):Connect(on_size_changed)
	local position_connection = content:GetPropertyChangedSignal("Position"):Connect(on_position_changed)
	on_size_changed()
	refresh()
	table.insert(entries, item)
	notify()

	local function unregister(): ()
		item.corners.disconnect()
		size_connection:Disconnect()
		position_connection:Disconnect()
		local index = table.find(entries, item)
		if index then
			table.remove(entries, index)
		end
		notify()
		content.Parent = screen
		content.AnchorPoint = default_anchor
		content.Position = default_position
		container:Destroy()
	end
	return unregister
end

local function add(item: entry): ()
	if item.hidden then
		item.hidden = false
		item.refresh()
		return
	end
	local create = item.create
	if not create then
		return
	end
	widget_copies.add(create)
end

local function remove(item: entry): ()
	item.hidden = true
	item.refresh()
	if item.on_remove then
		item.on_remove()
	end
end

return {
	add = add,
	remove = remove,
	clear_duplicates = widget_copies.clear,
	entries = entries,
	register = register,
	subscribe = subscribe,
}
