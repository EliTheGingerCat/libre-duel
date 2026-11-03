local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)

local function editor_drag_detector(props: {
	handle: Vector2?,
	on_start: (UIDragDetector, Vector2, Vector2?) -> (),
	on_move: (UIDragDetector, Vector2) -> (),
	on_finish: (UIDragDetector, Vector2) -> (),
})
	local function begin(detector: UIDragDetector, position: Vector2): ()
		props.on_start(detector, position, props.handle)
	end
	return React.createElement("UIDragDetector", {
		Name = "drag_detector",
		CursorIcon = "rbxasset://textures/Cursors/KeyboardMouse/ArrowCursor.png",
		DragStyle = Enum.UIDragDetectorDragStyle.TranslatePlane,
		ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomOffset,
		[React.Event.DragStart] = begin,
		[React.Event.DragContinue] = props.on_move,
		[React.Event.DragEnd] = props.on_finish,
	})
end

return editor_drag_detector
