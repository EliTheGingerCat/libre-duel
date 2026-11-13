const session_stopping_callbacks = require(script.Parent.session_stopping_callbacks)

-- runs right before a player's session stops, so drop.update still works inside the callback
const function on_session_stopping(callback: session_stopping_callbacks.session_stopping_callback): ()
	table.insert(session_stopping_callbacks, callback)
end

return on_session_stopping
