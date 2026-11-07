const ReplicatedStorage = game:GetService("ReplicatedStorage")

const sword_state = require(script.Parent.sword_state)

-- suffixing _remote to not confuse roblo
const update_blocking_remote = ReplicatedStorage.remotes.update_blocking

local function set_blocking(blocking: boolean): ()
	sword_state.blocking = blocking
	update_blocking_remote:InvokeServer(blocking)
end

local function start_blocking(): ()
	set_blocking(true)
end

local function stop_blocking(): ()
	set_blocking(false)
end

return {
	start = start_blocking,
	stop = stop_blocking,
}
