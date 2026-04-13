local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local cryptography = require(ReplicatedStorage.Packages.cryptography)
local keys = require(script.Parent.keys)
local get_shared_key = require(ReplicatedStorage.shared.cryptography.get_shared_key)
local serialiser = require(ReplicatedStorage.shared.cryptography.serialiser)

local Blake3 = cryptography.Hashing.Blake3
local CSPRNG = cryptography.Utilities.CSPRNG
local X25519 = cryptography.Verification.EdDSA.X25519
local AEAD = cryptography.Encryption.AEAD

local secure_remote = {}

local function encrypt_payload(raw_data)
	while typeof(keys["server_public"]) ~= "buffer" do
		task.wait()
	end

	local json_string = HttpService:JSONEncode(serialiser.serialise(raw_data))
	local message_buffer = buffer.fromstring(json_string)

	local derived_key = get_shared_key(keys["server_public"], keys["masked"])
	local nonce = CSPRNG.RandomBytes(24)
	local ciphertext, tag = AEAD.Encrypt(message_buffer, derived_key, nonce, nil, nil, true)

	return {
		public = keys["public"],
		nonce = nonce,
		ciphertext = ciphertext,
		tag = tag
	}
end

local function decrypt_payload(packet)
	if typeof(keys["masked"]) ~= "buffer" or typeof(packet.public) ~= "buffer" then
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

function secure_remote.fire_server_encrypted(remote_event, data)
	remote_event:FireServer(encrypt_payload(data))
end

function secure_remote.invoke_server_encrypted(remote_function, data)
	return remote_function:InvokeServer(encrypt_payload(data))
end

function secure_remote.on_client_event_encrypted(remote_event, callback)
	remote_event.OnClientEvent:Connect(function(packet)
		local decrypted_data = decrypt_payload(packet)
		if decrypted_data then
			callback(decrypted_data)
		end
	end)
end

return secure_remote
