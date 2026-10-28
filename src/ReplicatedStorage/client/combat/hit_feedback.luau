local replicated_storage = game:GetService("ReplicatedStorage")

local signal = require(replicated_storage.Packages.signal)

local hit_signal = signal.new()

local function report_hit(distance: number): ()
	hit_signal:Fire(distance)
end

local function subscribe(callback: (number) -> ())
	local connection = hit_signal:Connect(callback)
	local function disconnect(): ()
		connection:Disconnect()
	end
	return disconnect
end

return {
	report = report_hit,
	subscribe = subscribe,
}
