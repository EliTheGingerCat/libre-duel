const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Signal = require(ReplicatedStorage.Packages.signal)
const zap_client_network = require(ReplicatedStorage.client.network.zap_client_network)

-- listens from require time so ui mounted after the remote fires still knows whether a match is running
const game_active_state = {
	active = false,
	on_change = Signal.new(),
}

const function set_active(active: boolean): ()
	if game_active_state.active == active then
		return
	end
	game_active_state.active = active
	game_active_state.on_change:Fire()
end

zap_client_network.game_is_active.set_callback(set_active)

return game_active_state
