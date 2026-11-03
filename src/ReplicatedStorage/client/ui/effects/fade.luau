local function fade(from: number, to: number, duration: number, on_change: (number) -> ()): ()
	local started_at = os.clock()
	while duration > 0 do
		local progress = math.min(1, (os.clock() - started_at) / duration)
		on_change(from + (to - from) * progress)
		if progress == 1 then
			return
		end
		task.wait()
	end
	on_change(to)
end

return fade
