const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const CAKE_EATING_DURATION = require(script.Parent.CAKE_EATING_DURATION)
const inventory_util = require(ServerScriptService.inventory.inventory_util)

const set_cake_state = ReplicatedStorage.remotes.set_cake_state

type eating_timestamps = { [Player]: { time: number, thread: thread? } }
local eating_timestamps: eating_timestamps = {}

local function heal_player(player: Player): boolean
	const character = player.Character
	if character == nil then
		return false
	end

	const humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid == nil then
		return false
	end

	humanoid.Health = 100
	return true
end

local function check_eating_finished(player: Player): boolean
	task.wait(CAKE_EATING_DURATION)
	if
		eating_timestamps[player]["time"]
		and os.clock() - eating_timestamps[player]["time"] >= CAKE_EATING_DURATION
		and inventory_util.has_behaviour(player, "cake")
		and heal_player(player)
	then
		inventory_util.consume_selected_item(player)
		eating_timestamps[player] = nil
		return true
	end
	return false
end

local function stop_eating(player: Player): ()
	local eating_state = eating_timestamps[player]
	if eating_state == nil then
		return
	end
	local thread = eating_state.thread
	-- this is not necessary, i just don't want threads to stack up (it's probably a negligible performance hit, but small things add up!)
	if thread ~= nil then
		task.cancel(thread)
	end
	eating_timestamps[player] = nil
end

local function on_set_cake_state(player: Player, new_state: unknown): boolean
	stop_eating(player)

	if new_state == true then
		if not inventory_util.has_behaviour(player, "cake") then
			return false
		end
		print(`{player} started eating`)
		eating_timestamps[player] = {
			time = 0,
			thread = nil,
		}
		eating_timestamps[player]["time"] = os.clock()

		local thread_returned: boolean

		local function wait_for_eating(): ()
			thread_returned = check_eating_finished(player)
		end
		local thread = task.spawn(wait_for_eating)

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

Players.PlayerRemoving:Connect(stop_eating)
set_cake_state.OnServerInvoke = on_set_cake_state
