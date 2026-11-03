--> Build the Place without the massive map.

local build = require("@tools/build")
local build_name = require("../build_name")
local write_git_info = require("./modules/write_git_info")

write_git_info()
build(build_name, "./no_map.project.json")
