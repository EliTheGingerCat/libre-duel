--> Remove all meta files that only set RunContext.

-- This happens with syncback since `emitLegacyScripts` is off in `default.project.json`.

-- This script has to be run before CRLF.

local run_context = require("@tools/run_context")

run_context()
