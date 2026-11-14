const ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const game_active_state = require(ReplicatedStorage.client.match.game_active_state)

const function use_game_is_active(): boolean
	const game_is_active, set_game_is_active = React.useState(game_active_state.active)

	const function subscribe()
		const function update(): ()
			set_game_is_active(game_active_state.active)
		end
		const connection = game_active_state.on_change:Connect(update)
		update()
		const function disconnect(): ()
			connection:Disconnect()
		end
		return disconnect
	end
	React.useEffect(subscribe, {})

	return game_is_active
end

return use_game_is_active
