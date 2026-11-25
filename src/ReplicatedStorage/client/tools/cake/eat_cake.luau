const ReplicatedStorage = game:GetService("ReplicatedStorage")

const TOOL_USE_WALKSPEED_MODIFIER = require(ReplicatedStorage.client.tools.TOOL_USE_WALKSPEED_MODIFIER)
const cake_state = require(script.Parent.cake_state)
const walkspeed = require(ReplicatedStorage.client.util.walkspeed)
const zap_client_network = require(ReplicatedStorage.client.network.zap_client_network)

const function start_eating(): ()
	cake_state.eating = true
	cake_state.eat_started = os.clock()
	walkspeed.set_modifier("cake", TOOL_USE_WALKSPEED_MODIFIER)
	local finished = zap_client_network.set_cake_state.call(true)
	if finished then
		cake_state.eating = false
		cake_state.eat_started = nil
		walkspeed.set_modifier("cake", nil)
		-- do something...
	else
		cake_state.eating = false
		cake_state.eat_started = nil
		walkspeed.set_modifier("cake", nil)
		-- do something...
	end
end

const function stop_eating(): ()
	if cake_state.eating then
		cake_state.eating = false
		cake_state.eat_started = nil
		walkspeed.set_modifier("cake", nil)
		zap_client_network.set_cake_state.call(false)
	end
end

return {
	start = start_eating,
	stop = stop_eating,
}
