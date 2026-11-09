local settings_registry = require(script.Parent.Parent.settings.settings_registry)

-- Stretches an animation length by the UI animation scale setting. 0% makes it instant.
local function scale_animation_time(seconds: number): number
	local percent = settings_registry.get("ui_animation_scale")
	return if typeof(percent) == "number" then seconds * percent / 100 else seconds
end

return scale_animation_time
