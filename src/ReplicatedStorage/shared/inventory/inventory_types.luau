const ReplicatedStorage = game:GetService("ReplicatedStorage")

const registry = require(ReplicatedStorage.shared.entity.registry)
const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

export type item_id = string
-- replace `data` instead of mutating it, resolved tools are cached per table
export type slot_data = { item_id: item_id, amount: number, data: tool_types.overrides? }
export type slot = slot_data | "empty" -- "empty" instead of nil because ipairs stops at a nil
export type inventory = { [number]: slot }
export type entity_inventories = { [registry.entity]: inventory }

export type inventory_action = "swap_items" | "move_item" | "quick_move"
export type inventory_request = { action: inventory_action, from: number, to: number, id: number }
-- id is nil for server pushes, inventory is nil when it got deleted (e.g. on death)
export type inventory_update = { inventory: inventory?, id: number? }

-- invsee is looking into the inventory of another player
-- `target` guards against a request that was made for a previous session
export type invsee_request =
	{ action: inventory_action, target: Player, from: number, to: number, id: number }
	| { action: "stop" }
-- like inventory_update, target is nil once the session has ended
export type invsee_update = { target: Player?, inventory: inventory?, id: number? }

return {}
