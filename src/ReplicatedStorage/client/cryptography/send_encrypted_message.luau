local ReplicatedStorage = game:GetService("ReplicatedStorage")
local keys = require(script.Parent.keys)

local cryptography = require(ReplicatedStorage.Packages.cryptography)
local Blake3 = cryptography.Hashing.Blake3
local CSPRNG = cryptography.Utilities.CSPRNG
local X25519 = cryptography.Verification.EdDSA.X25519
local AEAD = cryptography.Encryption.AEAD

local function send_encrypted_message(message)
    -- wait for the key exchange to finish
    while keys["server_public"] == nil do
        task.wait()
    end

    local message_buffer = typeof(message) == "string" and buffer.fromstring(message) or message

    local masked = keys["masked"]
    local public = keys["public"]
    local server_public = keys["server_public"]

    local shared_secret, _ = X25519.Exchange(masked, server_public)
    local _, derived_key = Blake3.DeriveKey(buffer.fromstring("key"))(shared_secret, 32)
    local nonce = CSPRNG.RandomBytes(24)
    local ciphertext, tag = AEAD.Encrypt(message_buffer, derived_key, nonce, nil, nil, true)

    local packet = {
        public = public,
        nonce = nonce,
        ciphertext = ciphertext,
        tag = tag
    }

    ReplicatedStorage.remotes.send_encrypted_message:FireServer(packet)
end

return send_encrypted_message
