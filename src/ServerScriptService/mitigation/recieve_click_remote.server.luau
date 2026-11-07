local ReplicatedStorage = game:GetService("ReplicatedStorage")

local cps_dictionary = require(script.Parent.cps_dictionary)

local function add_and_remove(player: Player, click_type: unknown): ()
	if click_type ~= "attack" and click_type ~= "use" then
		return
	end
	const clicks = cps_dictionary[click_type :: cps_dictionary.click_type]

	clicks[player] = clicks[player] or 0

	clicks[player] += 1
	task.wait(1)
	clicks[player] -= 1

	if clicks[player] == 0 then --breter98: cleanup is important! miau :3
		clicks[player] = nil
	end
end

ReplicatedStorage.remotes.mouse_click.OnServerEvent:Connect(add_and_remove)
