local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local show_title = require(ServerScriptService.util.show_title)

local conch = require(ReplicatedStorage.Packages.conch)

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
            show_title(player, .5, stay or 5, .5, large_text, small_text)
	end,
})
