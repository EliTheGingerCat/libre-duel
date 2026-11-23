const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)

-- everyone in this server, rerenders when someone joins or leaves
const function use_server_players(): { Player }
	const server_players, set_server_players = React.useState(Players:GetPlayers())

	const function subscribe(): () -> ()
		const function update_server_players(): ()
			set_server_players(Players:GetPlayers())
		end
		-- PlayerRemoving fires before the player leaves the list
		const function update_after_removal(): ()
			task.defer(update_server_players)
		end
		const added_connection = Players.PlayerAdded:Connect(update_server_players)
		const removing_connection = Players.PlayerRemoving:Connect(update_after_removal)
		const function disconnect(): ()
			added_connection:Disconnect()
			removing_connection:Disconnect()
		end
		return disconnect
	end
	React.useEffect(subscribe, {})

	return server_players
end

return use_server_players
