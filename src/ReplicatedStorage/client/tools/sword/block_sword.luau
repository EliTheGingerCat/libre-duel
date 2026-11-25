const ReplicatedStorage = game:GetService("ReplicatedStorage")

const TOOL_USE_WALKSPEED_MODIFIER = require(ReplicatedStorage.client.tools.TOOL_USE_WALKSPEED_MODIFIER)
const sword_state = require(script.Parent.sword_state)
const walkspeed = require(ReplicatedStorage.client.util.walkspeed)
const zap_client_network = require(ReplicatedStorage.client.network.zap_client_network)

const function set_blocking(blocking: boolean): ()
	walkspeed.set_modifier("sword", if blocking then TOOL_USE_WALKSPEED_MODIFIER else nil)

	sword_state.blocking = blocking
	zap_client_network.update_blocking.fire(blocking)
end

const function start_blocking(): ()
	set_blocking(true)
end

const function stop_blocking(): ()
	set_blocking(false)
end

return {
	start = start_blocking,
	stop = stop_blocking,
}
