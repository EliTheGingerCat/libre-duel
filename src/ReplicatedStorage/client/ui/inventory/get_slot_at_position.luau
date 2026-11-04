local Players = game:GetService("Players")

export type slot_target = {
	kind: "inventory" | "crafting",
	-- the inventory slot, 0 for crafting
	index: number,
}

local player_gui = Players.LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui

-- Inventory slots are named `slot_{index}`. Everything in the crafting area has a name starting with `crafting`.
local function parse_slot_name(name: string): slot_target?
	const inventory_index = string.match(name, "^slot_(%d+)$")
	if inventory_index ~= nil then
		return { kind = "inventory", index = tonumber(inventory_index) :: number }
	end
	if string.sub(name, 1, 8) == "crafting" then
		return { kind = "crafting", index = 0 }
	end
	return nil
end

-- `position` is in the same space as `InputObject.Position`, so the top bar inset is already removed.
local function get_slot_at_position(window: GuiObject, position: Vector2): slot_target?
	for _, object in player_gui:GetGuiObjectsAtPosition(position.X, position.Y) do
		if object:IsDescendantOf(window) then
			const target = parse_slot_name(object.Name)
			if target ~= nil then
				return target
			end
			const parent = object.Parent
			const parent_target = if parent ~= nil then parse_slot_name(parent.Name) else nil
			if parent_target ~= nil then
				return parent_target
			end
		end
	end
	return nil
end

return get_slot_at_position
