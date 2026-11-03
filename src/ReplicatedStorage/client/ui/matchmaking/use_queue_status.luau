local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

const MODE_OPTIONS = require(script.Parent.MODE_OPTIONS)
local React = require(ReplicatedStorage.Packages.react)
local parse_queue_mode = require(ReplicatedStorage.shared.queue.parse_queue_mode)

export type status = { mode: MODE_OPTIONS.mode?, elapsed: number, teleporting: boolean }

local function use_queue_status(): status
	local state, set_state = React.useState({ mode = nil, elapsed = 0, teleporting = false } :: status)
	local function subscribe()
		local player = Players.LocalPlayer
		local timer: thread? = nil
		local function update(): ()
			local mode = parse_queue_mode(player:GetAttribute("queue_mode"))
			local started_at = player:GetAttribute("queue_started_at")
			local valid = mode ~= nil and typeof(started_at) == "number"
			set_state({
				mode = if valid then mode else nil,
				elapsed = if typeof(started_at) == "number"
					then math.max(0, math.floor(workspace:GetServerTimeNow() - started_at))
					else 0,
				teleporting = player:GetAttribute("queue_teleporting") == true,
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
			player:GetAttributeChangedSignal("queue_mode"):Connect(update),
			player:GetAttributeChangedSignal("queue_started_at"):Connect(update),
			player:GetAttributeChangedSignal("queue_teleporting"):Connect(update),
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
