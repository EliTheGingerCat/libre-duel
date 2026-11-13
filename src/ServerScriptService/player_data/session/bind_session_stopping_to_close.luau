const Players = game:GetService("Players")

const run_session_stopping_callbacks = require(script.Parent.run_session_stopping_callbacks)

const function run_callbacks_for_every_player(): ()
	for _, player in Players:GetPlayers() do
		run_session_stopping_callbacks(player)
	end
end

-- drop stops every session in its own BindToClose, so this has to be bound before drop.store is called
-- callbacks must not yield or drop's handler can start before they finish
const function bind_session_stopping_to_close(): ()
	game:BindToClose(run_callbacks_for_every_player)
end

return bind_session_stopping_to_close
