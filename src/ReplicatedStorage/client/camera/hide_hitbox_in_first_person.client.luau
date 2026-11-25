const Players = game:GetService("Players")

const camera_view_state = require(script.Parent.camera_view_state)

const local_player = Players.LocalPlayer

const HITBOX_NAMES = { hitbox = true, cube_hitbox = true }

const function apply_to_instance(instance: Instance): ()
	const hidden = not camera_view_state.third_person
	if instance:IsA("SelectionBox") then
		instance.Visible = not hidden
	elseif instance:IsA("BasePart") and HITBOX_NAMES[instance.Name] then
		instance.LocalTransparencyModifier = if hidden then 1 else 0
	end
end

const function apply_to_character(character: Model): ()
	for _, descendant in character:GetDescendants() do
		apply_to_instance(descendant)
	end
end

const function on_character_added(character: Model): ()
	apply_to_character(character)
	character.DescendantAdded:Connect(apply_to_instance)
end

const function on_view_changed(): ()
	if local_player.Character then
		apply_to_character(local_player.Character)
	end
end

local_player.CharacterAdded:Connect(on_character_added)
if local_player.Character then
	on_character_added(local_player.Character)
end
camera_view_state.changed:Connect(on_view_changed)
