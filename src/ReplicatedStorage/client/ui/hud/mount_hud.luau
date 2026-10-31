local create_builtin = require(script.Parent.create_builtin)
local registry = require(script.Parent.registry)

const WIDGETS = { "Keystrokes", "Mousestrokes", "ReachCounter", "ComboCounter", "FpsCounter", "Paperdoll" }

local function mount_hud()
	local cleanups: { () -> () } = {}
	for _, name in WIDGETS do
		table.insert(cleanups, create_builtin(name))
	end

	local function disconnect(): ()
		registry.clear_duplicates()
		for _, cleanup in cleanups do
			cleanup()
		end
	end
	return disconnect
end

return mount_hud
