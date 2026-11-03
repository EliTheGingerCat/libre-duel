--> Create a mapping of the filesystem into Roblox objects.

local sourcemap = require("@tools/sourcemap")
local write_git_info = require("./modules/write_git_info")

write_git_info()
sourcemap()
