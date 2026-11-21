const ReplicatedStorage = game:GetService("ReplicatedStorage")

const KEYBINDS = require(ReplicatedStorage.client.util.KEYBINDS)
const PLACEHOLDER_GUILD = require(script.Parent.PLACEHOLDER_GUILD)
const React = require(ReplicatedStorage.Packages.react)
const guild_menu = require(script.Parent.Parent.guild.guild_menu)
const use_placeholder_invites = require(script.Parent.use_placeholder_invites)
const use_studio_preview_toggle = require(script.Parent.use_studio_preview_toggle)

const function guild_menu_preview()
	const enabled, set_enabled = use_studio_preview_toggle(KEYBINDS.guild_menu_preview)
	const invites = use_placeholder_invites()
	const function close(): ()
		set_enabled(false)
	end
	return React.createElement(guild_menu, {
		enabled = enabled,
		on_close = close,
		guild = PLACEHOLDER_GUILD,
		viewer_is_owner = true,
		invites = invites,
	})
end

return guild_menu_preview
