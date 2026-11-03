--> Generate a project file without the massive map.

local fs = require("@lune/fs")
local serde = require("@lune/serde")

local project = serde.decode("json", fs.readFile("./default.project.json"))

project.tree.Workspace["$path"] = "./src/Workspace_no_map"

fs.writeFile("./no_map.project.json", serde.encode("json", project))
