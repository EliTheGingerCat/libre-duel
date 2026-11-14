const ReplicatedStorage = game:GetService("ReplicatedStorage")

const registry = require(ReplicatedStorage.shared.entity.registry)

-- EliTheGingerCat: I do not like how there are so many overloads for `CFrame.new`.
const function CFrame_from_position(position: Vector3): CFrame
	return CFrame.new(position)
end

const function move_entity(entity: registry.entity, position: Vector3): ()
	const character = registry.get_character(entity)
	if character == nil then
		return
	end

	const current_pivot = character:GetPivot()
	const current_rotation = current_pivot.Rotation
	const new_position_frame = CFrame_from_position(position)
	const new_pivot = new_position_frame * current_rotation

	character:PivotTo(new_pivot)
end

return move_entity
