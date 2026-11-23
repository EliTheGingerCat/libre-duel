const current_ping = require(script.Parent.current_ping)

const function get_ping(): current_ping.ping_type
	return current_ping.value
end

return get_ping
