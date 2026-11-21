-- keeps the part of a left to right line with x up to progress, ending exactly at progress
const function slice_line_by_progress(points: { Vector2 }, progress: number): { Vector2 }
	const sliced = {}
	for index, point in points do
		if point.X <= progress then
			table.insert(sliced, point)
		else
			const previous = points[index - 1]
			if previous then
				const alpha = (progress - previous.X) / math.max(1e-6, point.X - previous.X)
				table.insert(sliced, previous:Lerp(point, alpha))
			end
			break
		end
	end
	return sliced
end

return slice_line_by_progress
