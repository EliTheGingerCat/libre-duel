const Workspace = game:GetService("Workspace")
const debug_print = require(script.Parent.Parent.util.debug_print)

if Workspace.AuthorityMode == "Server" then
    debug_print("Libre Duel wasn't properly tested on Server Authority and it is guaranteed that you will find an issue. Chrono will also be disabled for this session.")
end

const ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.chrono).Start()
