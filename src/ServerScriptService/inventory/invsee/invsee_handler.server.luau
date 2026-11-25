const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const INVENTORY_ACTIONS = require(ReplicatedStorage.shared.inventory.INVENTORY_ACTIONS)
const inventory_types = require(ReplicatedStorage.shared.inventory.inventory_types)
const inventory_util = require(ServerScriptService.inventory.inventory_util)
const invsee_util = require(script.Parent.invsee_util)
const registry = require(ReplicatedStorage.shared.entity.registry)
const zap_server_network = require(ServerScriptService.network.zap_server_network)

const MIN_REQUEST_INTERVAL = 0.05

local last_request_times: { [Player]: number } = {}

const function on_request(viewer: Player, request: inventory_types.invsee_request): ()
	const target = invsee_util.get_target(viewer)
	if target == nil then
		return
	end

	const inventory = inventory_util.get_inventory(target)
	const now = os.clock()
	-- a request made for another target raced with the session changing, applying it here would move the wrong items
	-- dropped requests still get a reply so the client rolls its prediction back
	if
		inventory ~= nil
		and request.target == target
		and now - (last_request_times[viewer] or 0) >= MIN_REQUEST_INTERVAL
	then
		last_request_times[viewer] = now
		-- slot validation happens inside the action
		if INVENTORY_ACTIONS[request.action](inventory, request.from, request.to) then
			inventory_util.mark_dirty(target)
		end
	end
	invsee_util.send(viewer, request.id)
end

-- also fires when only the selected slot changed, which is a harmless resend
const function on_inventory_changed(entity: registry.entity): ()
	if type(entity) ~= "string" then
		invsee_util.send_to_viewers_of(entity)
	end
end

const function on_entity_removed(entity: registry.entity): ()
	if type(entity) == "string" then
		return
	end
	last_request_times[entity] = nil
	invsee_util.stop(entity)
	invsee_util.stop_viewers_of(entity)
end

zap_server_network.request_invsee_action.set_callback(on_request)
zap_server_network.stop_invsee.set_callback(invsee_util.stop)
inventory_util.changed:Connect(on_inventory_changed)
registry.removed:Connect(on_entity_removed)
