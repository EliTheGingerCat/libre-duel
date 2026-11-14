const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const INVENTORY_ACTIONS = require(ReplicatedStorage.shared.inventory.INVENTORY_ACTIONS)
const inventory_util = require(ServerScriptService.inventory.inventory_util)
const invsee_util = require(script.Parent.invsee_util)
const registry = require(ReplicatedStorage.shared.entity.registry)

const invsee = ReplicatedStorage.remotes.invsee

const MIN_REQUEST_INTERVAL = 0.05

local last_request_times: { [Player]: number } = {}

const function on_request(viewer: Player, arguments: unknown): ()
	const target = invsee_util.get_target(viewer)
	if target == nil or type(arguments) ~= "table" then
		return
	end
	const request = arguments :: { [any]: unknown }
	if request.action == "stop" then
		invsee_util.stop(viewer)
		return
	end
	const action = INVENTORY_ACTIONS[request.action :: any]
	const id = request.id
	if not action or type(id) ~= "number" then
		return
	end

	const inventory = inventory_util.get_inventory(target)
	const now = os.clock()
	-- a request made for another target raced with the session changing, applying it here would move the wrong items
	-- dropped requests still get a reply so the client rolls its prediction back
	if
		inventory ~= nil
		and request.target :: Player? == target
		and now - (last_request_times[viewer] or 0) >= MIN_REQUEST_INTERVAL
	then
		last_request_times[viewer] = now
		-- slot validation happens inside the action
		if action(inventory, request.from :: number, request.to :: number) then
			inventory_util.mark_dirty(target)
		end
	end
	invsee_util.send(viewer, id)
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

invsee.OnServerEvent:Connect(on_request)
inventory_util.changed:Connect(on_inventory_changed)
registry.removed:Connect(on_entity_removed)
