const Players = game:GetService("Players")

-- player -> remote name -> os.clock() when they may call it again
const next_allowed_calls: { [Player]: { [string]: number } } = {}

-- true when the call should be rejected, otherwise starts the cooldown
const function is_rate_limited(player: Player, remote_name: string, cooldown: number): boolean
	const now = os.clock()
	const calls = next_allowed_calls[player] or {}
	next_allowed_calls[player] = calls
	if (calls[remote_name] or 0) > now then
		return true
	end
	calls[remote_name] = now + cooldown
	return false
end

const function on_player_removing(player: Player): ()
	next_allowed_calls[player] = nil
end

Players.PlayerRemoving:Connect(on_player_removing)

return is_rate_limited
