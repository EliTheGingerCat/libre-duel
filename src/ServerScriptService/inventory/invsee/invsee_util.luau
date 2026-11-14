-- lets one player look into and rearrange the inventory of another
-- a session can only be started from the server, so having one is the permission check

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const inventory_types = require(ReplicatedStorage.shared.inventory.inventory_types)
const inventory_util = require(ServerScriptService.inventory.inventory_util)
const invsee_sessions = require(script.Parent.invsee_sessions)

const invsee = ReplicatedStorage.remotes.invsee

local invsee_util = {}

-- `id` is the request this answers, nil for a push
function invsee_util.send(viewer: Player, id: number?): ()
	const target = invsee_sessions[viewer]
	if target == nil then
		return
	end
	const update: inventory_types.invsee_update = {
		target = target,
		inventory = inventory_util.get_inventory(target),
		id = id,
	}
	invsee:FireClient(viewer, update)
end

function invsee_util.get_target(viewer: Player): Player?
	return invsee_sessions[viewer]
end

-- replaces whatever session the viewer already had
function invsee_util.start(viewer: Player, target: Player): ()
	invsee_sessions[viewer] = target
	invsee_util.send(viewer)
end

function invsee_util.stop(viewer: Player): ()
	if invsee_sessions[viewer] == nil then
		return
	end
	invsee_sessions[viewer] = nil
	-- players who left can't be fired to
	if viewer.Parent ~= nil then
		const update: inventory_types.invsee_update = {}
		invsee:FireClient(viewer, update)
	end
end

function invsee_util.send_to_viewers_of(target: Player): ()
	for viewer, viewed in invsee_sessions do
		if viewed == target then
			invsee_util.send(viewer)
		end
	end
end

function invsee_util.stop_viewers_of(target: Player): ()
	for viewer, viewed in invsee_sessions do
		if viewed == target then
			invsee_util.stop(viewer)
		end
	end
end

return invsee_util
