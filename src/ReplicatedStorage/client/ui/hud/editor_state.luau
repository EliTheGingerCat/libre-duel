local listeners: { () -> () } = {}

local editor_state = {
	enabled = false,
}

local function set_enabled(enabled: boolean): ()
	if editor_state.enabled == enabled then
		return
	end
	editor_state.enabled = enabled
	for _, callback in table.clone(listeners) do
		callback()
	end
end

local function subscribe(callback: () -> ())
	table.insert(listeners, callback)
	local function disconnect(): ()
		local index = table.find(listeners, callback)
		if index then
			table.remove(listeners, index)
		end
	end
	return disconnect
end

editor_state.set_enabled = set_enabled
editor_state.subscribe = subscribe

return editor_state
