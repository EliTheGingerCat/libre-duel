local ReplicatedStorage = game:GetService("ReplicatedStorage")

local debug_print = require(script.Parent.Parent.util.debug_print)

local keys = require(script.Parent.keys)
local client_keys = require(script.Parent.client_keys)

local generate_keys = require(script.Parent.generate_keys)

generate_keys()

ReplicatedStorage.remotes.exchange_public_keys.OnServerInvoke = function(player, client_public)
    client_keys[player] = client_public
    debug_print("SERVER: ", buffer.tostring(client_public))
    return keys["public"]
end
