-- the encoded state each player last received, so the 12 second session refreshes don't resend identical data
const last_sent_guild_states: { [Player]: string } = {}
const last_sent_incoming_invites: { [Player]: string } = {}

const function on_player_removing(player: Player): ()
	last_sent_guild_states[player] = nil
	last_sent_incoming_invites[player] = nil
end

return {
	guild_states = last_sent_guild_states,
	incoming_invites = last_sent_incoming_invites,
	on_player_removing = on_player_removing,
}
