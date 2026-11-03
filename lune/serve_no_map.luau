--> Serve without the massive map.

local serve = require("@tools/serve")
local write_git_info = require("./modules/write_git_info")

write_git_info()
serve("./no_map.project.json")
