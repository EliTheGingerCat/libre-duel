export type roster = { [string]: { number } }

const ready = Instance.new("BindableEvent")
const finished = Instance.new("BindableEvent")
local current_roster: roster? = nil

local function start(roster: roster): ()
	if current_roster ~= nil then
		return
	end
	current_roster = roster
	ready:Fire()
end

local function get_roster(): roster?
	return current_roster
end

local function finish(): ()
	current_roster = nil
	finished:Fire()
end

return {
	finish = finish,
	finished = finished.Event,
	get_roster = get_roster,
	ready = ready.Event,
	start = start,
}
