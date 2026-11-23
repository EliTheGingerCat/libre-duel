const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const create_player_summary = require(script.Parent.Parent.format.create_player_summary)
const guild_snapshot_types = require(ReplicatedStorage.shared.guild.guild_snapshot_types)
const guild_types = require(script.Parent.Parent.guild_types)
const player_row_types = require(script.Parent.Parent.Parent.player_row.player_row_types)
const request_guild_action = require(ReplicatedStorage.client.guild.request_guild_action)
const use_server_players = require(script.Parent.use_server_players)
const user_info_cache = require(ReplicatedStorage.client.guild.user_info_cache)

const SEARCH_DELAY = 0.5

const search_remote = ReplicatedStorage.remotes.guild.search_guild_invite_candidate

const function request_invite(user_id: number): ()
	request_guild_action("invite_to_guild", user_id)
end

const function request_cancel(user_id: number): ()
	request_guild_action("cancel_guild_invite", user_id)
end

const function invite_player(player: player_row_types.player_summary): ()
	task.spawn(request_invite, player.user_id)
end

const function cancel_invite(player: player_row_types.player_summary): ()
	task.spawn(request_cancel, player.user_id)
end

const function server_player_matches_query(player: Player, lowered_query: string): boolean
	return lowered_query == ""
		or string.find(string.lower(player.Name), lowered_query, 1, true) ~= nil
		or string.find(string.lower(player.DisplayName), lowered_query, 1, true) ~= nil
end

-- the invites page for owners, lists everyone in this server matching the query plus an exact username lookup from the server
const function use_outgoing_guild_invites(guild: guild_snapshot_types.guild_snapshot?): guild_types.invites
	const query, set_query = React.useState("")
	const server_players = use_server_players()
	const search_results, set_search_results = React.useState({} :: { guild_snapshot_types.player_search_result })

	const function search_after_typing_stops(): () -> ()
		if query == "" then
			set_search_results({})
		end
		const function search(): ()
			if query == "" then
				return
			end
			const ok, results = pcall(search_remote.InvokeServer, search_remote, query)
			if ok and typeof(results) == "table" then
				set_search_results(results :: { guild_snapshot_types.player_search_result })
			end
		end
		const thread = task.delay(SEARCH_DELAY, search)
		const function cancel(): ()
			-- errors when the thread already finished
			pcall(task.cancel, thread)
		end
		return cancel
	end
	React.useEffect(search_after_typing_stops, { query })

	const excluded_ids: { [number]: true } = { [Players.LocalPlayer.UserId] = true }
	const outgoing = {}
	if guild then
		const invited_ids = {}
		for _, invite in guild.outgoing_invites do
			table.insert(invited_ids, invite.user_id)
		end
		user_info_cache.request(invited_ids)
		for _, invite in guild.outgoing_invites do
			excluded_ids[invite.user_id] = true
			table.insert(outgoing, create_player_summary(invite.user_id, ""))
		end
		for _, member in guild.members do
			excluded_ids[member.user_id] = true
		end
	end
	const results = {}
	const lowered_query = string.lower(query)
	for _, server_player in server_players do
		if not excluded_ids[server_player.UserId] and server_player_matches_query(server_player, lowered_query) then
			excluded_ids[server_player.UserId] = true
			user_info_cache.remember(
				server_player.UserId,
				{ username = server_player.Name, display_name = server_player.DisplayName }
			)
			table.insert(results, create_player_summary(server_player.UserId, ""))
		end
	end
	for _, result in search_results do
		user_info_cache.remember(result.user_id, { username = result.username, display_name = result.display_name })
		if not excluded_ids[result.user_id] then
			table.insert(results, create_player_summary(result.user_id, ""))
		end
	end

	return {
		outgoing = outgoing,
		search_results = results,
		query = query,
		on_search = set_query,
		on_invite = invite_player,
		on_cancel = cancel_invite,
	}
end

return use_outgoing_guild_invites
