local ReplicatedStorage = game:GetService("ReplicatedStorage")

const HUD_DEFAULTS = require(script.Parent.HUD_DEFAULTS)
local Signal = require(ReplicatedStorage.Packages.signal)
local input_device = require(script.Parent.Parent.Parent.util.input_device)
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
	supports_device: { string }?,
	default_hidden: boolean,
	preview: Frame?,
	corners: widget_corners.controller,
	create: factory?,
	on_remove: (() -> ())?,
	render_preview: (() -> unknown)?,
	refresh: () -> (),
}

local entries: { entry } = {}
local changed = Signal.new()

-- Removed by the player, or not meant for the device they're on.
const function is_shown(item: entry): boolean
	return not item.hidden and input_device.supports(item.supports_device)
end

const function notify(): ()
	changed:Fire()
end

const function subscribe(callback: () -> ())
	local connection = changed:Connect(callback)
	const function disconnect(): ()
		connection:Disconnect()
	end
	return disconnect
end

-- A copy, so callers cannot change the registry without notifying subscribers.
const function get_entries(): { entry }
	return table.clone(entries)
end

const function register(
	content: GuiObject,
	screen: ScreenGui,
	create: factory?,
	on_remove: (() -> ())?,
	render_preview: (() -> unknown)?,
	default_hidden: boolean?
)
	local default_position = content.Position
	local default_anchor = content.AnchorPoint
	local container = content.Parent
	assert(container and container:IsA("Frame"))
	container.Size = UDim2.fromOffset(content.AbsoluteSize.X, content.AbsoluteSize.Y)
	local scale = container:FindFirstChildOfClass("UIScale")
	assert(scale)
	content.AnchorPoint = Vector2.zero
	content.Position = UDim2.fromOffset(0, 0)

	-- Copies are added on purpose, so they always start visible.
	local starts_hidden = default_hidden == true and not on_remove

	local item: entry
	const function refresh(): ()
		local preview = item.preview
		local preview_screen = if preview then preview:FindFirstAncestorOfClass("ScreenGui") else nil
		local width = if preview_screen then preview_screen.AbsoluteSize.X else screen.AbsoluteSize.X
		local factor = if preview then math.max(0.001, preview.AbsoluteSize.X / math.max(1, width)) else 1
		container.Parent = preview or screen
		scale.Scale = item.multiplier * factor
		container.Visible = is_shown(item)
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
	local defaults = HUD_DEFAULTS[screen.Name]
	item = {
		content = content,
		container = container,
		screen = screen,
		scale = scale,
		layout = if on_remove then { anchor = Vector2.new(0.5, 0.5), offset = Vector2.zero } else nil,
		multiplier = 1,
		hidden = starts_hidden,
		supports_device = if defaults then defaults.supports_device else nil,
		default_hidden = starts_hidden,
		preview = nil,
		corners = widget_corners(content),
		create = create,
		on_remove = on_remove,
		render_preview = render_preview,
		refresh = refresh,
	}

	const function on_size_changed(): ()
		local size = content.AbsoluteSize / math.max(0.001, scale.Scale)
		local current = container.Size
		if math.abs(current.X.Offset - size.X) > 0.01 or math.abs(current.Y.Offset - size.Y) > 0.01 then
			container.Size = UDim2.fromOffset(size.X, size.Y)
		end
	end

	const function on_position_changed(): ()
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

	const function unregister(): ()
		item.corners.disconnect()
		size_connection:Disconnect()
		position_connection:Disconnect()
		local index = table.find(entries, item)
		if index then
			table.remove(entries, index)
		end
		notify()
		container.Parent = screen
		content.AnchorPoint = default_anchor
		content.Position = default_position
	end
	return unregister
end

const function add(item: entry): ()
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

const function remove(item: entry): ()
	item.hidden = true
	item.refresh()
	if item.on_remove then
		item.on_remove()
	end
end

-- Removes every copy and puts the built-in widgets back where they started.
const function reset(): ()
	widget_copies.clear()
	for _, item in entries do
		if not item.on_remove then
			item.layout = nil
			item.multiplier = 1
			item.hidden = item.default_hidden
			item.refresh()
		end
	end
	notify()
end

const function on_device_changed(): ()
	for _, item in entries do
		item.refresh()
	end
	notify()
end

input_device.changed:Connect(on_device_changed)

return {
	add = add,
	is_shown = is_shown,
	remove = remove,
	reset = reset,
	clear_duplicates = widget_copies.clear,
	get_entries = get_entries,
	register = register,
	subscribe = subscribe,
}
