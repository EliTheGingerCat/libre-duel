local replicated_storage = game:GetService("ReplicatedStorage")

local mount_editor = require(script.Parent.Parent.hud.mount_editor)
local mount_hud = require(script.Parent.Parent.hud.mount_hud)
local react = require(replicated_storage.Packages.react)

local function gameplay_hud(): nil
	react.useEffect(mount_hud, {})
	react.useEffect(mount_editor, {})
	return nil
end

return gameplay_hud
