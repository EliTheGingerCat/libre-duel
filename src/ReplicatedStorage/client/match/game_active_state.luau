const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Signal = require(ReplicatedStorage.Packages.signal)

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

ReplicatedStorage.remotes.game_is_active.OnClientEvent:Connect(set_active)

return game_active_state
