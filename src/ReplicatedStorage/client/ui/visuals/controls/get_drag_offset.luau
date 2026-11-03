local GuiService = game:GetService("GuiService")

local function get_drag_offset(target: GuiObject, position: Vector2): Vector2
	local screen = target:FindFirstAncestorOfClass("ScreenGui")
	local inset = if screen and screen.IgnoreGuiInset then GuiService:GetGuiInset() else Vector2.zero
	return position - inset - target.AbsolutePosition
end

return get_drag_offset
