local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote = ReplicatedStorage.remotes.play_sound

local function play_sound(name: string, position: Vector3): ()
	for _, player in Players:GetPlayers() do
		remote:FireClient(player, name, position)
	end
end

return play_sound
