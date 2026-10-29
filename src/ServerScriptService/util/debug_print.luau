local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

const CREATOR_ID = game.CreatorId
const IS_STUDIO = RunService:IsStudio()

local debug_enabled = true

local function debug_print(...: any): ()
	if debug_enabled then
		local source = debug.info(2, "s")
		print(source, ...)
	end
end

local function on_event(player: Player): ()
	local is_owner = player.UserId == CREATOR_ID
	local has_permission = IS_STUDIO or is_owner
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
