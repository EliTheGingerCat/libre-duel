const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const SWORD_DAMAGE = require(ReplicatedStorage.shared.combat.SWORD_DAMAGE)

const attack_entity = require(script.Parent.attack_entity)
const inventory_util = require(ServerScriptService.inventory.inventory_util)

local function on_event(player: Player, target: unknown): ()
	const tool = inventory_util.get_selected_tool(player)
	const sword = if tool ~= nil then tool.behaviours.sword else nil
	if sword == nil then
		return
	end
	const damage = sword.damage or SWORD_DAMAGE
	if type(target) == "string" then
		attack_entity(player, target, damage)
	elseif typeof(target) == "Instance" and target:IsA("Player") then
		attack_entity(player, target, damage)
	end
end

ReplicatedStorage.remotes.attack_entity.OnServerEvent:Connect(on_event)
