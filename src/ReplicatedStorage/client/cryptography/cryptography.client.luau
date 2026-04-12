local ReplicatedStorage = game:GetService("ReplicatedStorage")
f
local cryptography = require(ReplicatedStorage.Packages.cryptography)

local Blake3 = cryptography.Hashing.Blake3
local CSPRNG = cryptography.Utilities.CSPRNG
local X25519 = cryptography.Verification.EdDSA.X25519
local AEAD = cryptography.Encryption.AEAD

local server_secret = CSPRNG.Ed25519Random()
local server_masked = X25519.Mask(server_secret)
local server_public = X25519.PublicKey(server_masked)

local client_secret = CSPRNG.Ed25519Random()
local client_masked = X25519.Mask(client_secret)
local client_public = X25519.PublicKey(client_masked)


local function encrypt_for_recipient(message, recipient_public)
    local shared_secret, _ = X25519.Exchange(client_masked, recipient_public)

    local _, derived_key = Blake3.DeriveKey(buffer.fromstring("key"))(shared_secret, 32)

    local nonce = CSPRNG.RandomBytes(24)

    local ciphertext, tag = AEAD.Encrypt(message, derived_key, nonce, nil, nil, true)

    return {
        public = client_public,
        nonce = nonce,
        ciphertext = ciphertext,
        tag = tag
    }
end

local function decrypt_from_sender(packet, my_masked)
    local shared_secret, _ = X25519.Exchange(my_masked, packet.public)

    local _, derived_key = Blake3.DeriveKey(buffer.fromstring("key"))(shared_secret, 32)

    return AEAD.Decrypt(packet.ciphertext, derived_key, packet.nonce, packet.tag, nil, nil, true)
end


local encrypted_message = encrypt_for_recipient(buffer.fromstring("hello!"), server_public)

print("Encrypted packet:", encrypted_message)

local decrypted_message = decrypt_from_sender(encrypted_message, server_masked)

print("Decrypted message:", buffer.tostring(decrypted_message))
