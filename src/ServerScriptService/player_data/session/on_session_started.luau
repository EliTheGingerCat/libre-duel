const session_started_callbacks = require(script.Parent.session_started_callbacks)

-- runs once the player's data finished loading on this server, get_cached_player_data works inside the callback
const function on_session_started(callback: session_started_callbacks.session_started_callback): ()
	table.insert(session_started_callbacks, callback)
end

return on_session_started
