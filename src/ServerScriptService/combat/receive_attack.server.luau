const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const SWORD_DAMAGE = require(ReplicatedStorage.shared.combat.SWORD_DAMAGE)

const attack_entity = require(script.Parent.attack_entity)
const inventory_util = require(ServerScriptService.inventory.inventory_util)

local function on_event(player: Player, target: unknown): ()
	if not inventory_util.has_behaviour(player, "sword") then
		return
	end
	if type(target) == "string" then
		attack_entity(player, target, SWORD_DAMAGE)
	elseif typeof(target) == "Instance" and target:IsA("Player") then
		attack_entity(player, target, SWORD_DAMAGE)
	end
end

ReplicatedStorage.remotes.attack_entity.OnServerEvent:Connect(on_event)
