local ServerScriptService = game:GetService("ServerScriptService")

local cps_dictionary = require(script.Parent.cps_dictionary)
const zap_server_network = require(ServerScriptService.network.zap_server_network)

const function add_and_remove(player: Player): ()
	cps_dictionary[player] = cps_dictionary[player] or 0

	cps_dictionary[player] += 1
	task.wait(1)
	cps_dictionary[player] -= 1

	if cps_dictionary[player] == 0 then --breter98: cleanup is important! miau :3
		cps_dictionary[player] = nil
	end
end

-- SingleAsync in network.zap, so the wait in here doesn't hold up other events
zap_server_network.mouse_click.set_callback(add_and_remove)
