const ReplicatedStorage = game:GetService("ReplicatedStorage")

const registry = require(ReplicatedStorage.shared.entity.registry)

-- EliTheGingerCat: I do not like how there are so many overloads for `CFrame.new`.
const function CFrame_from_position(position: Vector3): CFrame
	return CFrame.new(position)
end

-- only the rotation of `facing` is used, without it the character keeps its current rotation
const function move_entity(entity: registry.entity, position: Vector3, facing: CFrame?): ()
	const character = registry.get_character(entity)
	if character == nil then
		return
	end

	const new_rotation = if facing then facing.Rotation else character:GetPivot().Rotation
	const new_position_frame = CFrame_from_position(position)
	const new_pivot = new_position_frame * new_rotation

	character:PivotTo(new_pivot)
end

return move_entity
