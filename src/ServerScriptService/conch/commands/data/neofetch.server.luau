const ReplicatedStorage = game:GetService("ReplicatedStorage")
const conch = require(ReplicatedStorage.Packages.conch)

const git_info = ReplicatedStorage:WaitForChild("git_info")
const commit = git_info:WaitForChild("commit") :: StringValue

const RED = "\27[31m"
const WHITE = "\27[315m"
const CYAN = "\27[36m"
const RESET = "\27[0m"

const function get_neofetch_arguments() end

const function format_uptime(seconds: number): string
	const hours = math.floor(seconds / 3600)
	const minutes = math.floor(seconds % 3600 / 60)
	return `{hours}h {minutes}m`
end

const function neofetch(): ...string
	const uptime = format_uptime(workspace.DistributedGameTime)
	return `{RED}gr 4P $ _  _   _{RESET}`,
		`{RED}@L J@J@FM@W@Ph@~5${RESET}     Libre Duel`,
		`{RED}@yyJ@J@aa@M@  @ya={RESET}     Git commit: {commit.Value}`,
		`{WHITE}gp{RESET}{CYAN}gagy _  _  __  ${RESET}     CPU: Ryzen 7 9700X`,
		`{WHITE}@M{RESET}{CYAN}$  $L@L @L$EZ@W@{RESET}     Uptime: {uptime}`,
		`{WHITE}@M{RESET}{CYAN}@aaP @ga@LRaa=4@{RESET}`
end

conch.register("neofetch", {
	description = "Gives you some info",
	permissions = {},
	arguments = get_neofetch_arguments,
	callback = neofetch,
})
