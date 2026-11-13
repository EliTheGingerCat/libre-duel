const TIE_EPSILON = 1e-4

-- Each part counts as its world-space bounding box, which is only exact for axis-aligned blocks.
-- The returned point's Y is the top of the surface that supports it.
local function get_nearest_supported_point(
	position: Vector3,
	feet_y: number,
	parts: { BasePart },
	overhang: number,
	step_tolerance: number
): Vector3?
	local best_point: Vector3? = nil
	local best_distance = math.huge
	local best_height_gap = math.huge

	for _, part in parts do
		local cframe = part.CFrame
		local half = part.Size / 2
		local right, up, look = cframe.RightVector, cframe.UpVector, cframe.LookVector

		local top_y = cframe.Y + math.abs(right.Y) * half.X + math.abs(up.Y) * half.Y + math.abs(look.Y) * half.Z
		local height_gap = math.abs(top_y - feet_y)
		if height_gap > step_tolerance then
			continue
		end

		local reach_x = math.abs(right.X) * half.X + math.abs(up.X) * half.Y + math.abs(look.X) * half.Z + overhang
		local reach_z = math.abs(right.Z) * half.X + math.abs(up.Z) * half.Y + math.abs(look.Z) * half.Z + overhang

		local x = math.clamp(position.X, cframe.X - reach_x, cframe.X + reach_x)
		local z = math.clamp(position.Z, cframe.Z - reach_z, cframe.Z + reach_z)
		local distance = math.sqrt((x - position.X) ^ 2 + (z - position.Z) ^ 2)

		-- Overlapping surfaces at different heights tie on distance, so prefer the one the feet are on.
		local is_closer = distance < best_distance - TIE_EPSILON
		local is_tied = distance < best_distance + TIE_EPSILON
		if is_closer or (is_tied and height_gap < best_height_gap) then
			best_point = Vector3.new(x, top_y, z)
			best_distance = distance
			best_height_gap = height_gap
		end
	end

	return best_point
end

return get_nearest_supported_point
