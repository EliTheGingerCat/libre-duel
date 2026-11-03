local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local MODE_OPTIONS = require(script.Parent.MODE_OPTIONS)

export type status = { mode: MODE_OPTIONS.mode?, elapsed: number, teleporting: boolean }

local function use_queue_status(): status
	local state, set_state = React.useState({ mode = nil, elapsed = 0, teleporting = false } :: status)
	local function subscribe()
		local player = Players.LocalPlayer
		local timer: thread? = nil
		local function update(): ()
			local mode = player:GetAttribute("QueueMode")
			local started_at = player:GetAttribute("QueueStartedAt")
			local valid = (mode == "solo" or mode == "duo") and typeof(started_at) == "number"
			set_state({
				mode = if valid then mode :: MODE_OPTIONS.mode else nil,
				elapsed = if typeof(started_at) == "number"
					then math.max(0, math.floor(workspace:GetServerTimeNow() - started_at))
					else 0,
				teleporting = player:GetAttribute("QueueTeleporting") == true,
			})
			if timer then
				task.cancel(timer)
				timer = nil
			end
			if valid then
				local function tick_status(): ()
					timer = nil
					update()
				end
				timer = task.delay(1, tick_status)
			end
		end
		local connections = {
			player:GetAttributeChangedSignal("QueueMode"):Connect(update),
			player:GetAttributeChangedSignal("QueueStartedAt"):Connect(update),
			player:GetAttributeChangedSignal("QueueTeleporting"):Connect(update),
		}
		update()
		local function disconnect(): ()
			for _, connection in connections do
				connection:Disconnect()
			end
			if timer then
				task.cancel(timer)
			end
		end
		return disconnect
	end
	React.useEffect(subscribe, {})
	return state
end

return use_queue_status
