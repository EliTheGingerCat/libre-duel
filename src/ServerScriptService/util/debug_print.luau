local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local creator_id = game.CreatorId
local is_studio = RunService:IsStudio()

local debug_enabled = false

local function debug_print(...: any): ()
	if debug_enabled then
		local source = debug.info(2, "s")
		print(source, ...)
	end
end

local function on_event(player: Player): ()
	local is_owner = player.UserId == creator_id
	local has_permission = is_studio or is_owner
	if not has_permission then
		return
	end

	debug_enabled = not debug_enabled
	if debug_enabled then
		print("Enabled debug printing.")
	else
		print("Disabled debug printing.")
	end
end

ReplicatedStorage.remotes.debug_server.OnServerEvent:Connect(on_event)

return debug_print
