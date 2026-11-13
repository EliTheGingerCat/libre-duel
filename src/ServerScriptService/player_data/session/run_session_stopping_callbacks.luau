const active_session_keys = require(script.Parent.active_session_keys)
const session_stopping_callbacks = require(script.Parent.session_stopping_callbacks)

-- returns false if the player had no active session, so callbacks never run twice for one session
const function run_session_stopping_callbacks(player: Player): boolean
	const key = tostring(player.UserId)
	if not active_session_keys[key] then
		return false
	end
	active_session_keys[key] = nil

	const function on_error(message: unknown)
		warn(`Session stopping callback failed for {key}: {message}`)
	end
	for _, callback in session_stopping_callbacks do
		-- one broken callback shouldn't stop the session from saving
		xpcall(callback, on_error, player)
	end
	return true
end

return run_session_stopping_callbacks
