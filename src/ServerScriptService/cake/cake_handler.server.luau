const ReplicatedStorage = game:GetService("ReplicatedStorage")

const CAKE_EATING_DURATION = require(script.Parent.CAKE_EATING_DURATION)

const set_cake_state = ReplicatedStorage.remotes.set_cake_state

type eating_timestamps = { [Player]: { time: number, thread: thread? } }
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

local thread_returned: boolean

local function check_eating_finished(player: Player): boolean
	task.wait(CAKE_EATING_DURATION)
	if eating_timestamps[player]["time"] and os.time() - eating_timestamps[player]["time"] >= CAKE_EATING_DURATION then
		heal_player(player)
		thread_returned = true
		return true
	end
	thread_returned = false
	return false
end

set_cake_state.OnServerInvoke = function(player, new_state: boolean)
	local eating_state = eating_timestamps[player]
	if eating_state ~= nil then
		local thread = eating_state.thread
		if thread ~= nil then
			task.cancel(thread)
		end
		eating_timestamps[player] = nil
	end

	if new_state == true then
		print(`{player} started eating`)
		eating_timestamps[player] = {
			time = 0,
			thread = nil,
		}
		eating_timestamps[player]["time"] = os.time()
		local thread = task.spawn(check_eating_finished, player)
		eating_timestamps[player]["thread"] = thread
		while coroutine.status(thread) ~= "dead" do
			task.wait()
		end

		return thread_returned
	else
		print(`{player} stopped eating`)
		eating_timestamps[player] = nil
		return false
	end
end
