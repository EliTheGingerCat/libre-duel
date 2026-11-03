local ReplicatedStorage = game:GetService("ReplicatedStorage")

local conch = require(ReplicatedStorage.Packages.conch)

conch.initiate_default_lifecycle()
conch.set_role_permissions("administrator", "administrator")
