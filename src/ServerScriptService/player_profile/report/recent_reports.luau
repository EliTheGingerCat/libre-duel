const Players = game:GetService("Players")

-- reporter -> reported user id -> os.clock() of their last report, so one player can't flood reports on another
const recent_reports: { [Player]: { [number]: number } } = {}

const function on_player_removing(player: Player): ()
	recent_reports[player] = nil
end

Players.PlayerRemoving:Connect(on_player_removing)

return recent_reports
