local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote = ReplicatedStorage.remotes.show_title

local function show_title(
	player: Player | "all",
	fade_in: number,
	stay: number,
	fade_out: number,
	top_text: string,
	bottom_text: string?,
	colour: Color3?
): ()
	if typeof(player) == "Instance" then
		remote:FireClient(player, math.max(0, fade_in), math.max(0, stay), math.max(0, fade_out), top_text, bottom_text, colour)
	elseif player == "all" then
		remote:FireAllClients(math.max(0, fade_in), math.max(0, stay), math.max(0, fade_out), top_text, bottom_text, colour)
	end
	-- Luau has no `unreachable` keyword, just pretend there is one here...
	return
end

return show_title
