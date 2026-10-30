const ReplicatedStorage = game:GetService("ReplicatedStorage")

const attack_entity = require(script.Parent.attack_entity)

local function on_event(player: Player, target: unknown): ()
	if type(target) == "string" then
		attack_entity(player, target)
	elseif typeof(target) == "Instance" and target:IsA("Player") then
		attack_entity(player, target)
	end
end

ReplicatedStorage.remotes.attack_entity.OnServerEvent:Connect(on_event)
