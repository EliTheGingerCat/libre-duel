const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const conch = require(ReplicatedStorage.Packages.conch)
const read_guild_data = require(ServerScriptService.guild.data.read_guild_data)
const read_player_data = require(ServerScriptService.player_data.read_player_data)

const function get_arguments()
	return conch.args.userid("user", "The username or user id whose guild to show, they can be offline")
end

-- every returned value becomes its own line in the console
const function guild_info(user_id: number): ...string
	const player_data = read_player_data(user_id)
	if player_data == nil then
		return `Could not read the data of {user_id}`
	end
	const guild_id = player_data.guild_id or ""
	if guild_id == "" then
		return `{user_id} is not in a guild`
	end
	const data = read_guild_data(guild_id)
	if data == nil then
		return `{user_id} points at guild {guild_id}, which doesn't exist (the hint clears on their next join)`
	end
	local member_count = 0
	for _ in data.members do
		member_count += 1
	end
	local invite_count = 0
	for _ in data.outgoing_invites do
		invite_count += 1
	end
	return `[{data.tag}] {data.name}`,
		`id: {data.id}`,
		`owner: {data.owner_id}`,
		`members: {member_count}, outgoing invites: {invite_count}`,
		`is a member: {data.members[tostring(user_id)] ~= nil}`,
		`rank history points: {#data.rank_history}`
end

conch.register("guild_info", {
	description = "Shows the saved guild of a player",
	permissions = { "administrator" },
	arguments = get_arguments,
	callback = guild_info,
})
