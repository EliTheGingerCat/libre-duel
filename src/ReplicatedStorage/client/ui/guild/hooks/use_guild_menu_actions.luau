const ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const guild_snapshot_types = require(ReplicatedStorage.shared.guild.guild_snapshot_types)
const guild_types = require(script.Parent.Parent.guild_types)
const menu_navigation = require(script.Parent.Parent.Parent.navigation.menu_navigation)
const request_guild_action = require(ReplicatedStorage.client.guild.request_guild_action)
const use_viewed_guild = require(script.Parent.use_viewed_guild)

export type guild_menu_actions = {
	actions: guild_types.actions,
	creating: boolean,
	answering_invite_guild_id: string?,
}

const function run_action(name: request_guild_action.action_name, argument: unknown?): ()
	task.spawn(request_guild_action, name, argument)
end

const function member_action(action: guild_types.member_action, member: guild_types.member): ()
	if action == "view_profile" then
		menu_navigation.open_player_profile(member.user_id)
	elseif action == "kick" then
		run_action("kick_guild_member", member.user_id)
	elseif action == "ban" then
		run_action("ban_guild_member", member.user_id)
	end
end

const function banned_member_action(
	action: guild_types.banned_member_action,
	banned_member: guild_types.banned_member
): ()
	if action == "view_profile" then
		menu_navigation.open_player_profile(banned_member.user_id)
	elseif action == "unban" then
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

const function rename(name: string): ()
	run_action("edit_guild_info", { name = name })
end

const function edit_description(description: string): ()
	run_action("edit_guild_info", { description = description })
end

const function change_icon(): ()
	run_action("request_guild_image_change", "icon")
end

const function change_banner(): ()
	run_action("request_guild_image_change", "banner")
end

const function view_guild_info(invite: guild_types.incoming_invite): ()
	menu_navigation.open_guild(invite.guild_id)
end

-- TODO: blocking guilds isn't designed yet
const function block_guild(_invite: guild_types.incoming_invite): () end

-- every button in the guild menu ends up here and gets sent to the server
const function use_guild_menu_actions(viewed_guild: use_viewed_guild.viewed_guild): guild_menu_actions
	const creating, set_creating = React.useState(false)
	const answering_invite_guild_id: string?, set_answering_invite_guild_id: (string?) -> () =
		React.useState(nil :: string?)

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

	return {
		creating = creating,
		answering_invite_guild_id = answering_invite_guild_id,
		actions = {
			on_create = create,
			on_leave = leave,
			on_delete = delete,
			on_rename = rename,
			on_edit_description = edit_description,
			on_change_icon = change_icon,
			on_change_banner = change_banner,
			on_member_action = member_action,
			on_banned_member_action = banned_member_action,
			on_accept_invite = accept_invite,
			on_decline_invite = decline_invite,
			on_view_guild_info = view_guild_info,
			on_block_guild = block_guild,
			on_select_viewed_page = viewed_guild.select_page,
		},
	}
end

return use_guild_menu_actions
