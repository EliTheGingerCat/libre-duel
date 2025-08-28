local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MemoryStoreService = game:GetService("MemoryStoreService")
local TeleportService = game:GetService("TeleportService")
local MessagingService = game:GetService("MessagingService")

local PLACE_ID = game.PlaceId
local JOB_ID = game.JobId
local ENTRY_TTL = 120
local REFRESH_INTERVAL = 60

local servers_map = MemoryStoreService:GetHashMap("ld:servers")
local playground_codes_map = MemoryStoreService:GetHashMap("ld:playground_codes")
local queues_map = MemoryStoreService:GetHashMap("ld:queues")

local current_type = "lobby"
local current_code: string? = nil
local reserved_access_code: string? = nil
local owner_user_id: number? = nil
local gamemode_variant: string? = nil

local pending_teleports = {}

local function ensure_rf(name: string)
	local rf = ReplicatedStorage:FindFirstChild(name)
	if not rf then
		rf = Instance.new("RemoteFunction")
		rf.Name = name
		rf.Parent = ReplicatedStorage
	end
	return rf :: RemoteFunction
end

local RF_GetThisServerMetadata = ensure_rf("GetThisServerMetadata")
local RF_ResolvePlaygroundCode = ensure_rf("ResolvePlaygroundCode")
local RF_CreatePlaygroundAndTeleport = ensure_rf("CreatePlaygroundAndTeleport")
local RF_TeleportToPlaygroundByCode = ensure_rf("TeleportToPlaygroundByCode")
local RF_JoinQueue = ensure_rf("JoinQueue")
local RF_LeaveQueue = ensure_rf("LeaveQueue")
local RF_GetQueueStatus = ensure_rf("GetQueueStatus")

local function now()
	return os.time()
end

