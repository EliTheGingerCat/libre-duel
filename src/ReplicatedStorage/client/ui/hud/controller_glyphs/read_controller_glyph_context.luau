const ReplicatedStorage = game:GetService("ReplicatedStorage")

const INVENTORY_CONSTANTS = require(ReplicatedStorage.shared.inventory.INVENTORY_CONSTANTS)
const TOOL_USE_LABELS = require(script.Parent.TOOL_USE_LABELS)
const client_inventory_util = require(ReplicatedStorage.client.inventory.client_inventory_util)
const controller_glyph_types = require(script.Parent.controller_glyph_types)
const editor_state = require(script.Parent.Parent.editor_state)
const get_aim_target = require(ReplicatedStorage.client.aim.get_aim_target)
const get_melee_target = require(ReplicatedStorage.client.combat.get_melee_target)
const get_mining_fail_reason = require(ReplicatedStorage.client.tools.pickaxe.get_mining_fail_reason)
const get_slot_tool = require(ReplicatedStorage.client.tools.get_slot_tool)
const inventory_state = require(script.Parent.Parent.Parent.inventory.inventory_state)
const mode_selector_state = require(script.Parent.Parent.Parent.matchmaking.mode_selector_state)
const play_button_state = require(script.Parent.Parent.Parent.matchmaking.play_button_state)
const tool_registry = require(ReplicatedStorage.shared.tools.registry)
const tool_state = require(ReplicatedStorage.client.tools.tool_state)
const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

type controller_glyph_context = controller_glyph_types.controller_glyph_context

const function get_menu(): "closable" | "other" | nil
	if editor_state.enabled then
		return "other"
	elseif inventory_state.enabled or mode_selector_state.enabled then
		return "closable"
	end
	return nil
end

const function get_use_label(tool: tool_types.tool): string?
	for _, tool_use_label in TOOL_USE_LABELS do
		if tool_registry.has_behaviour(tool, tool_use_label.behaviour) then
			return tool_use_label.label
		end
	end
	return nil
end

-- the raycasts only run for tools that can act on what they hit, since this is read every frame
const function get_attack_label(tool: tool_types.tool): string?
	if tool_registry.has_behaviour(tool, "pickaxe") and get_mining_fail_reason(get_aim_target().instance) == nil then
		return "Mine"
	end
	if get_melee_target() ~= nil then
		return "Attack"
	end
	return nil
end

-- cycling only goes through the hotbar row, so the rest of the inventory doesn't count
const function has_multiple_hotbar_items(): boolean
	const inventory = client_inventory_util.get_inventory()
	if inventory == nil then
		return false
	end
	local item_count = 0
	for slot = 1, INVENTORY_CONSTANTS.COLUMNS do
		if type(inventory[slot]) == "table" then
			item_count += 1
			if item_count > 1 then
				return true
			end
		end
	end
	return false
end

const function read_controller_glyph_context(): controller_glyph_context
	const tool = get_slot_tool(tool_state.current)
	return {
		menu = get_menu(),
		play_available = play_button_state.available,
		attack_label = if tool ~= nil then get_attack_label(tool) else nil,
		use_label = if tool ~= nil then get_use_label(tool) else nil,
		sneak_relevant = tool ~= nil and tool_registry.has_behaviour(tool, "cube"),
		hotbar_relevant = has_multiple_hotbar_items(),
	}
end

return read_controller_glyph_context
