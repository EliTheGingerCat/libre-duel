local ReplicatedStorage = game:GetService("ReplicatedStorage")

local signal = require(ReplicatedStorage.Packages.signal)

local hit_signal = signal.new()

const function report_hit(distance: number): ()
	hit_signal:Fire(distance)
end

const function subscribe(callback: (number) -> ())
	local connection = hit_signal:Connect(callback)
	const function disconnect(): ()
		connection:Disconnect()
	end
	return disconnect
end

return {
	report = report_hit,
	subscribe = subscribe,
}
