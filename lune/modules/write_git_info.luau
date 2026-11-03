local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")

local function git(arguments: { string }): string
	local result = process.exec("git", arguments)
	assert(result.ok, result.stderr)
	return result.stdout:match("^%s*(.-)%s*$") or ""
end

local function write_git_info(): ()
	local commit = git({ "rev-parse", "HEAD" })
	local project = {
		name = "git_info",
		tree = {
			["$className"] = "Folder",
			commit = {
				["$className"] = "StringValue",
				["$properties"] = { Value = commit },
			},
			license = { ["$path"] = "LICENSE.txt" },
		},
	}
	fs.writeFile("git_info.project.json", serde.encode("json", project, true) .. "\n")
end

return write_git_info
