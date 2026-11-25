const ReplicatedStorage = game:GetService("ReplicatedStorage")

const KEYBINDS = require(ReplicatedStorage.client.util.KEYBINDS)
const PLACEHOLDER_GUILD = require(script.Parent.PLACEHOLDER_GUILD)
const PLACEHOLDER_INCOMING_INVITES = require(script.Parent.PLACEHOLDER_INCOMING_INVITES)
const React = require(ReplicatedStorage.Packages.react)
const guild_menu = require(script.Parent.Parent.guild.guild_menu)
const guild_types = require(script.Parent.Parent.guild.guild_types)
const use_placeholder_invites = require(script.Parent.use_placeholder_invites)
const use_studio_preview_toggle = require(script.Parent.use_studio_preview_toggle)

const function do_nothing(): () end

-- nothing here reaches the server, every action is a no op
const PLACEHOLDER_ACTIONS: guild_types.actions = {
	on_create = do_nothing,
	on_leave = do_nothing,
	on_delete = do_nothing,
	on_rename = do_nothing,
	on_edit_description = do_nothing,
	on_change_icon = do_nothing,
	on_change_banner = do_nothing,
	on_member_action = do_nothing,
	on_banned_member_action = do_nothing,
	on_accept_invite = do_nothing,
	on_decline_invite = do_nothing,
	on_view_guild_info = do_nothing,
	on_block_guild = do_nothing,
	on_select_viewed_page = do_nothing,
}

const function guild_menu_preview()
	const enabled, set_enabled = use_studio_preview_toggle(KEYBINDS.guild_menu_preview)
	const has_guild, set_has_guild = React.useState(true)
	const invites = use_placeholder_invites()
	const function close(): ()
		set_enabled(false)
	end
	-- reopening flips between the in guild and no guild layouts so both can be previewed
	const function flip_layout_when_opened(): ()
		if enabled then
			set_has_guild(not has_guild)
		end
	end
	React.useEffect(flip_layout_when_opened, { enabled })
	return React.createElement(guild_menu, {
		enabled = enabled,
		on_close = close,
		guild = if has_guild then PLACEHOLDER_GUILD else nil,
		viewed_page = "info",
		viewer_is_owner = true,
		invites = invites,
		incoming_invites = PLACEHOLDER_INCOMING_INVITES,
		creating = false,
		actions = PLACEHOLDER_ACTIONS,
	})
end

return guild_menu_preview
