const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Signal = require(ReplicatedStorage.Packages.signal)

export type destination = { kind: "player_profile", user_id: number } | { kind: "guild", guild_id: string }

const navigated = Signal.new()

-- lets one menu open another without knowing about it, every menu root listens and opens or closes itself
const function open_player_profile(user_id: number): ()
	navigated:Fire({ kind = "player_profile", user_id = user_id } :: destination)
end

const function open_guild(guild_id: string): ()
	navigated:Fire({ kind = "guild", guild_id = guild_id } :: destination)
end

const function subscribe(callback: (destination: destination) -> ()): () -> ()
	const connection = navigated:Connect(callback)
	const function disconnect(): ()
		connection:Disconnect()
	end
	return disconnect
end

return {
	open_player_profile = open_player_profile,
	open_guild = open_guild,
	subscribe = subscribe,
}
