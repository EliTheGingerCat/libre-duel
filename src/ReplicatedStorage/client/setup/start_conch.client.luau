local ReplicatedStorage = game:GetService("ReplicatedStorage")

require(ReplicatedStorage.Packages.conch).initiate_default_lifecycle()
require(ReplicatedStorage.Packages["conch-ui"]).bind_to(Enum.KeyCode.Backquote)
