local Players = game:GetService("Players")

export type player_cooldowns = {
	[string]: number
}

type all_cooldowns = {
	[Player]: player_cooldowns
}

local cooldowns: all_cooldowns = {}

local function on_player_removing(player: Player): ()
	cooldowns[player] = nil
end

Players.PlayerRemoving:Connect(on_player_removing)

return cooldowns
