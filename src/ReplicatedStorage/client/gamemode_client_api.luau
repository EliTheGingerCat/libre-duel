local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function get_rf(name: string): RemoteFunction?
	local obj = ReplicatedStorage:FindFirstChild(name)
	if obj then
		return obj :: RemoteFunction
	end
	obj = ReplicatedStorage:WaitForChild(name, 5)
	return obj :: RemoteFunction
end

local api = {}

function api.get_this_server()
	local rf = get_rf("GetThisServerMetadata")
	if not rf then
		return { type = "lobby", code = nil }
	end
	local ok, result = pcall(function()
		return rf:InvokeServer()
	end)
	if not ok then
		return { type = "lobby", code = nil }
	end
	return result
end

function api.resolve_code(code: string)
	local rf = get_rf("ResolvePlaygroundCode")
	if not rf then
		return nil, "UNAVAILABLE"
	end
	local ok, result = pcall(function()
		return rf:InvokeServer(code)
	end)
	if not ok or not result or not result.ok then
		return nil, (result and result.error) or "RPC_FAILED"
	end
	return result.result, nil
end

function api.create_playground_and_teleport()
	local rf = get_rf("CreatePlaygroundAndTeleport")
	if not rf then
		return nil, "UNAVAILABLE"
	end
	local ok, result = pcall(function()
		return rf:InvokeServer()
	end)
	if not ok or not result or not result.ok then
		return nil, (result and result.error) or "RPC_FAILED"
	end
	return result.code, nil
end

function api.teleport_to_playground_by_code(code: string)
	local rf = get_rf("TeleportToPlaygroundByCode")
	if not rf then
		return false, "UNAVAILABLE"
	end
	local ok, result = pcall(function()
		return rf:InvokeServer(code)
	end)
	if not ok or not result or not result.ok then
		return false, (result and result.error) or "RPC_FAILED"
	end
	return true, nil
end

function api.join_queue(gamemode: string, variant: string)
	local rf = get_rf("JoinQueue")
	if not rf then
		return nil, "UNAVAILABLE"
	end
	local ok, result = pcall(function()
		return rf:InvokeServer(gamemode, variant)
	end)
	if not ok or not result or not result.ok then
		return nil, (result and result.error) or "RPC_FAILED"
	end
	return result, nil
end

function api.leave_queue()
	local rf = get_rf("LeaveQueue")
	if not rf then
		return false, "UNAVAILABLE"
	end
	local ok, result = pcall(function()
		return rf:InvokeServer()
	end)
	if not ok or not result or not result.ok then
		return false, (result and result.error) or "RPC_FAILED"
	end
	return true, nil
end

function api.get_queue_status()
	local rf = get_rf("GetQueueStatus")
	if not rf then
		return nil, "UNAVAILABLE"
	end
	local ok, result = pcall(function()
		return rf:InvokeServer()
	end)
	if not ok or not result or not result.ok then
		return nil, (result and result.error) or "RPC_FAILED"
	end
	return result, nil
end

return api