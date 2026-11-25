local ReplicatedStorage = game:GetService("ReplicatedStorage")

local play_sound_local = require(script.Parent.play_sound_local)
const zap_client_network = require(ReplicatedStorage.client.network.zap_client_network)

zap_client_network.play_sound.set_callback(play_sound_local)
