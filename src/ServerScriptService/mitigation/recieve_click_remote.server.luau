local ReplicatedStorage = game:GetService("ReplicatedStorage")

local cps_dictionary = require(script.Parent.cps_dictionary)

local function add_and_remove(player: Player)
	cps_dictionary[player] = cps_dictionary[player] or 0

	cps_dictionary[player] += 1
	task.wait(1)
	cps_dictionary[player] -= 1

	if cps_dictionary[player] == 0 then --breter98: cleanup is important! miau :3
		cps_dictionary[player] = nil
	end
end


ReplicatedStorage.remotes.mouse_click.OnServerEvent:Connect(function(player)
	add_and_remove(player)
end)
