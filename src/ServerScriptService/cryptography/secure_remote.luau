local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local client_keys = require(script.Parent.client_keys)
local cryptography = require(ReplicatedStorage.Packages.cryptography)
local get_shared_key = require(ReplicatedStorage.shared.cryptography.get_shared_key)
local keys = require(script.Parent.keys)
local serialiser = require(ReplicatedStorage.shared.cryptography.serialiser)

const CSPRNG = cryptography.Utilities.CSPRNG
const AEAD = cryptography.Encryption.AEAD

type packet = { public: buffer, nonce: buffer, ciphertext: buffer, tag: buffer }

local secure_remote = {}

local function encrypt_for_player(player: Player, data_table: unknown): packet?
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
		tag = tag,
	}
end

-- The packet comes from the client, so it is checked before use.
local function decrypt_from_player(packet: any): unknown
	if typeof(packet) ~= "table" or typeof(packet.public) ~= "buffer" then
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

function secure_remote.fire_client_encrypted(remote_event: RemoteEvent, player: Player, data_table: unknown): ()
	local packet = encrypt_for_player(player, data_table)
	if packet then
		remote_event:FireClient(player, packet)
	end
end

function secure_remote.fire_all_clients_encrypted(remote_event: RemoteEvent, data_table: unknown): ()
	for _, player in Players:GetPlayers() do
		local packet = encrypt_for_player(player, data_table)
		if packet then
			remote_event:FireClient(player, packet)
		end
	end
end

function secure_remote.on_server_event_encrypted(
	remote_event: RemoteEvent,
	callback: (Player, unknown) -> ()
): RBXScriptConnection
	local function on_server_event(player: Player, packet: unknown): ()
		local data_table = decrypt_from_player(packet)
		if data_table then
			callback(player, data_table)
		end
	end
	return remote_event.OnServerEvent:Connect(on_server_event)
end

function secure_remote.on_server_invoke_encrypted(remote_function: RemoteFunction, callback: (Player, unknown) -> unknown): ()
	local function on_server_invoke(player: Player, packet: unknown): unknown
		local data_table = decrypt_from_player(packet)
		if data_table then
			return callback(player, data_table)
		end
		return false
	end
	remote_function.OnServerInvoke = on_server_invoke
end

return secure_remote
