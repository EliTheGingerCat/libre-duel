local ReplicatedStorage = game:GetService("ReplicatedStorage")
local keys = require(script.Parent.keys)
local client_keys = require(script.Parent.client_keys)

local cryptography = require(ReplicatedStorage.Packages.cryptography)
local Blake3 = cryptography.Hashing.Blake3
local CSPRNG = cryptography.Utilities.CSPRNG
local X25519 = cryptography.Verification.EdDSA.X25519
local AEAD = cryptography.Encryption.AEAD

local remote = ReplicatedStorage.remotes.receive_encrypted_message

local function send_encrypted_message(player, message)
    local client_public = client_keys[player]

    if not client_public then
        warn(player.Name, " is missing a key (unfinished exchange?)")
        return
    end

    local message_buffer = typeof(message) == "string" and buffer.fromstring(message) or message

    local masked = keys["masked"]
    local public = keys["public"]

    local shared_secret, _ = X25519.Exchange(masked, client_public)
    local _, derived_key = Blake3.DeriveKey(buffer.fromstring("key"))(shared_secret, 32)

    local nonce = CSPRNG.RandomBytes(24)
    local ciphertext, tag = AEAD.Encrypt(message_buffer, derived_key, nonce, nil, nil, true)

    local packet = {
        public = public,
        nonce = nonce,
        ciphertext = ciphertext,
        tag = tag
    }

    remote:FireClient(player, packet)
end

return send_encrypted_message
