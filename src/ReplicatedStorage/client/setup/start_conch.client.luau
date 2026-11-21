const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const conch_ui = require(ReplicatedStorage.Packages["conch-ui"])

require(ReplicatedStorage.Packages.conch).initiate_default_lifecycle()
conch_ui.bind_to(Enum.KeyCode.Backquote)

-- conch mounts once, so losing this gui on respawn would leave the shortcut toggling an invisible source
const gui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Command Executor") :: ScreenGui
gui.ResetOnSpawn = false
