local ReplicatedStorage = game:GetService("ReplicatedStorage")

local debug_print = require(script.Parent.Parent.util.debug_print)

local keys = require(script.Parent.keys)
local generate_keys = require(script.Parent.generate_keys)

generate_keys()

local server_public = ReplicatedStorage.remotes.exchange_public_keys:InvokeServer(keys["public"])
keys["server_public"] = server_public

debug_print("CLIENT: ", keys["server_public"])
