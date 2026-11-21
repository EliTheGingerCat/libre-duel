-- runs the per tick logic at 20 tps and exposes the partial tick for interpolation
const FIRST_PERSON = require(script.Parent.Parent.FIRST_PERSON_VIEWMODEL)

const TICK_LENGTH = 1 / FIRST_PERSON.ticks_per_second
-- a long hitch only replays this many ticks instead of all of them
const MAX_CATCH_UP_TICKS = 10

const tick_callbacks: { () -> () } = {}
local last_tick_time = os.clock()

const function on_tick(callback: () -> ()): ()
	table.insert(tick_callbacks, callback)
end

const function run_tick(): ()
	for _, callback in tick_callbacks do
		callback()
	end
end

-- returns the partial tick
const function advance(): number
	const now = os.clock()
	local ticks_due = math.floor((now - last_tick_time) / TICK_LENGTH)
	if ticks_due > MAX_CATCH_UP_TICKS then
		last_tick_time = now - MAX_CATCH_UP_TICKS * TICK_LENGTH
		ticks_due = MAX_CATCH_UP_TICKS
	end
	for _ = 1, ticks_due do
		last_tick_time += TICK_LENGTH
		run_tick()
	end
	return (now - last_tick_time) / TICK_LENGTH
end

return {
	on_tick = on_tick,
	advance = advance,
}
