const ReplicatedStorage = game:GetService("ReplicatedStorage")

const apply_knockback = require(ReplicatedStorage.shared.combat.apply_knockback)
const registry = require(ReplicatedStorage.shared.entity.registry)

-- players simulate their own character, so their knockback is applied on their client
-- bots are simulated by the server, so theirs is applied here
const function send_knockback(
	target: registry.entity,
	target_root: BasePart,
	vector: Vector3,
	strength_x: number,
	strength_y: number
): ()
	const target_player = registry.get_player(target)
	if target_player == nil then
		apply_knockback(vector, target_root, strength_x, strength_y)
		return
	end
	ReplicatedStorage.remotes.knockback:FireClient(target_player, vector, strength_x, strength_y)
end

return send_knockback
