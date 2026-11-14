const ReplicatedStorage = game:GetService("ReplicatedStorage")

const signal = require(ReplicatedStorage.Packages.signal)

local invsee_state = {
	-- whose inventory is open, its contents live in client_inventory
	target = nil :: Player?,
	-- id of the latest request sent, and of the latest one the server answered
	request_id = 0,
	settled_id = 0,
	-- fires when the target or its inventory changes, including predictions
	on_change = signal.new(),
}

return invsee_state
