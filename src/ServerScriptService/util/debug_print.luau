local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

const zap_server_network = require(ServerScriptService.network.zap_server_network)

const CREATOR_ID = game.CreatorId
const IS_STUDIO = RunService:IsStudio()

local debug_enabled = true

const function debug_print(...: any): ()
	if debug_enabled then
		local source = debug.info(2, "s")
		print(source, ...)
	end
end

const function on_event(player: Player): ()
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

zap_server_network.debug_server.set_callback(on_event)

return debug_print
