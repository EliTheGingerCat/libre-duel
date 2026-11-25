const ReplicatedStorage = game:GetService("ReplicatedStorage")
const current_ping = require(ReplicatedStorage.client.ping.current_ping)
const zap_client_network = require(ReplicatedStorage.client.network.zap_client_network)

const PINGING_DELAY = 5

-- This is the ping side
const function send_ping(): ()
	zap_client_network.ping.fire()
end

local t1 = os.clock()
const function on_pong(): ()
	const t2 = os.clock()
	const dt = (t2 - PINGING_DELAY) - t1
	const dt_ms = math.round(dt * 1000)
	current_ping.value = dt_ms
	t1 = os.clock()
	task.delay(PINGING_DELAY, send_ping)
end

zap_client_network.pong.set_callback(on_pong)

send_ping()
