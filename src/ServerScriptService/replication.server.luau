local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local replication = require(ReplicatedStorage.shared.replication)

local all_replication_events = replication.all_replication_events

local function on_heartbeat(): ()
	ReplicatedStorage.remotes.replication:FireAllClients(all_replication_events)
	table.clear(all_replication_events)
end
RunService.Heartbeat:Connect(on_heartbeat)
