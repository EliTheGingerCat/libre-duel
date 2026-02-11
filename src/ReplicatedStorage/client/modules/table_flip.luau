local function table_flip<I, V>(t: {[I]: V}): {[V]: I}
	local flipped = {}
	for index, value in t do
		flipped[value] = index
	end
	return flipped
end

return table_flip
