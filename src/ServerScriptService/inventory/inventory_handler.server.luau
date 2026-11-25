const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const INVENTORY_ACTIONS = require(ReplicatedStorage.shared.inventory.INVENTORY_ACTIONS)
const encode_network_inventory = require(script.Parent.encode_network_inventory)
const inventory_types = require(ReplicatedStorage.shared.inventory.inventory_types)
const inventory_util = require(script.Parent.inventory_util)
const zap_server_network = require(ServerScriptService.network.zap_server_network)

const MIN_REQUEST_INTERVAL = 0.05

local last_request_times: { [Player]: number } = {}

const function on_request(player: Player, request: inventory_types.inventory_request): ()
	const inventory = inventory_util.get_inventory(player)
	if not inventory then
		return
	end

	-- rate limited requests still get a reply so the client rolls its prediction back
	const now = os.clock()
	if now - (last_request_times[player] or 0) >= MIN_REQUEST_INTERVAL then
		last_request_times[player] = now
		-- slot validation happens inside the action, on failure the unchanged inventory is resent
		-- replies directly instead of mark_dirty because the client needs the id to settle its prediction
		INVENTORY_ACTIONS[request.action](inventory, request.from, request.to)
		inventory_util.changed:Fire(player)
	end
	zap_server_network.update_inventory.fire(
		player,
		{ inventory = encode_network_inventory(inventory), id = request.id }
	)
end

const function on_player_removing(player: Player): ()
	last_request_times[player] = nil
end

zap_server_network.request_inventory_action.set_callback(on_request)
Players.PlayerRemoving:Connect(on_player_removing)
