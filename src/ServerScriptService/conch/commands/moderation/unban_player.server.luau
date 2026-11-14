const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const conch = require(ReplicatedStorage.Packages.conch)

const function get_arguments()
	return conch.args.userid("user", "The username or user id of the banned player")
end

const function unban(user_id: number): string
	-- returns nothing useful, the return type only gives pcall a slot for the error message
	const function unban_async(): string?
		-- the ban command applies to the universe, so the unban has to as well
		Players:UnbanAsync({ UserIds = { user_id }, ApplyToUniverse = true })
		return nil
	end
	const ok, message = pcall(unban_async)
	if not ok then
		return `Could not unban {user_id}: {message}`
	end
	return `Unbanned {user_id}`
end

conch.register("unban", {
	description = "Lifts a ban, the player does not have to be in the server",
	permissions = { "administrator" },
	arguments = get_arguments,
	callback = unban,
})
