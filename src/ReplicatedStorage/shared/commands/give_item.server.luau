local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const inventory_util = require(ServerScriptService.inventory.inventory_util)
local conch = require(ReplicatedStorage.Packages.conch)

const function get_items()
	local map = {}
	for _, item in ReplicatedStorage.shared.tools.definitions:GetChildren() do
		map[item.name] = item.name
	end
	return map
end

local item_type = conch.args.dynamic("items", get_items, "item")

conch.register("give_item", {
	description = "Gives a player an item of your choice.",
	permissions = { "administrator" },
	arguments = function()
		return conch.args.player("player", "The player that should receive the item"),
			item_type("item", "The ID of the item"),
			conch.args.number("amount", "The quantity of the item to give.")
	end,
	callback = function(player, item, amount) -- typechecked!
        const inventory = inventory_util.get_inventory(player)
        if not inventory then
            return `{player} is missing an inventory! :/`
        end
		inventory_util.give_item(inventory, item, amount)
		inventory_util.replicate(player)
		return `Successfully gave {player} {amount or "a"} {item}{if amount == 1 then "" else "s"}`
	end,
})
