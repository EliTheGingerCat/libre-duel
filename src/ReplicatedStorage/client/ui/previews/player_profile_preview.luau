const ReplicatedStorage = game:GetService("ReplicatedStorage")

const KEYBINDS = require(ReplicatedStorage.client.util.KEYBINDS)
const PLACEHOLDER_PLAYER_PROFILE = require(script.Parent.PLACEHOLDER_PLAYER_PROFILE)
const React = require(ReplicatedStorage.Packages.react)
const player_profile_menu = require(script.Parent.Parent.player_profile.player_profile_menu)
const use_studio_preview_toggle = require(script.Parent.use_studio_preview_toggle)

const function player_profile_preview()
	const enabled, set_enabled = use_studio_preview_toggle(KEYBINDS.player_profile_preview)
	const function close(): ()
		set_enabled(false)
	end
	return React.createElement(player_profile_menu, {
		enabled = enabled,
		on_close = close,
		profile = PLACEHOLDER_PLAYER_PROFILE,
	})
end

return player_profile_preview
