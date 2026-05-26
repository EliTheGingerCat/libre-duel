local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local debug_print = require(ServerScriptService.util.debug_print)
local entity_mod = require(ReplicatedStorage.shared.entity)
local Chrono_entity = require(ReplicatedStorage.shared.shortcuts.Chrono_entity)
local Chrono_entity_mod = require(ReplicatedStorage.shared.shortcuts.Chrono_entity)

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

	local entity_Chrono = Chrono_entity_mod.new("DEFAULT", model_clone, "NATIVE", initial_frame)

	entity_mod.create({
		character = model_clone,
	})

	local function on_primary_part_changed(): ()
		local primary_part = model_clone.PrimaryPart
		if primary_part == nil then
			Chrono_entity.Destroy(entity_Chrono)
			-- If this is not done, the output will be flooded with a repeated warning message. Regardless, Chrono entities require a primary part.
		end
	end

	model_clone:GetPropertyChangedSignal("PrimaryPart"):Connect(on_primary_part_changed)
end

local function on_player_removing(player: Player): ()
	bot_creation_number[player] = nil
end
Players.PlayerRemoving:Connect(on_player_removing)

ReplicatedStorage.remotes.create_bot.OnServerEvent:Connect(on_fire)
