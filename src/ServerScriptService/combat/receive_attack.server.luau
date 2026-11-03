const ReplicatedStorage = game:GetService("ReplicatedStorage")

const SWORD_DAMAGE = require(ReplicatedStorage.shared.combat.SWORD_DAMAGE)

const attack_entity = require(script.Parent.attack_entity)

local function on_event(player: Player, target: unknown): ()
	if type(target) == "string" then
		attack_entity(player, target, SWORD_DAMAGE)
	elseif typeof(target) == "Instance" and target:IsA("Player") then
		attack_entity(player, target, SWORD_DAMAGE)
	end
end

ReplicatedStorage.remotes.attack_entity.OnServerEvent:Connect(on_event)
