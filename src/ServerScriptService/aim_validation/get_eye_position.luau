const ReplicatedStorage = game:GetService("ReplicatedStorage")

const chrono = require(ReplicatedStorage.Packages.chrono)
const EYE_OFFSET = require(ReplicatedStorage.shared.aim.EYE_OFFSET)
const registry = require(ReplicatedStorage.shared.entity.registry)

-- chrono's latest snapshot is what the client last reported, while the root part on the server
-- trails it by native replication's own delay, which adds up fast when running and jumping
const function get_freshest_root_position(entity: registry.entity, root: BasePart): Vector3
	if type(entity) == "string" then
		return root.Position
	end
	const chrono_entity = chrono.Holder.GetEntityFromPlayer(entity)
	const latest_cframe = if chrono_entity then chrono_entity.latestCFrame else nil
	return if latest_cframe then latest_cframe.Position else root.Position
end

-- where reach is measured from
const function get_eye_position(entity: registry.entity): Vector3?
	const character = registry.get_character(entity)
	const root = if character then character:FindFirstChild("HumanoidRootPart") else nil
	if root == nil or not root:IsA("BasePart") then
		return nil
	end
	return get_freshest_root_position(entity, root) + EYE_OFFSET
end

return get_eye_position
