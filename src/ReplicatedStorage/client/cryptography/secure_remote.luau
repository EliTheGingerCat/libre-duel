local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local cryptography = require(ReplicatedStorage.Packages.cryptography)
local get_shared_key = require(ReplicatedStorage.shared.cryptography.get_shared_key)
local keys = require(script.Parent.keys)
local serialiser = require(ReplicatedStorage.shared.cryptography.serialiser)

const CSPRNG = cryptography.Utilities.CSPRNG
const AEAD = cryptography.Encryption.AEAD

type packet = { public: buffer, nonce: buffer, ciphertext: buffer, tag: buffer }

local secure_remote = {}

const function encrypt_payload(raw_data: unknown): packet
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
		tag = tag,
	}
end

const function decrypt_payload(packet: any): unknown
	if typeof(keys["masked"]) ~= "buffer" or typeof(packet) ~= "table" or typeof(packet.public) ~= "buffer" then
		return nil
	end

	local derived_key = get_shared_key(packet.public, keys["masked"])
	local success, decrypted_buffer =
		pcall(AEAD.Decrypt, packet.ciphertext, derived_key, packet.nonce, packet.tag, nil, nil, true)

	if success and decrypted_buffer then
		local json_string = buffer.tostring(decrypted_buffer)
		local raw_data = HttpService:JSONDecode(json_string)
		return serialiser.deserialise(raw_data)
	end

	return nil
end

function secure_remote.fire_server_encrypted(remote_event: RemoteEvent, data: unknown): ()
	remote_event:FireServer(encrypt_payload(data))
end

function secure_remote.invoke_server_encrypted(remote_function: RemoteFunction, data: unknown): unknown
	return remote_function:InvokeServer(encrypt_payload(data))
end

function secure_remote.on_client_event_encrypted(remote_event: RemoteEvent, callback: (unknown) -> ()): RBXScriptConnection
	const function on_client_event(packet: unknown): ()
		local decrypted_data = decrypt_payload(packet)
		if decrypted_data then
			callback(decrypted_data)
		end
	end
	return remote_event.OnClientEvent:Connect(on_client_event)
end

return secure_remote
