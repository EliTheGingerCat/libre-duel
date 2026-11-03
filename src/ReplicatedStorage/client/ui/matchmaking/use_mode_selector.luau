local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

const MODE_OPTIONS = require(script.Parent.MODE_OPTIONS)
local React = require(ReplicatedStorage.Packages.react)
local editor_state = require(script.Parent.Parent.hud.editor_state)
local mode_selector_state = require(script.Parent.mode_selector_state)
local notification_management = require(script.Parent.Parent.notification_management)

local function close(): ()
	mode_selector_state.set_enabled(false)
end

local function use_mode_selector(): { enabled: boolean, busy: boolean, close: () -> (), join: (MODE_OPTIONS.mode) -> () }
	local enabled, set_enabled = React.useState(mode_selector_state.enabled)
	local busy, set_busy = React.useState(false)
	local pending = React.useRef(false)

	local function subscribe()
		local function update(): ()
			if editor_state.enabled then
				close()
			end
			set_enabled(mode_selector_state.enabled and not editor_state.enabled)
		end
		local function on_input(input: InputObject, processed: boolean): ()
			if not processed and input.KeyCode == Enum.KeyCode.Escape then
				close()
			end
		end
		local connection = mode_selector_state.on_change:Connect(update)
		local input_connection = UserInputService.InputBegan:Connect(on_input)
		local unsubscribe = editor_state.subscribe(update)
		update()
		local function disconnect(): ()
			connection:Disconnect()
			input_connection:Disconnect()
			unsubscribe()
			close()
		end
		return disconnect
	end
	React.useEffect(subscribe, {})

	local function join(mode: MODE_OPTIONS.mode): ()
		if pending.current then
			return
		end
		if RunService:IsStudio() then
			notification_management.add("Matchmaking is unavailable in Studio.")
			return
		end
		pending.current = true
		set_busy(true)
		local remote = ReplicatedStorage.remotes.join_queue
		local ok, joined = pcall(remote.InvokeServer, remote, mode)
		pending.current = false
		set_busy(false)
		if ok and joined == true then
			close()
		else
			notification_management.add("Could not join the queue. Please try again.")
		end
	end

	return { enabled = enabled, busy = busy, close = close, join = join }
end

return use_mode_selector
