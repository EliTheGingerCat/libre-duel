const ReplicatedStorage = game:GetService("ReplicatedStorage")

const conch = require(ReplicatedStorage.Packages.conch)

-- the player running the current command, nil when it was not run by a player
-- only works inside a command callback, before it yields
const function get_executor_player(): Player?
	-- conch declares the context with read-only fields, which the type checker can't index
	const context = conch.get_command_context() :: any
	const player: Player | false | nil = if context ~= nil then context.executor.player else nil
	return player or nil
end

return get_executor_player
