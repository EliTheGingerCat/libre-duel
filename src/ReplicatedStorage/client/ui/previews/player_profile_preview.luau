const ReplicatedStorage = game:GetService("ReplicatedStorage")

const KEYBINDS = require(ReplicatedStorage.client.util.KEYBINDS)
const PLACEHOLDER_PLAYER_PROFILE = require(script.Parent.PLACEHOLDER_PLAYER_PROFILE)
const React = require(ReplicatedStorage.Packages.react)
const player_profile_menu = require(script.Parent.Parent.player_profile.player_profile_menu)
const player_profile_types = require(script.Parent.Parent.player_profile.player_profile_types)
const use_studio_preview_toggle = require(script.Parent.use_studio_preview_toggle)

const function do_nothing(): () end

-- nothing here reaches the server, every action is a no op
const PLACEHOLDER_ACTIONS: player_profile_types.actions = {
	on_change_banner = do_nothing,
	on_edit_bio = do_nothing,
	on_report = do_nothing,
}

const function player_profile_preview()
	const enabled, set_enabled = use_studio_preview_toggle(KEYBINDS.player_profile_preview)
	const viewer_is_self, set_viewer_is_self = React.useState(false)
	const function close(): ()
		set_enabled(false)
	end
	-- reopening flips between your own profile and someone else's so both can be previewed
	const function flip_viewer_when_opened(): ()
		if enabled then
			set_viewer_is_self(not viewer_is_self)
		end
	end
	React.useEffect(flip_viewer_when_opened, { enabled })
	return React.createElement(player_profile_menu, {
		enabled = enabled,
		on_close = close,
		profile = PLACEHOLDER_PLAYER_PROFILE,
		failed = false,
		viewer_is_self = viewer_is_self,
		actions = PLACEHOLDER_ACTIONS,
	})
end

return player_profile_preview
