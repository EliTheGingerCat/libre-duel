const ReplicatedStorage = game:GetService("ReplicatedStorage")

const notification_management = require(script.Parent.notification_management)
const zap_client_network = require(ReplicatedStorage.client.network.zap_client_network)

zap_client_network.send_notification.set_callback(notification_management.add)
