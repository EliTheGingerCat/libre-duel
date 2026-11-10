const ReplicatedStorage = game:GetService("ReplicatedStorage")

const notification_management = require(script.Parent.notification_management)

ReplicatedStorage.remotes.send_notification.OnClientEvent:Connect(notification_management.add)
