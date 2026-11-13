local editor_state = require(script.Parent.Parent.hud.editor_state)
local settings_registry = require(script.Parent.settings_registry)

const function open_hud_editor(): ()
	editor_state.request_enabled(true)
end

const function settings_definitions(): ()
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
		{
			category = "interface",
			id = "ui_animation_scale",
			kind = "slider",
			text = "UI animation scale",
			default = 100,
			minimum = 0,
			maximum = 400,
			step = 10,
			suffix = "%",
		},
	}
	for _, entry in entries do
		settings_registry.register(entry)
	end
end

return settings_definitions
