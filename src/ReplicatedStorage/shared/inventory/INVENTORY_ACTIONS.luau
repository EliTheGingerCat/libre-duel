const inventory_logic = require(script.Parent.inventory_logic)
const inventory_types = require(script.Parent.inventory_types)

-- what each request action does to an inventory, shared by client prediction and the server
const INVENTORY_ACTIONS: { [inventory_types.inventory_action]: (inventory_types.inventory, number, number) -> boolean } = {
	move_item = inventory_logic.move_item,
	quick_move = inventory_logic.quick_move,
	swap_items = inventory_logic.swap_items,
}

return table.freeze(INVENTORY_ACTIONS)
