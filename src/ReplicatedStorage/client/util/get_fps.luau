local run_service = game:GetService("RunService")

local fps = 0
local frames = 0
local elapsed = 0

local function on_render(delta_time: number): ()
	frames += 1
	elapsed += delta_time
	if elapsed >= 0.5 then
		fps = math.round(frames / elapsed)
		frames = 0
		elapsed = 0
	end
end

run_service.RenderStepped:Connect(on_render)

local function get_fps(): number
	return fps
end

return get_fps
