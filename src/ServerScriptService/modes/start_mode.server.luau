const Players = game:GetService("Players")
const RunService = game:GetService("RunService")

const get_server_type = require(script.Parent.Parent.util.get_server_type)

type mode = {
	reserved_server_types: { string },
	studio: boolean?,
	start: () -> (),
	stop: () -> (),
}

const load_mode: (ModuleScript) -> mode = require
const modes: { [string]: mode } = {}
local studio_mode: mode? = nil
local current_mode: mode? = nil

for _, module in script.Parent:GetChildren() do
	if not module:IsA("ModuleScript") then
		continue
	end
	const mode = load_mode(module)
	for _, server_type in mode.reserved_server_types do
		assert(modes[server_type] == nil, `Duplicate mode registration for {server_type}`)
		modes[server_type] = mode
	end
	if mode.studio then
		assert(studio_mode == nil, "Only one mode can be enabled in Studio")
		studio_mode = mode
	end
end

local function start_mode(mode: mode): ()
	if current_mode then
		return
	end
	current_mode = mode
	mode.start()
end

local function stop_mode(): ()
	if current_mode then
		current_mode.stop()
		current_mode = nil
	end
end

game:BindToClose(stop_mode)

if RunService:IsStudio() then
	if studio_mode then
		start_mode(studio_mode)
	end
	return
end

if get_server_type() ~= "reserved" then
	return
end

local function on_player_added(player: Player): ()
	if current_mode then
		return
	end

	const data: unknown = player:GetJoinData().TeleportData
	if typeof(data) ~= "table" then
		return
	end

	const fields = data :: { [string]: unknown }
	const server_type = fields.queue_mode
	if typeof(server_type) ~= "string" then
		return
	end

	const mode = modes[server_type]
	if mode then
		start_mode(mode)
	end
end

Players.PlayerAdded:Connect(on_player_added)
for _, player in Players:GetPlayers() do
	on_player_added(player)
end
