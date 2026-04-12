local ReplicatedStorage = game:GetService("ReplicatedStorage")
local keys = require(script.Parent.keys)

local cryptography = require(ReplicatedStorage.Packages.cryptography)
local Blake3 = cryptography.Hashing.Blake3
local X25519 = cryptography.Verification.EdDSA.X25519
local AEAD = cryptography.Encryption.AEAD

local remote = ReplicatedStorage.remotes.receive_encrypted_message

local function on_message_received(callback)

    remote.OnClientEvent:Connect(function(packet)
        if not keys["masked"] then return end

        local masked = keys["masked"]

        local shared_secret, _ = X25519.Exchange(masked, packet.public)
        local _, derived_key = Blake3.DeriveKey(buffer.fromstring("key"))(shared_secret, 32)

        local decrypted_buffer = AEAD.Decrypt(packet.ciphertext, derived_key, packet.nonce, packet.tag, nil, nil, true)
        local message = buffer.tostring(decrypted_buffer)

        callback(message)
    end)
end

return {
    on_message_received = on_message_received
}
