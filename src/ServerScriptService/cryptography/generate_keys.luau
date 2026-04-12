local ReplicatedStorage = game:GetService("ReplicatedStorage")

local cryptography = require(ReplicatedStorage.Packages.cryptography)

local keys = require(script.Parent.keys)

local CSPRNG = cryptography.Utilities.CSPRNG
local X25519 = cryptography.Verification.EdDSA.X25519

local function generate_keys()
    keys["secret"] = CSPRNG.Ed25519Random()
    keys["masked"] = X25519.Mask(keys["secret"])
    keys["public"] = X25519.PublicKey(keys["masked"])
end

return generate_keys
