const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")

const MODE_DEFINITIONS = require(ReplicatedStorage.shared.modes.MODE_DEFINITIONS)
const get_mode_definition = require(ReplicatedStorage.shared.modes.get_mode_definition)
const get_server_type = require(script.Parent.Parent.util.get_server_type)
const parse_queue_mode = require(ReplicatedStorage.shared.queue.parse_queue_mode)

type definition = MODE_DEFINITIONS.definition
type mode = {
	studio: boolean?,
	start: (definition) -> (),
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
	modes[module.Name] = mode
	if mode.studio then
		assert(studio_mode == nil, "Only one mode can be enabled in Studio")
		studio_mode = mode
	end
end

local function start_mode(mode: mode, definition: definition): ()
	if current_mode then
		return
	end
	current_mode = mode
	mode.start(definition)
end

local function stop_mode(): ()
	if current_mode then
		current_mode.stop()
		current_mode = nil
	end
end

game:BindToClose(stop_mode)

if RunService:IsStudio() then
	for _, definition in MODE_DEFINITIONS do
		if studio_mode and modes[definition.game] == studio_mode then
			start_mode(studio_mode, definition)
			break
		end
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
	const mode_id: MODE_DEFINITIONS.mode_id? = parse_queue_mode(fields.queue_mode)
	if mode_id == nil then
		return
	end

	const definition = get_mode_definition(mode_id)
	const mode = modes[definition.game]
	if mode then
		start_mode(mode, definition)
	end
end

Players.PlayerAdded:Connect(on_player_added)
for _, player in Players:GetPlayers() do
	on_player_added(player)
end
