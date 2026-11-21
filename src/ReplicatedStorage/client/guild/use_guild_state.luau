const ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const guild_snapshot_types = require(ReplicatedStorage.shared.guild.guild_snapshot_types)
const guild_state = require(script.Parent.guild_state)

export type state = {
	guild: guild_snapshot_types.guild_snapshot?,
	incoming_invites: { guild_snapshot_types.incoming_invite_snapshot },
}

const function read_state(): state
	return { guild = guild_state.state.guild, incoming_invites = guild_state.state.incoming_invites }
end

-- rerenders whenever the server sends a new guild or invite list
const function use_guild_state(): state
	const state, set_state = React.useState(read_state)
	const function subscribe(): () -> ()
		const function update(): ()
			set_state(read_state())
		end
		update()
		return guild_state.subscribe(update)
	end
	React.useEffect(subscribe, {})
	return state
end

return use_guild_state
