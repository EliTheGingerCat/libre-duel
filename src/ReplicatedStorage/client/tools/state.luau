const ReplicatedStorage = game:GetService("ReplicatedStorage")

const LOADOUT = require(script.Parent.LOADOUT)
const signal = require(ReplicatedStorage.Packages.signal)

const on_change = signal.new()

const state = {
	current = table.find(LOADOUT, "cube") or 1,
	on_change = on_change,
}

local function set_slot(slot: number): ()
	if state.current == slot then
		return
	end
	state.current = slot
	on_change:Fire(slot)
end

state.set_slot = set_slot

return state
