--> Serve information from the filesystem to the Roblox Studio plugin.

local serve = require("@tools/serve")
local write_git_info = require("./modules/write_git_info")

write_git_info()
serve()
