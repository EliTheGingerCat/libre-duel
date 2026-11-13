const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const attack_entity = require(script.Parent.attack_entity)
const inventory_util = require(ServerScriptService.inventory.inventory_util)
const NON_SWORD_DAMAGE = require(ReplicatedStorage.shared.combat.NON_SWORD_DAMAGE)
const SWORD_DAMAGE = require(ReplicatedStorage.shared.combat.SWORD_DAMAGE)

const function on_event(player: Player, target: unknown): ()
	-- an empty hand can't attack, which keeps the lobby peaceful since nobody holds anything there
	const tool = inventory_util.get_selected_tool(player)
	if tool == nil then
		return
	end
	const sword = tool.behaviours.sword
	const damage = if sword ~= nil then sword.damage or SWORD_DAMAGE else NON_SWORD_DAMAGE
	if type(target) == "string" then
		attack_entity(player, target, damage)
	elseif typeof(target) == "Instance" and target:IsA("Player") then
		attack_entity(player, target, damage)
	end
end

ReplicatedStorage.remotes.attack_entity.OnServerEvent:Connect(on_event)
