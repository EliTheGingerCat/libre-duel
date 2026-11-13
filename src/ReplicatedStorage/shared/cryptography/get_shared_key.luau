local ReplicatedStorage = game:GetService("ReplicatedStorage")

local cryptography = require(ReplicatedStorage.Packages.cryptography)

local Blake3 = cryptography.Hashing.Blake3
const X25519 = cryptography.Verification.EdDSA.X25519

const function get_shared_key(their_public: buffer, masked: buffer): buffer
	local shared_secret, _ = X25519.Exchange(masked, their_public)
	local _, derived_key = Blake3.DeriveKey(buffer.fromstring("key"))(shared_secret, 32)
	return derived_key
end

return get_shared_key
