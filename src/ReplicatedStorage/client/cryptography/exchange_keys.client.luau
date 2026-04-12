local ReplicatedStorage = game:GetService("ReplicatedStorage")

local keys = require(script.Parent.keys)
local generate_keys = require(script.Parent.generate_keys)

generate_keys()

local server_public = ReplicatedStorage.remotes.exchange_public_keys:InvokeServer(keys["public"])
keys["server_public"] = server_public

print("CLIENT: ", keys["server_public"])
