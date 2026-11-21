const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const UserInputService = game:GetService("UserInputService")

const React = require(ReplicatedStorage.Packages.react)
const can_see_discord_links = require(ReplicatedStorage.client.guild.can_see_discord_links)
const format_guild_snapshot = require(script.Parent.format.format_guild_snapshot)
const format_incoming_invite = require(script.Parent.format.format_incoming_invite)
const guild_menu = require(script.Parent.guild_menu)
const guild_snapshot_types = require(ReplicatedStorage.shared.guild.guild_snapshot_types)
const guild_types = require(script.Parent.guild_types)
const request_guild_action = require(ReplicatedStorage.client.guild.request_guild_action)
const topbarplus = require(ReplicatedStorage.Packages.topbarplus)
const use_guild_invites = require(script.Parent.use_guild_invites)
const use_guild_state = require(ReplicatedStorage.client.guild.use_guild_state)
const use_user_info_version = require(ReplicatedStorage.client.guild.use_user_info_version)
const user_info_cache = require(ReplicatedStorage.client.guild.user_info_cache)

const fetch_guild_info_remote = ReplicatedStorage.remotes.guild.fetch_guild_info

const GUILD_ICON = "rbxassetid://127844573570900"

type icon_handle = { deselect: (icon_handle) -> icon_handle }

const function run_action(name: request_guild_action.action_name, argument: unknown?): ()
	task.spawn(request_guild_action, name, argument)
end

-- shows the real guild menu, everything it needs comes from the server through guild_state
const function guild_menu_controller()
	const enabled, set_enabled = React.useState(false)
	const show_discord, set_show_discord = React.useState(false)
	const creating, set_creating = React.useState(false)
	const answering_invite_guild_id: string?, set_answering_invite_guild_id: (string?) -> () =
		React.useState(nil :: string?)
	const viewed_snapshot: guild_snapshot_types.guild_snapshot?, set_viewed_snapshot: (guild_snapshot_types.guild_snapshot?) -> () =
		React.useState(nil :: guild_snapshot_types.guild_snapshot?)
	const icon_ref = React.useRef(nil :: icon_handle?)
	const state = use_guild_state()
	use_user_info_version()
	const invites = use_guild_invites(state.guild)

	const function mount(): () -> ()
		const icon = topbarplus.new():setName("Guild"):setImage(GUILD_ICON):setCaption("Guild"):align("Left")
		icon_ref.current = icon
		const function open(): ()
			set_enabled(true)
		end
		const function close(): ()
			set_enabled(false)
		end
		const function key(input: InputObject, processed: boolean): ()
			if not processed and (input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB) then
				icon:deselect()
			end
		end
		const connections =
			{ icon.selected:Connect(open), icon.deselected:Connect(close), UserInputService.InputBegan:Connect(key) }
		const function check_discord_policy(): ()
			set_show_discord(can_see_discord_links())
		end
		task.spawn(check_discord_policy)
		const function disconnect(): ()
			for _, connection in connections do
				connection:Disconnect()
			end
			icon:destroy()
			icon_ref.current = nil
		end
		return disconnect
	end
	React.useEffect(mount, {})

	const function close_menu(): ()
		if icon_ref.current then
			icon_ref.current:deselect()
		end
		set_enabled(false)
		set_viewed_snapshot(nil)
	end

	const function create(info: guild_snapshot_types.guild_info_input): ()
		const function request(): ()
			set_creating(true)
			request_guild_action("create_guild", info)
			set_creating(false)
		end
		task.spawn(request)
	end
	const function answer_invite(invite: guild_types.incoming_invite, action: request_guild_action.action_name): ()
		const function request(): ()
			set_answering_invite_guild_id(invite.guild_id)
			request_guild_action(action, invite.guild_id)
			set_answering_invite_guild_id(nil)
		end
		task.spawn(request)
	end
	const function accept_invite(invite: guild_types.incoming_invite): ()
		answer_invite(invite, "accept_guild_invite")
	end
	const function decline_invite(invite: guild_types.incoming_invite): ()
		answer_invite(invite, "decline_guild_invite")
	end
	const function view_guild_info(invite: guild_types.incoming_invite): ()
		const function fetch(): ()
			const ok, snapshot = pcall(fetch_guild_info_remote.InvokeServer, fetch_guild_info_remote, invite.guild_id)
			if ok and typeof(snapshot) == "table" then
				set_viewed_snapshot(snapshot :: guild_snapshot_types.guild_snapshot)
			end
		end
		task.spawn(fetch)
	end
	const function member_action(action: guild_types.member_action, member: guild_types.member): ()
		-- TODO: open the player profile once profiles load real data
		if action == "kick" then
			run_action("kick_guild_member", member.user_id)
		elseif action == "ban" then
			run_action("ban_guild_member", member.user_id)
		end
	end
	const function banned_member_action(
		action: guild_types.banned_member_action,
		banned_member: guild_types.banned_member
	): ()
		-- TODO: open the player profile once profiles load real data
		if action == "unban" then
			run_action("unban_guild_member", banned_member.user_id)
		end
	end
	const function leave(): ()
		run_action("leave_guild")
	end
	const function delete(): ()
		-- the server answers with a confirmation popup, nothing is deleted yet
		run_action("delete_guild")
	end
	-- TODO: blocking guilds isn't designed yet
	const function block_guild(_invite: guild_types.incoming_invite): () end
	const function close_viewed_guild(): ()
		set_viewed_snapshot(nil)
	end

	const inviter_ids = {}
	for _, invite in state.incoming_invites do
		table.insert(inviter_ids, invite.inviter_id)
	end
	user_info_cache.request(inviter_ids)
	const incoming_invites = {}
	for _, invite in state.incoming_invites do
		table.insert(incoming_invites, format_incoming_invite(invite))
	end

	return React.createElement(guild_menu, {
		enabled = enabled,
		on_close = close_menu,
		guild = if state.guild then format_guild_snapshot(state.guild, show_discord) else nil,
		viewed_guild = if viewed_snapshot then format_guild_snapshot(viewed_snapshot, show_discord) else nil,
		viewer_is_owner = state.guild ~= nil and state.guild.owner_id == Players.LocalPlayer.UserId,
		invites = invites,
		incoming_invites = incoming_invites,
		creating = creating,
		answering_invite_guild_id = answering_invite_guild_id,
		actions = {
			on_create = create,
			on_leave = leave,
			on_delete = delete,
			on_member_action = member_action,
			on_banned_member_action = banned_member_action,
			on_accept_invite = accept_invite,
			on_decline_invite = decline_invite,
			on_view_guild_info = view_guild_info,
			on_block_guild = block_guild,
			on_close_viewed_guild = close_viewed_guild,
		},
	})
end

return guild_menu_controller
