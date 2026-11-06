local create_widget = require(script.Parent.editor_widget)
local geometry = require(script.Parent.editor_geometry)
local registry = require(script.Parent.registry)

type drag_state = {
	view: create_widget.view,
	source: UIDragDetector,
	pointer: Vector2,
	start: geometry.rectangle,
	rect: geometry.rectangle,
	multiplier: number,
	anchor: Vector2,
	handle: Vector2?,
	guide_x: geometry.guide?,
	guide_y: geometry.guide?,
}

type controller = {
	begin: (create_widget.view, UIDragDetector, Vector2, Vector2?) -> boolean,
	update: (UIDragDetector, Vector2) -> (),
	finish: () -> (),
	finish_input: (UIDragDetector, Vector2) -> (),
	get_view: () -> create_widget.view?,
	get_pointer: () -> Vector2?,
	get_guides: () -> (geometry.guide?, geometry.guide?),
}

local function editor_drag(preview: Frame, screen: ScreenGui, views: { create_widget.view }): controller
	local current: drag_state? = nil
	local pointer: Vector2? = nil
	local function preview_factor(): number
		return preview.AbsoluteSize.X / math.max(1, screen.AbsoluteSize.X)
	end
	local function finish(): ()
		local previous = current
		current = nil
		if
			previous
			and preview.AbsoluteSize.X > 0
			and preview.AbsoluteSize.Y > 0
			and table.find(registry.get_entries(), previous.view.item)
		then
			previous.view.item.layout = geometry.get_layout(previous.rect, preview.AbsoluteSize, preview_factor())
			previous.view.item.refresh()
		end
	end
	local function begin(view: create_widget.view, source: UIDragDetector, position: Vector2, handle: Vector2?): boolean
		if current or view.item.hidden then
			return false
		end
		local rect = view.get_rectangle()
		if rect.size.X <= 0 or rect.size.Y <= 0 then
			return false
		end
		pointer = position
		current = {
			view = view,
			source = source,
			pointer = position,
			start = rect,
			rect = rect,
			multiplier = view.item.multiplier,
			anchor = view.item.container.AnchorPoint,
			handle = handle,
		}
		return true
	end
	local function update(source: UIDragDetector, position: Vector2): ()
		local drag = current
		if not drag or drag.source ~= source or preview.AbsoluteSize.X <= 0 or preview.AbsoluteSize.Y <= 0 then
			return
		end
		pointer = position
		local others: { geometry.rectangle } = {}
		for _, view in views do
			if view ~= drag.view and not view.item.hidden then
				table.insert(others, view.get_rectangle())
			end
		end
		local delta = position - drag.pointer
		local rect: geometry.rectangle
		if drag.handle then
			rect = geometry.resize(drag.start, delta, drag.handle, others, preview.AbsoluteSize, drag.multiplier)
			drag.view.item.multiplier = drag.multiplier * rect.size.X / drag.start.size.X
		else
			rect = geometry.move(drag.start, delta, others, preview.AbsoluteSize)
		end
		drag.rect = rect
		drag.guide_x, drag.guide_y = geometry.get_guides(rect, others, preview.AbsoluteSize)
		drag.view.item.layout = {
			anchor = drag.anchor,
			offset = (rect.position + rect.size * drag.anchor - preview.AbsoluteSize * drag.anchor) / preview_factor(),
		}
		drag.view.item.refresh()
		drag.view.refresh()
	end
	local function finish_input(source: UIDragDetector, position: Vector2): ()
		if current and current.source == source then
			update(source, position)
			finish()
		end
	end
	local function get_view(): create_widget.view?
		return if current then current.view else nil
	end
	local function get_pointer(): Vector2?
		return pointer
	end
	local function get_guides(): (geometry.guide?, geometry.guide?)
		if current then
			return current.guide_x, current.guide_y
		end
		return nil, nil
	end
	return {
		begin = begin,
		update = update,
		finish = finish,
		finish_input = finish_input,
		get_view = get_view,
		get_pointer = get_pointer,
		get_guides = get_guides,
	}
end

return editor_drag
