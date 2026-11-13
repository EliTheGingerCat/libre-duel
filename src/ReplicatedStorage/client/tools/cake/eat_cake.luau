const ReplicatedStorage = game:GetService("ReplicatedStorage")

const TOOL_USE_WALKSPEED_MODIFIER = require(ReplicatedStorage.client.tools.TOOL_USE_WALKSPEED_MODIFIER)
const cake_state = require(script.Parent.cake_state)
const walkspeed = require(ReplicatedStorage.client.util.walkspeed)

const set_cake_state = ReplicatedStorage.remotes.set_cake_state

const function start_eating(): ()
	cake_state.eating = true
	walkspeed.set_modifier("cake", TOOL_USE_WALKSPEED_MODIFIER)
	local finished = set_cake_state:InvokeServer(true)
	if finished then
		cake_state.eating = false
		walkspeed.set_modifier("cake", nil)
		-- do something...
	else
		cake_state.eating = false
		walkspeed.set_modifier("cake", nil)
		-- do something...
	end
end

const function stop_eating(): ()
	if cake_state.eating then
		cake_state.eating = false
		walkspeed.set_modifier("cake", nil)
		set_cake_state:InvokeServer(false)
	end
end

return {
	start = start_eating,
	stop = stop_eating,
}
