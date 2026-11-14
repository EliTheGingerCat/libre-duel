const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const conch = require(ReplicatedStorage.Packages.conch)
const get_executor_player = require(ServerScriptService.conch.get_executor_player)
const invsee_util = require(ServerScriptService.inventory.invsee.invsee_util)

const function get_arguments()
	return conch.args.player("player", "The player whose inventory to open")
end

const function invsee(target: Player): string
	const viewer = get_executor_player()
	if viewer == nil then
		return "Only a player can look into an inventory"
	end
	if viewer == target then
		return "That is your own inventory, it has a keybind"
	end
	invsee_util.start(viewer, target)
	return `Opened the inventory of {target.Name}, closing the window stops it`
end

conch.register("invsee", {
	description = "Opens the inventory of another player and lets you rearrange it",
	permissions = { "administrator" },
	arguments = get_arguments,
	callback = invsee,
})
