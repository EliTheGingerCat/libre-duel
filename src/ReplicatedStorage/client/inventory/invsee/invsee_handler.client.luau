const ReplicatedStorage = game:GetService("ReplicatedStorage")

const invsee_util = require(script.Parent.invsee_util)

ReplicatedStorage.remotes.invsee.OnClientEvent:Connect(invsee_util.apply_update)
