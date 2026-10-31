const ReplicatedStorage = game:GetService("ReplicatedStorage")

const CAKE_EATING_DURATION = require(script.Parent.CAKE_EATING_DURATION)

const set_cake_state = ReplicatedStorage.remotes.set_cake_state

type eating_timestamps = { [Player]: number }
local eating_timestamps: eating_timestamps = {}

local function heal_player(player: Player): ()
	const character = player.Character
	if character == nil then
		return
	end

	const humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid == nil then
		return
	end

	humanoid.Health = 100
end

local function check_eating_finished(player: Player): boolean
    task.wait(CAKE_EATING_DURATION)
	if eating_timestamps[player] and os.time() - eating_timestamps[player] >= CAKE_EATING_DURATION then
		heal_player(player)
		return true
	end
	return false
end

set_cake_state.OnServerInvoke = function(player, new_state: boolean)
	if new_state == true then
		print(`{player} started eating`)
		eating_timestamps[player] = os.time()
		return check_eating_finished(player)
	else
		print(`{player} stopped eating`)
		eating_timestamps[player] = nil
		return false
	end
end
