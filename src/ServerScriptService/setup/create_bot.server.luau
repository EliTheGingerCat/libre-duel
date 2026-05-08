local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local debug_print = require(ServerScriptService.util.debug_print)
local entity = require(ReplicatedStorage.shared.entity)
local Chrono_entity = require(ReplicatedStorage.shared.shortcuts.Chrono_entity)

local model_Scientist = ServerStorage.assets.Scientist

local bot_creation_number: {[Player]: number} = {}

local initial_frame = CFrame.new(Vector3.new(0, 15, 0))

local function on_fire(player: Player): ()
	local count = bot_creation_number[player] or 0
	if count >= 3 then
		debug_print(`Too many bots for player "{player.Name}".`)
		return
	end
	local count_new = count + 1
	bot_creation_number[player] = count_new

	local model_clone = model_Scientist:Clone()
	model_clone.Name ..= ` of "{player.Name}" #{count_new}`
	model_clone.Parent = Workspace

	Chrono_entity.new("DEFAULT", model_clone, "NATIVE", initial_frame)

	entity.create({
		character = model_clone,
	})
end

local function on_player_removing(player: Player): ()
	bot_creation_number[player] = nil
end
Players.PlayerRemoving:Connect(on_player_removing)

ReplicatedStorage.remotes.create_bot.OnServerEvent:Connect(on_fire)
