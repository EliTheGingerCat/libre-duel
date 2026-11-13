local ReplicatedStorage = game:GetService("ReplicatedStorage")

local client_keys = require(script.Parent.client_keys)
local debug_print = require(script.Parent.Parent.util.debug_print)
local generate_keys = require(script.Parent.generate_keys)
local keys = require(script.Parent.keys)

const function on_exchange_public_keys(player: Player, client_public: unknown): buffer?
	-- The key comes from the client, so only accept an actual buffer.
	if typeof(client_public) ~= "buffer" then
		return nil
	end
	client_keys[player] = client_public
	debug_print("SERVER: ", buffer.tostring(client_public))
	return keys["public"]
end

generate_keys()

ReplicatedStorage.remotes.exchange_public_keys.OnServerInvoke = on_exchange_public_keys
