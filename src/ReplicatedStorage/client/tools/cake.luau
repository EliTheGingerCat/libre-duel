const ReplicatedStorage = game:GetService("ReplicatedStorage")

const tool_types = require(script.Parent.tool_types)

const set_cake_state = ReplicatedStorage.remotes.set_cake_state

local function send_state(eating: boolean): ()
	set_cake_state:InvokeServer(eating)
end

local function create(): tool_types.tool
	local eating = false

	local function begin_use(): ()
		if eating then
			return
		end
		eating = true
		task.spawn(send_state, true)
	end

	local function cancel_use(): ()
		if not eating then
			return
		end
		eating = false
		task.spawn(send_state, false)
	end

	return {
		begin_use = begin_use,
		cancel_use = cancel_use,
		end_use = cancel_use,
		buffer_click = true,
	}
end

return create
