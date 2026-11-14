const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")

const conch = require(ReplicatedStorage.Packages.conch)

const get_owner = require(script.Parent.Parent.util.get_owner)

const SUPER_USER_ROLE = "super-user"
const OWNER_LOOKUP_ATTEMPTS = 5
const OWNER_LOOKUP_RETRY_DELAY = 2

const function get_owner_id(): number | string
	return get_owner("userid")
end

-- the lookup goes through web calls that can fail, nil when every attempt did
const function find_owner_id(): number?
	for attempt = 1, OWNER_LOOKUP_ATTEMPTS do
		const ok, result = pcall(get_owner_id)
		if ok and type(result) == "number" then
			return result
		end
		warn(`Could not look up the game owner (attempt {attempt}): {result}`)
		task.wait(OWNER_LOOKUP_RETRY_DELAY)
	end
	return nil
end

local owner_id: number? = nil

-- everyone in a studio test counts, since the owner of an unpublished place can't be looked up
const function on_player_added(player: Player): ()
	if RunService:IsStudio() or player.UserId == owner_id then
		conch.give_roles(conch.get_user(player), SUPER_USER_ROLE)
	end
end

if not RunService:IsStudio() then
	owner_id = find_owner_id()
end

-- the owner is rarely in the server when it starts, so this can't be a single lookup in Players
Players.PlayerAdded:Connect(on_player_added)
for _, player in Players:GetPlayers() do
	on_player_added(player)
end
