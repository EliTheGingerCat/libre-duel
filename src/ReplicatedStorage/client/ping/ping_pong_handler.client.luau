const ReplicatedStorage = game:GetService("ReplicatedStorage")
const current_ping = require(ReplicatedStorage.client.ping.current_ping)
const ping_pong = ReplicatedStorage.remotes.ping_pong

const PINGING_DELAY = 5

-- This is the ping side
const function fire_server(): ()
	ping_pong:FireServer()
end

local t1 = os.clock()
const function on_client_event(): ()
	const t2 = os.clock()
	const dt = (t2 - PINGING_DELAY) - t1
	const dt_ms = math.round(dt * 1000)
	current_ping.value = dt_ms
	t1 = os.clock()
	task.delay(PINGING_DELAY, fire_server)
end

ping_pong.OnClientEvent:Connect(on_client_event)

ping_pong:FireServer()
