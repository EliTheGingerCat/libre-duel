const ReplicatedStorage = game:GetService("ReplicatedStorage")

const dissolve_cube = require(script.Parent.dissolve_cube)

local function on_start(player: Player, id: unknown, cube: unknown): ()
	if not dissolve_cube.start(player, id, cube) and type(id) == "number" then
		ReplicatedStorage.remotes.dissolve_failed:FireClient(player, id)
	end
end

local function on_stop(player: Player, id: unknown): ()
	if type(id) == "number" then
		dissolve_cube.stop(player, id)
	end
end

ReplicatedStorage.remotes.dissolve_cube.OnServerEvent:Connect(on_start)
ReplicatedStorage.remotes.dissolve_stop.OnServerEvent:Connect(on_stop)
