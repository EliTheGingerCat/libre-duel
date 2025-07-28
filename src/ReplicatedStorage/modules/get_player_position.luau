local function get_player_position(player: Player): Vector3?
	local character = player.Character
	if not character then
		return nil
	end

	local primary_part = character.PrimaryPart
	if not primary_part then
		return nil
	end

	return primary_part.CFrame.Position
end

return get_player_position