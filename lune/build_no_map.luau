--> Build the Place without the massive map.

local build = require("@tools/build")
local build_name = require("../build_name")

build(build_name, "./no_map.project.json")