local replicated_storage = game:GetService("ReplicatedStorage")

local combat_counters = require(script.Parent.combat_counters)
const CUBE_SIZE = require(replicated_storage.shared.cube.CUBE_SIZE)

local function mount_combat(reach_label: TextLabel?, combo_label: TextLabel?)
	local function update(combo: number, reach: number): ()
		if combo_label then
			combo_label.Text = `Combo: {combo}`
		end
		if reach_label then
			reach_label.Text = string.format("%.2f cubes", reach / CUBE_SIZE)
		end
	end
	return combat_counters.subscribe(update)
end

return mount_combat
