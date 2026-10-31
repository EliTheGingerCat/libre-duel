local replicated_storage = game:GetService("ReplicatedStorage")

local react = require(replicated_storage.Packages.react)
local editor_state = require(script.Parent.editor_state)

local function use_editor_enabled(): boolean
	local enabled, set_enabled = react.useState(editor_state.enabled)
	local function subscribe()
		local function update(): ()
			set_enabled(editor_state.enabled)
		end
		local disconnect = editor_state.subscribe(update)
		update()
		return disconnect
	end
	react.useEffect(subscribe, {})
	return enabled
end

return use_editor_enabled
