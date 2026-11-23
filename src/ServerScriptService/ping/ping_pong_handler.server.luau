-- This is the pong side

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ping_pong = ReplicatedStorage.remotes.ping_pong

const function on_server_event(player): ()
	ping_pong:FireClient(player)
end

ping_pong.OnServerEvent:Connect(on_server_event)
