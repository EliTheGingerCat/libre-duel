local settings_registry = require(script.Parent.settings_registry)

local function placeholders(): ()
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
		{ category = "interface", id = "information", kind = "information", text = "Please do not the cat." },
		{ category = "interface", id = "warning", kind = "warning", text = "Please do not the cat. Final warning." },
		{
			category = "interface",
			id = "danger",
			kind = "danger",
			text = "You did the cat. This will have big consequences.",
		},
		{ category = "interface", id = "team", kind = "dropdown", text = "Team", default = "Red" },
		{ category = "interface", id = "opacity", kind = "slider", text = "UI Opacity", default = 50, suffix = "%" },
		{ category = "interface", id = "text", kind = "text", text = "Enter text...", default = "" },
		{ category = "interface", id = "switch_off", kind = "switch", text = "Switch off", default = false },
		{
			category = "interface",
			id = "search",
			kind = "text",
			text = "Search...",
			default = "",
			icon = "rbxassetid://113215135352721",
		},
		{
			category = "interface",
			id = "colour",
			kind = "colour",
			text = "AtOmOsphere colour",
			default = { colour = Color3.new(1, 0, 0), alpha = 1 },
		},
		{ category = "interface", id = "button", kind = "button", text = "Button" },
		{
			category = "interface",
			id = "dangerous_button",
			kind = "dangerous_button",
			text = "I agree to reset all settings.",
		},
		{
			category = "interface",
			id = "big_button",
			kind = "big_button",
			text = 'Big button\n<font color="rgb(180,180,180)" size="18">Gear icon included!</font>',
		},
		{ category = "interface", id = "switch_on", kind = "switch", text = "Switch on", default = true },
		{ category = "interface", id = "radio_on", kind = "checkbox", text = "Selected", default = true, round = true },
		{ category = "interface", id = "check_on", kind = "checkbox", text = "Selected", default = true },
		{ category = "interface", id = "check_off", kind = "checkbox", text = "Not selected", default = false },
		{
			category = "interface",
			id = "radio_off",
			kind = "checkbox",
			text = "Not selected",
			default = false,
			round = true,
		},
	}
	for _, entry in entries do
		settings_registry.register(entry)
	end
end

return placeholders
