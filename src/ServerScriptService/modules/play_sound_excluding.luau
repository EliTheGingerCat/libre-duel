local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote = ReplicatedStorage.remotes.play_sound

local function play_sound_excluding(excluding: Player, name: string, position: Vector3): ()
	for _, player in Players:GetPlayers() do
		if player == excluding then
			continue
		end

		remote:FireClient(player, name, position)
	end
end

return play_sound_excluding
