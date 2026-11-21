const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const format_guild_snapshot = require(script.Parent.format.format_guild_snapshot)
const guild_menu = require(script.Parent.guild_menu)
const use_can_see_discord_links = require(ReplicatedStorage.client.guild.use_can_see_discord_links)
const use_guild_menu_actions = require(script.Parent.hooks.use_guild_menu_actions)
const use_guild_state = require(ReplicatedStorage.client.guild.use_guild_state)
const use_incoming_guild_invites = require(script.Parent.hooks.use_incoming_guild_invites)
const use_outgoing_guild_invites = require(script.Parent.hooks.use_outgoing_guild_invites)
const use_topbar_menu_icon = require(script.Parent.Parent.topbar.use_topbar_menu_icon)
const use_user_info_version = require(ReplicatedStorage.client.guild.use_user_info_version)
const use_viewed_guild = require(script.Parent.hooks.use_viewed_guild)

const GUILD_ICON = "rbxassetid://127844573570900"

-- shows the real guild menu, everything it needs comes from the server through guild_state
const function guild_menu_root()
	const menu_icon = use_topbar_menu_icon("Guild", GUILD_ICON)
	const state = use_guild_state()
	const show_discord = use_can_see_discord_links()
	-- member names inside the formatted guild come from user_info_cache
	use_user_info_version()
	const viewed_guild = use_viewed_guild(menu_icon.enabled)
	const menu_actions = use_guild_menu_actions(viewed_guild)
	const outgoing_invites = use_outgoing_guild_invites(state.guild)
	const incoming_invites = use_incoming_guild_invites(state.incoming_invites)

	return React.createElement(guild_menu, {
		enabled = menu_icon.enabled,
		on_close = menu_icon.close,
		guild = if state.guild then format_guild_snapshot(state.guild, show_discord) else nil,
		viewed_guild = if viewed_guild.snapshot
			then format_guild_snapshot(viewed_guild.snapshot, show_discord)
			else nil,
		viewer_is_owner = state.guild ~= nil and state.guild.owner_id == Players.LocalPlayer.UserId,
		invites = outgoing_invites,
		incoming_invites = incoming_invites,
		creating = menu_actions.creating,
		answering_invite_guild_id = menu_actions.answering_invite_guild_id,
		actions = menu_actions.actions,
	})
end

return guild_menu_root
