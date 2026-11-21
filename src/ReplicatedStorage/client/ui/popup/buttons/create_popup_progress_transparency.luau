const POPUP_LAYOUT = require(script.Parent.Parent.POPUP_LAYOUT)

const PROGRESS_TRANSPARENCY = POPUP_LAYOUT.PROGRESS_TRANSPARENCY
-- width of the hard edge between the filled and empty part
const EDGE_WIDTH = 0.001

-- progress goes from 0 (empty) to 1 (full), filling left to right
const function create_popup_progress_transparency(progress: number): NumberSequence
	if progress <= 0 then
		return NumberSequence.new(1)
	end
	if progress >= 1 - EDGE_WIDTH then
		return NumberSequence.new(PROGRESS_TRANSPARENCY)
	end
	return NumberSequence.new({
		NumberSequenceKeypoint.new(0, PROGRESS_TRANSPARENCY),
		NumberSequenceKeypoint.new(progress, PROGRESS_TRANSPARENCY),
		NumberSequenceKeypoint.new(progress + EDGE_WIDTH, 1),
		NumberSequenceKeypoint.new(1, 1),
	})
end

return create_popup_progress_transparency
