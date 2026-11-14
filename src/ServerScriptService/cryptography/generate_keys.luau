local ReplicatedStorage = game:GetService("ReplicatedStorage")

local cryptography = require(ReplicatedStorage.Packages.cryptography)

local keys = require(script.Parent.keys)

const CSPRNG = cryptography.Utilities.CSPRNG
const X25519 = cryptography.Verification.EdDSA.X25519

const function generate_keys()
	const secret = CSPRNG.Ed25519Random()
	const masked = X25519.Mask(secret)
	keys.secret = secret
	keys.masked = masked
	keys.public = X25519.PublicKey(masked)
end

return generate_keys
