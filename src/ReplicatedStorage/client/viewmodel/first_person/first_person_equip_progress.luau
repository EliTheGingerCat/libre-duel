-- the old item drops out of view before the new one rises
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const FIRST_PERSON = require(script.Parent.Parent.FIRST_PERSON_VIEWMODEL)
const first_person_tick_clock = require(script.Parent.first_person_tick_clock)
const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

local held_tool: tool_types.tool? = nil
local tool_to_render: tool_types.tool? = nil
local equipped_progress = 0
local previous_equipped_progress = 0

const function is_same_stack(first: tool_types.tool?, second: tool_types.tool?): boolean
	if first == nil or second == nil then
		return first == second
	end
	return first.id == second.id
end

const function set_held_tool(tool: tool_types.tool?): ()
	held_tool = tool
end

const function update_equipped_item(): ()
	previous_equipped_progress = equipped_progress
	const target = if is_same_stack(tool_to_render, held_tool) then 1 else 0
	const step = math.clamp(target - equipped_progress, -FIRST_PERSON.equip_speed, FIRST_PERSON.equip_speed)
	equipped_progress += step
	if equipped_progress < 0.1 then
		tool_to_render = held_tool
	end
end

const function get_tool_to_render(): tool_types.tool?
	return tool_to_render
end

-- 0 when fully raised, 1 when fully lowered, which is what transformFirstPersonItem takes
const function get_equip_drop(partial_tick: number): number
	return 1 - (previous_equipped_progress + (equipped_progress - previous_equipped_progress) * partial_tick)
end

first_person_tick_clock.on_tick(update_equipped_item)

return {
	set_held_tool = set_held_tool,
	get_tool_to_render = get_tool_to_render,
	get_equip_drop = get_equip_drop,
}
