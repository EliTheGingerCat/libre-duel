local ReplicatedStorage = game:GetService("ReplicatedStorage")

local play_sound_local = require(script.Parent.modules.play_sound_local)

local function on_event(name: string, position: Vector3): ()
	play_sound_local(name, position)
end

ReplicatedStorage.remotes.play_sound.OnClientEvent:Connect(on_event)