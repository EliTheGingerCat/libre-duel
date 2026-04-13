local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local keys = require(script.Parent.keys)
local client_keys = require(script.Parent.client_keys)
local cryptography = require(ReplicatedStorage.Packages.cryptography)
local get_shared_key = require(ReplicatedStorage.shared.cryptography.get_shared_key)
local serialiser = require(ReplicatedStorage.shared.cryptography.serialiser)

local Blake3 = cryptography.Hashing.Blake3
local CSPRNG = cryptography.Utilities.CSPRNG
local X25519 = cryptography.Verification.EdDSA.X25519
local AEAD = cryptography.Encryption.AEAD

local secure_remote = {}

local function encrypt_for_player(player, data_table)
	local target_public = client_keys[player]
	if not target_public then
		return nil
	end

	local json_string = HttpService:JSONEncode(serialiser.serialise(data_table))
	local message_buffer = buffer.fromstring(json_string)

	local derived_key = get_shared_key(target_public, keys["masked"])
	local nonce = CSPRNG.RandomBytes(24)
	local ciphertext, tag = AEAD.Encrypt(message_buffer, derived_key, nonce, nil, nil, true)

	return {
		public = keys["public"],
		nonce = nonce,
		ciphertext = ciphertext,
		tag = tag
	}
end

local function decrypt_from_player(packet)
	if typeof(packet) ~= "table" or typeof(packet.public) ~= "buffer" then
		return nil
	end

	local derived_key = get_shared_key(packet.public, keys["masked"])
	local success, decrypted_buffer = pcall(function()
		return AEAD.Decrypt(packet.ciphertext, derived_key, packet.nonce, packet.tag, nil, nil, true)
	end)

	if success and decrypted_buffer then
		local json_string = buffer.tostring(decrypted_buffer)
		local raw_data = HttpService:JSONDecode(json_string)
		return serialiser.deserialise(raw_data)
	end

	return nil
end

function secure_remote.fire_client_encrypted(remote_event, player, data_table)
	local packet = encrypt_for_player(player, data_table)
	if packet then
		remote_event:FireClient(player, packet)
	end
end

function secure_remote.fire_all_clients_encrypted(remote_event, data_table)
	for _, player in ipairs(game.Players:GetPlayers()) do
		local packet = encrypt_for_player(player, data_table)
		if packet then
			remote_event:FireClient(player, packet)
		end
	end
end

function secure_remote.on_server_event_encrypted(remote_event, callback)
	remote_event.OnServerEvent:Connect(function(player, packet)
		local data_table = decrypt_from_player(packet)
		if data_table then
			callback(player, data_table)
		end
	end)
end

function secure_remote.on_server_invoke_encrypted(remote_function, callback)
	remote_function.OnServerInvoke = function(player, packet)
		local data_table = decrypt_from_player(packet)
		if data_table then
			return callback(player, data_table)
		else
			return false
		end
	end
end

return secure_remote
