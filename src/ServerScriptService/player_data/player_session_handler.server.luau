const Players = game:GetService("Players")
const ServerScriptService = game:GetService("ServerScriptService")

const drop = require(ServerScriptService.ServerPackages.drop)
const PLAYER_STORE_NAME = require(script.Parent.PLAYER_STORE_NAME)
const initialize_player_data = require(script.Parent.initialize_player_data)
const player_schema = require(script.Parent.player_schema)
const player_store = require(script.Parent.player_store)

const function player_added(player)
    const key = tostring(player.UserId)
    const ok = pcall(drop.startsession, player_store, key)

    if not ok then
        -- let's give it another shot
        task.wait(1)
        const ok_retry = pcall(drop.startsession, player_store, key)
        if not ok_retry then
            player:Kick("Your data failed to load! :(")
        end
    end

    drop.waitforsession(player_store, key)
    initialize_player_data(key)
end

const function player_removing(player)
	const key = tostring(player.UserId)
	const function on_error(message: unknown)
		warn(`Could not stop session for {key}: {message}`)
	end
	-- errors if the session never started, or if shutdown already stopped it
	xpcall(drop.stopsessionasync, on_error, player_store, key)
end

Players.PlayerAdded:Connect(player_added)
Players.PlayerRemoving:Connect(player_removing)

for _, player in Players:GetPlayers() do
	task.spawn(player_added, player)
end
