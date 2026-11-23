export type ping_type = number?

local current_ping: { [string]: ping_type } = {
	value = nil,
}

return current_ping
