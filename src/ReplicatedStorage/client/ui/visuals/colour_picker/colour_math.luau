local function from_hsv(hue: number, saturation: number, value: number): Color3
	local sector = (hue % 1) * 6
	local chroma = value * saturation
	local secondary = chroma * (1 - math.abs(sector % 2 - 1))
	local offset = value - chroma
	local rgb = if sector < 1
		then Vector3.new(chroma, secondary, 0)
		elseif sector < 2 then Vector3.new(secondary, chroma, 0)
		elseif sector < 3 then Vector3.new(0, chroma, secondary)
		elseif sector < 4 then Vector3.new(0, secondary, chroma)
		elseif sector < 5 then Vector3.new(secondary, 0, chroma)
		else Vector3.new(chroma, 0, secondary)
	return Color3.new(rgb.X + offset, rgb.Y + offset, rgb.Z + offset)
end

return { from_hsv = from_hsv }
