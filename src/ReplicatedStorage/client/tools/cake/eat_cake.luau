const ReplicatedStorage = game:GetService("ReplicatedStorage")

const cake_state = require(script.Parent.cake_state)

const set_cake_state = ReplicatedStorage.remotes.set_cake_state

local function start_eating(): ()
	cake_state.eating = true
	local finished = set_cake_state:InvokeServer(true)
	if finished then
		cake_state.eating = false
		-- do something...
	else
		-- do something...
	end
end

local function stop_eating(): ()
	if cake_state.eating then
		cake_state.eating = false
		set_cake_state:InvokeServer(false)
	end
end

return {
	start = start_eating,
	stop = stop_eating,
}
