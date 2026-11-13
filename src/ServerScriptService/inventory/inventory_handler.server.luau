const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const inventory_types = require(ReplicatedStorage.shared.inventory.inventory_types)
const inventory_util = require(script.Parent.inventory_util)

const update_inventory = ReplicatedStorage.remotes.update_inventory

const MIN_REQUEST_INTERVAL = 0.05

const ACTIONS: { [string]: (inventory_types.inventory, number, number) -> boolean } = {
	move_item = inventory_util.move_item,
	quick_move = inventory_util.quick_move,
	swap_items = inventory_util.swap_items,
}

local last_request_times: { [Player]: number } = {}

const function on_request(player: Player, arguments: unknown): ()
	if type(arguments) ~= "table" then
		return
	end
	const request = arguments :: { [any]: unknown }
	const action = ACTIONS[request.action :: any]
	const id = request.id
	if not action or type(id) ~= "number" then
		return
	end

	const inventory = inventory_util.get_inventory(player)
	if not inventory then
		return
	end

	-- rate limited requests still get a reply so the client rolls its prediction back
	const now = os.clock()
	if now - (last_request_times[player] or 0) >= MIN_REQUEST_INTERVAL then
		last_request_times[player] = now
		-- slot validation happens inside the action, on failure the unchanged inventory is resent
		action(inventory, request.from :: number, request.to :: number)
		inventory_util.changed:Fire(player)
	end
	update_inventory:FireClient(player, { inventory = inventory, id = id })
end

const function on_player_removing(player: Player): ()
	last_request_times[player] = nil
end

update_inventory.OnServerEvent:Connect(on_request)
Players.PlayerRemoving:Connect(on_player_removing)
