local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local conch = require(ReplicatedStorage.Packages.conch)
local show_title = require(ServerScriptService.util.show_title)

-- Conch infers the callback's argument types from the inline arguments function, so these stay anonymous.
conch.register("show_title", {
	description = "Shows a title to a player",
	permissions = { "administrator" },
	arguments = function()
		return conch.args.player("player", "The player to show the title to"),
			conch.args.string("large_text", "The large text to show them (supports rich text)"),
			conch.args.string("small_text", "The small text to show them (supports rich text)"),
			conch.args.opt(conch.args.string("stay", "How much to make the title stay for"))
	end,

	callback = function(player, large_text, small_text, stay) -- typechecked!
		show_title(player, 0.5, stay or 5, 0.5, large_text, small_text)
	end,
})
