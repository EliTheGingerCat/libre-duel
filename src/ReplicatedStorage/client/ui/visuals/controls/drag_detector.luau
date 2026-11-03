local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local get_drag_offset = require(script.Parent.get_drag_offset)

local function drag_detector(props: { axis: Vector2?, on_changed: (Vector2) -> () })
	local function update(detector: UIDragDetector, position: Vector2): ()
		local parent = detector.Parent
		assert(parent and parent:IsA("GuiObject"))
		local size = parent.AbsoluteSize
		local offset = get_drag_offset(parent, position)
		props.on_changed(Vector2.new(offset.X / math.max(1, size.X), offset.Y / math.max(1, size.Y)))
	end
	return React.createElement("UIDragDetector", {
		DragStyle = if props.axis
			then Enum.UIDragDetectorDragStyle.TranslateLine
			else Enum.UIDragDetectorDragStyle.TranslatePlane,
		DragAxis = props.axis,
		ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomOffset,
		[React.Event.DragStart] = update,
		[React.Event.DragContinue] = update,
	})
end

return drag_detector
