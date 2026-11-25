local ServerScriptService = game:GetService("ServerScriptService")

const zap_server_network = require(ServerScriptService.network.zap_server_network)

const function show_title(
	player: Player | "all",
	fade_in: number,
	stay: number,
	fade_out: number,
	top_text: string,
	bottom_text: string?,
	colour: Color3?
): ()
	if typeof(player) == "Instance" then
		zap_server_network.show_title.fire(
			player,
			math.max(0, fade_in),
			math.max(0, stay),
			math.max(0, fade_out),
			top_text,
			bottom_text,
			colour
		)
	elseif player == "all" then
		zap_server_network.show_title.fire_all(
			math.max(0, fade_in),
			math.max(0, stay),
			math.max(0, fade_out),
			top_text,
			bottom_text,
			colour
		)
	end
	-- Luau has no `unreachable` keyword, just pretend there is one here...
	return
end

return show_title
