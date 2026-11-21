const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const send_notification_remote = ReplicatedStorage.remotes.send_notification

const function send_notification(player: Player | "all", message: string): ()
	if player == "all" then
		for _, player in Players:GetPlayers() do
			send_notification_remote:FireClient(player, message)
		end
		return
	end
	send_notification_remote:FireClient(player, message)
end

return send_notification
