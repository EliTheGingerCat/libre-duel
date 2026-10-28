export type rectangle = {
	position: Vector2,
	size: Vector2,
}

export type layout = {
	anchor: Vector2,
	offset: Vector2,
}

local function anchor_axis(value: number): number
	return if value < 1 / 3 then 0 elseif value > 2 / 3 then 1 else 0.5
end

local function get_layout(rect: rectangle, bounds: Vector2, preview_factor: number): layout
	local centre = (rect.position + rect.size / 2) / bounds
	local anchor = Vector2.new(anchor_axis(centre.X), anchor_axis(centre.Y))
	return {
		anchor = anchor,
		offset = (rect.position + rect.size * anchor - bounds * anchor) / preview_factor,
	}
end

local handles = {
	Vector2.new(-1, -1),
	Vector2.new(0, -1),
	Vector2.new(1, -1),
	Vector2.new(-1, 0),
	Vector2.new(1, 0),
	Vector2.new(-1, 1),
	Vector2.new(0, 1),
	Vector2.new(1, 1),
}

local function contains(rect: rectangle, point: Vector2): boolean
	local relative = point - rect.position
	return relative.X >= 0 and relative.Y >= 0 and relative.X <= rect.size.X and relative.Y <= rect.size.Y
end

local function get_handle(rect: rectangle, point: Vector2): Vector2?
	for _, handle in handles do
		local position = rect.position + rect.size * ((handle + Vector2.one) / 2)
		if (point - position).Magnitude <= 9 then
			return handle
		end
	end
	return nil
end

local function targets(others: { rectangle }, bounds: Vector2): { Vector2 }
	local result = { Vector2.zero, bounds / 2, bounds }
	for _, other in others do
		table.insert(result, other.position)
		table.insert(result, other.position + other.size / 2)
		table.insert(result, other.position + other.size)
	end
	return result
end

local function move(rect: rectangle, delta: Vector2, others: { rectangle }, bounds: Vector2): rectangle
	local max_x = math.max(0, bounds.X - rect.size.X)
	local max_y = math.max(0, bounds.Y - rect.size.Y)
	local position = rect.position + delta
	position = Vector2.new(math.clamp(position.X, 0, max_x), math.clamp(position.Y, 0, max_y))
	local snap_x, snap_y = 9, 9
	local offset_x, offset_y = 0, 0
	for _, target in targets(others, bounds) do
		for _, fraction in { 0, 0.5, 1 } do
			local offset = target - (position + rect.size * fraction)
			if math.abs(offset.X) < snap_x and position.X + offset.X >= 0 and position.X + offset.X <= max_x then
				snap_x = math.abs(offset.X)
				offset_x = offset.X
			end
			if math.abs(offset.Y) < snap_y and position.Y + offset.Y >= 0 and position.Y + offset.Y <= max_y then
				snap_y = math.abs(offset.Y)
				offset_y = offset.Y
			end
		end
	end
	return { position = position + Vector2.new(offset_x, offset_y), size = rect.size }
end

local function resize(
	rect: rectangle,
	delta: Vector2,
	handle: Vector2,
	others: { rectangle },
	bounds: Vector2,
	multiplier: number
): rectangle
	local anchor = (Vector2.one - handle) / 2
	local fixed = rect.position + rect.size * anchor
	local direction = rect.size * handle
	local factor = 1 + delta:Dot(direction) / math.max(1, direction:Dot(direction))
	local maximum = 3 / multiplier
	for _, axis in { Vector2.xAxis, Vector2.yAxis } do
		local size = rect.size:Dot(axis)
		local anchor_axis = anchor:Dot(axis)
		if anchor_axis > 0 then
			maximum = math.min(maximum, fixed:Dot(axis) / math.max(1, size * anchor_axis))
		end
		if anchor_axis < 1 then
			maximum = math.min(maximum, (bounds - fixed):Dot(axis) / math.max(1, size * (1 - anchor_axis)))
		end
	end
	maximum = math.max(0.001, maximum)
	local minimum = math.min(0.25 / multiplier, maximum)
	factor = math.clamp(factor, minimum, maximum)
	local snap_distance = 9
	local snapped_factor = factor
	for _, target in targets(others, bounds) do
		for _, axis in { Vector2.xAxis, Vector2.yAxis } do
			local extent = direction:Dot(axis)
			if extent == 0 then
				continue
			end
			local candidate = (target - fixed):Dot(axis) / extent
			local distance = math.abs(candidate - factor) * math.abs(extent)
			if distance < snap_distance and candidate >= minimum and candidate <= maximum then
				snap_distance = distance
				snapped_factor = candidate
			end
		end
	end
	local size = rect.size * snapped_factor
	return { position = fixed - size * anchor, size = size }
end

return {
	contains = contains,
	get_handle = get_handle,
	get_layout = get_layout,
	move = move,
	resize = resize,
}
