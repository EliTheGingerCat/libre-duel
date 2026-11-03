local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote = ReplicatedStorage.remotes.show_title

local function show_title(
	player: Player,
	fade_in: number,
	stay: number,
	fade_out: number,
	top_text: string,
	bottom_text: string?
): ()
	remote:FireClient(player, math.max(0, fade_in), math.max(0, stay), math.max(0, fade_out), top_text, bottom_text)
end

return show_title
