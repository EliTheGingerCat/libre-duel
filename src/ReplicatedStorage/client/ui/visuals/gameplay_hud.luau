local replicated_storage = game:GetService("ReplicatedStorage")

local mount_hud = require(script.Parent.Parent.hud.mount_hud)
local react = require(replicated_storage.Packages.react)

local function gameplay_hud(): nil
	react.useEffect(mount_hud, {})
	return nil
end

return gameplay_hud