local ALPHANUM = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
local function generate_code(len: number)
	local s = table.create(len)
	for i = 1, len do
		local idx = math.random(1, #ALPHANUM)
		s[i] = string.sub(ALPHANUM, idx, idx)
	end
	return table.concat(s)
end

local function publish_server_state()
	local data = {
		placeId = PLACE_ID,
		jobId = JOB_ID,
		serverType = current_type,
		updatedAt = now(),
	}

	if current_type == "playground" then
		data.ownerUserId = owner_user_id
		data.reservedAccessCode = reserved_access_code
		data.playgroundCode = current_code
	elseif current_type ~= "lobby" then
		data.gamemode = current_type
		data.variant = gamemode_variant
		data.reservedAccessCode = reserved_access_code
	end

	pcall(function()
		servers_map:SetAsync(JOB_ID, data, ENTRY_TTL)
	end)

	if current_type == "playground" and current_code then
		pcall(function()
			playground_codes_map:SetAsync(current_code, {
				jobId = JOB_ID,
				placeId = PLACE_ID,
				updatedAt = now()
			}, ENTRY_TTL)
		end)
	end
end

task.spawn(function()
	while task.wait(REFRESH_INTERVAL) do
		publish_server_state()
	end
end)

game:BindToClose(function()
	pcall(function()
		servers_map:RemoveAsync(JOB_ID)
	end)
	if current_code then
		pcall(function()
			playground_codes_map:RemoveAsync(current_code)
		end)
	end
end)

local first_player_detected = false
Players.PlayerAdded:Connect(function(player)
	if first_player_detected then
		return
	end
	first_player_detected = true

	local join_data
	pcall(function()
		join_data = player:GetJoinData()
	end)
	local tdata = join_data and join_data.TeleportData

	if tdata then
		if tdata.kind == "playground" and tdata.code and tdata.reserved then
			current_type = "playground"
			current_code = tostring(tdata.code)
			reserved_access_code = tostring(tdata.reserved)
			owner_user_id = tdata.ownerUserId or player.UserId
		elseif tdata.kind == "gamemode" and tdata.gamemode and tdata.variant then
			current_type = tostring(tdata.gamemode)
			gamemode_variant = tostring(tdata.variant)
			reserved_access_code = tostring(tdata.reserved)
		end
	end

	publish_server_state()
end)

pcall(function()
	MessagingService:SubscribeAsync("LD_TELEPORT_QUEUE", function(message)
		local data = message.Data
		if data.action == "teleport_players" then
			local user_ids = data.userIds
			local teleport_data = data.teleportData
			local reserved_code = data.reservedCode
			
			local local_players = {}
			for _, user_id in user_ids do
				local target_player = Players:GetPlayerByUserId(user_id)
				if target_player then
					table.insert(local_players, target_player)
				end
			end
			
			if #local_players > 0 then
				pcall(function()
					TeleportService:TeleportToPrivateServer(PLACE_ID, reserved_code, local_players, nil, teleport_data)
				end)
			end
		end
	end)
end)

RF_GetThisServerMetadata.OnServerInvoke = function(_player)
	return { 
		type = current_type, 
		code = current_code, 
		placeId = PLACE_ID, 
		jobId = JOB_ID,
		gamemode = current_type ~= "lobby" and current_type ~= "playground" and current_type or nil,
		variant = gamemode_variant
	}
end

local function handle_create_playground_and_teleport(player: Player)
	local reserved_code
	local ok = pcall(function()
		reserved_code = TeleportService:ReserveServer(PLACE_ID)
	end)
	if not ok or not reserved_code then
		return { ok = false, error = "RESERVE_FAILED" }
	end

	local code
	for _ = 1, 10 do
		code = generate_code(6)
		local exists
		pcall(function()
			exists = playground_codes_map:GetAsync(code)
		end)
		if not exists then break else code = nil end
	end
	if not code then
		return { ok = false, error = "CODE_GEN_FAILED" }
	end

	local teleport_data = { kind = "playground", code = code, reserved = reserved_code, ownerUserId = player.UserId }
	local success = pcall(function()
		TeleportService:TeleportToPrivateServer(PLACE_ID, reserved_code, { player }, nil, teleport_data)
	end)
	if not success then
		return { ok = false, error = "TELEPORT_FAILED" }
	end

	return { ok = true, code = code }
end

local function handle_teleport_to_playground_by_code(player: Player, code: string)
	if type(code) ~= "string" then
		return { ok = false, error = "INVALID_CODE" }
	end
	local code_data
	local ok = pcall(function()
		code_data = playground_codes_map:GetAsync(code)
	end)
	if not ok or not code_data then
		return { ok = false, error = "NOT_FOUND" }
	end

	local server_data
	pcall(function()
		server_data = servers_map:GetAsync(code_data.jobId)
	end)
	if not server_data or not server_data.reservedAccessCode then
		return { ok = false, error = "SERVER_NOT_FOUND" }
	end

	local tdata = { kind = "playground", code = string.upper(code), reserved = server_data.reservedAccessCode }
	local success = pcall(function()
		TeleportService:TeleportToPrivateServer(PLACE_ID, server_data.reservedAccessCode, { player }, nil, tdata)
	end)
	if not success then
		return { ok = false, error = "TELEPORT_FAILED" }
	end
	return { ok = true }
end

local QUEUE_REQUIREMENTS = {
	["bridge-1v1"] = 2,
	["bridge-2v2"] = 4,
	["bridge-3v3"] = 6,
	["bridge-4v4"] = 8,
	["basicfight-1v1"] = 2,
	["basicfight-2v2"] = 4,
	["boxing-1v1"] = 2,
}

local function handle_leave_queue(player: Player)
	for queue_name, _ in QUEUE_REQUIREMENTS do
		local queue_data
		local get_success = pcall(function()
			queue_data = queues_map:GetAsync(queue_name)
		end)
		
		if get_success and queue_data and queue_data.players then
			for i, queued_player in queue_data.players do
				if queued_player.userId == player.UserId then
					table.remove(queue_data.players, i)
					pcall(function()
						queues_map:SetAsync(queue_name, queue_data, ENTRY_TTL)
					end)
					return { ok = true }
				end
			end
		end
	end
	return { ok = false, error = "NOT_IN_QUEUE" }
end

local function distribute_teleport_command(players_by_server, teleport_data, reserved_code)
	local servers_to_notify = {}
	
	for job_id, user_ids in players_by_server do
		if job_id == JOB_ID then
			local local_players = {}
			for _, user_id in user_ids do
				local target_player = Players:GetPlayerByUserId(user_id)
				if target_player then
					table.insert(local_players, target_player)
				end
			end
			if #local_players > 0 then
				task.spawn(function()
					pcall(function()
						TeleportService:TeleportToPrivateServer(PLACE_ID, reserved_code, local_players, nil, teleport_data)
					end)
				end)
			end
		else
			table.insert(servers_to_notify, {
				jobId = job_id,
				userIds = user_ids
			})
		end
	end
	
	for _, server_info in servers_to_notify do
		task.spawn(function()
			pcall(function()
				MessagingService:PublishAsync("LD_TELEPORT_QUEUE", {
					action = "teleport_players",
					targetJobId = server_info.jobId,
					userIds = server_info.userIds,
					teleportData = teleport_data,
					reservedCode = reserved_code
				})
			end)
		end)
	end
end

local function handle_join_queue(player: Player, gamemode: string, variant: string)
	if type(gamemode) ~= "string" or type(variant) ~= "string" then
		return { ok = false, error = "INVALID_PARAMS" }
	end

	local queue_key = gamemode .. "-" .. variant
	local required_players = QUEUE_REQUIREMENTS[queue_key]
	if not required_players then
		return { ok = false, error = "INVALID_QUEUE" }
	end

	handle_leave_queue(player)

	local queue_data
	local get_success = pcall(function()
		queue_data = queues_map:GetAsync(queue_key) or { players = {}, createdAt = now() }
	end)
	
	if not get_success then
		return { ok = false, error = "QUEUE_UNAVAILABLE" }
	end

	local player_in_queue = false
	for _, queued_player in queue_data.players do
		if queued_player.userId == player.UserId then
			player_in_queue = true
			break
		end
	end

	if not player_in_queue then
		table.insert(queue_data.players, {
			userId = player.UserId,
			jobId = JOB_ID,
			joinedAt = now()
		})
	end

	local should_create_match = #queue_data.players >= required_players
	local players_to_teleport = {}
	
	if should_create_match then
		for i = 1, required_players do
			table.insert(players_to_teleport, queue_data.players[i])
		end
		
		for i = required_players, 1, -1 do
			table.remove(queue_data.players, i)
		end
	end

	local set_success = pcall(function()
		queues_map:SetAsync(queue_key, queue_data, ENTRY_TTL)
	end)

	if not set_success then
		return { ok = false, error = "QUEUE_UPDATE_FAILED" }
	end

	if should_create_match then
		local new_reserved_code
		local reserve_success = pcall(function()
			new_reserved_code = TeleportService:ReserveServer(PLACE_ID)
		end)

		if not reserve_success or not new_reserved_code then
			for _, player_data in players_to_teleport do
				table.insert(queue_data.players, 1, player_data)
			end
			pcall(function()
				queues_map:SetAsync(queue_key, queue_data, ENTRY_TTL)
			end)
			return { ok = true, queueSize = #queue_data.players, required = required_players }
		end

		local teleport_data = { 
			kind = "gamemode", 
			gamemode = gamemode, 
			variant = variant, 
			reserved = new_reserved_code 
		}

		local players_by_server = {}
		for _, player_data in players_to_teleport do
			local job_id = player_data.jobId
			if not players_by_server[job_id] then
				players_by_server[job_id] = {}
			end
			table.insert(players_by_server[job_id], player_data.userId)
		end
		
		distribute_teleport_command(players_by_server, teleport_data, new_reserved_code)
	end
	
	return { ok = true, queueSize = #queue_data.players, required = required_players }
end

local function handle_get_queue_status(player: Player)
	for queue_name, required in QUEUE_REQUIREMENTS do
		local queue_data
		pcall(function()
			queue_data = queues_map:GetAsync(queue_name)
		end)
		
		if queue_data and queue_data.players then
			for _, queued_player in queue_data.players do
				if queued_player.userId == player.UserId then
					return { 
						ok = true, 
						queue = queue_name, 
						current = #queue_data.players, 
						required = required 
					}
				end
			end
		end
	end
	return { ok = false }
end

RF_ResolvePlaygroundCode.OnServerInvoke = function(_player, code: string)
	if type(code) ~= "string" or #code < 4 then
		return { ok = false, error = "INVALID_CODE" }
	end
	local code_data
	local ok = pcall(function()
		code_data = playground_codes_map:GetAsync(string.upper(code))
	end)
	if not ok or not code_data then
		return { ok = false, error = "NOT_FOUND" }
	end
	return { ok = true, result = code_data }
end

RF_CreatePlaygroundAndTeleport.OnServerInvoke = handle_create_playground_and_teleport
RF_TeleportToPlaygroundByCode.OnServerInvoke = handle_teleport_to_playground_by_code
RF_JoinQueue.OnServerInvoke = handle_join_queue
RF_LeaveQueue.OnServerInvoke = handle_leave_queue
RF_GetQueueStatus.OnServerInvoke = handle_get_queue_status

Players.PlayerRemoving:Connect(function(player)
	task.spawn(function()
		handle_leave_queue(player)
	end)
end)