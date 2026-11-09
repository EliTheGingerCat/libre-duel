local UserGameSettings = UserSettings():GetService("UserGameSettings")

local editor_state = require(script.Parent.Parent.hud.editor_state)
local settings_registry = require(script.Parent.settings_registry)

local function open_hud_editor(): ()
	editor_state.request_enabled(true)
end

local function ui_blur_enabled(): boolean
	return settings_registry.get("ui_blur") == true
end

-- UIBlur only renders at this level or above, and Automatic counts as 0.
local function ui_blur_unsupported(): boolean
	return ui_blur_enabled() and UserGameSettings.SavedQualityLevel.Value < 8
end

local function settings_definitions(): ()
	settings_registry.register_category({
		id = "interface",
		text = "Interface",
		icon = "rbxassetid://75711772548687",
	})
	settings_registry.register_category({
		id = "privacy",
		text = "Privacy",
		icon = "rbxassetid://80524814855827",
	})
	settings_registry.register_category({
		id = "visuals",
		text = "Visuals",
		icon = "rbxassetid://121337450209631",
	})
	settings_registry.register_category({
		id = "about",
		text = "About",
		icon = "rbxassetid://126734453814705",
		bottom = true,
	})
	local entries: { settings_registry.entry } = {
		{
			category = "interface",
			id = "hud_editor",
			kind = "big_button",
			icon = "rbxassetid://115802146437284",
			text = 'Enter HUD editor\n<font color="rgb(180,180,180)" size="18">Rearrange or insert HUD elements</font>',
			on_activated = open_hud_editor,
		},
		{ category = "interface", id = "ui_blur", kind = "switch", text = "UI blur", default = false },
		{
			category = "interface",
			id = "ui_blur_warning",
			kind = "warning",
			text = "This setting has known performance issues.",
			visible = ui_blur_enabled,
			parent = "ui_blur",
		},
		{
			category = "interface",
			id = "ui_blur_graphics",
			kind = "danger",
			text = "Your graphics level must be 8 or higher for this to work!",
			visible = ui_blur_unsupported,
			parent = "ui_blur",
		},
		{
			category = "interface",
			id = "ui_animation_scale",
			kind = "slider",
			text = "UI animation scale",
			default = 100,
			minimum = 0,
			maximum = 200,
			step = 10,
			suffix = "%",
		},
	}
	for _, entry in entries do
		settings_registry.register(entry)
	end
	UserGameSettings:GetPropertyChangedSignal("SavedQualityLevel"):Connect(settings_registry.refresh)
end

return settings_definitions
