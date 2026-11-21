const ReplicatedStorage = game:GetService("ReplicatedStorage")

const PLACEHOLDER_INVITE_CANDIDATES = require(script.Parent.PLACEHOLDER_INVITE_CANDIDATES)
const React = require(ReplicatedStorage.Packages.react)
const guild_types = require(script.Parent.Parent.guild.guild_types)
const player_row_types = require(script.Parent.Parent.player_row.player_row_types)

const function matches_query(player: player_row_types.player_summary, query: string): boolean
	return string.find(player.display_name:lower(), query, 1, true) ~= nil
		or string.find(player.username:lower(), query, 1, true) ~= nil
end

-- local stand in for the server, inviting moves a player to outgoing and cancelling moves them back
const function use_placeholder_invites(): guild_types.invites
	const query, set_query = React.useState("")
	const outgoing_ids, set_outgoing_ids = React.useState({} :: { [number]: boolean? })
	const outgoing = {}
	const search_results = {}
	const lowered_query = query:lower()
	for _, player in PLACEHOLDER_INVITE_CANDIDATES do
		if outgoing_ids[player.user_id] then
			table.insert(outgoing, player)
		elseif lowered_query ~= "" and matches_query(player, lowered_query) then
			table.insert(search_results, player)
		end
	end
	const function set_outgoing(player: player_row_types.player_summary, invited: boolean): ()
		const next_ids = table.clone(outgoing_ids)
		next_ids[player.user_id] = if invited then true else nil
		set_outgoing_ids(next_ids)
	end
	const function invite(player: player_row_types.player_summary): ()
		set_outgoing(player, true)
	end
	const function cancel(player: player_row_types.player_summary): ()
		set_outgoing(player, false)
	end
	return {
		outgoing = outgoing,
		search_results = search_results,
		query = query,
		on_search = set_query,
		on_invite = invite,
		on_cancel = cancel,
	}
end

return use_placeholder_invites
