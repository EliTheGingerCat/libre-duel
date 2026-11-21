const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Signal = require(ReplicatedStorage.Packages.signal)
const guild_snapshot_types = require(ReplicatedStorage.shared.guild.guild_snapshot_types)

const changed = Signal.new()

-- the latest guild and invites the server sent, nil guild means the player isn't in one
const guild_state = {
	guild = nil :: guild_snapshot_types.guild_snapshot?,
	incoming_invites = {} :: { guild_snapshot_types.incoming_invite_snapshot },
}

const function set_guild(guild: guild_snapshot_types.guild_snapshot?): ()
	guild_state.guild = guild
	changed:Fire()
end

const function set_incoming_invites(invites: { guild_snapshot_types.incoming_invite_snapshot }): ()
	guild_state.incoming_invites = invites
	changed:Fire()
end

const function subscribe(callback: () -> ()): () -> ()
	const connection = changed:Connect(callback)
	const function disconnect(): ()
		connection:Disconnect()
	end
	return disconnect
end

return {
	state = guild_state,
	set_guild = set_guild,
	set_incoming_invites = set_incoming_invites,
	subscribe = subscribe,
}
