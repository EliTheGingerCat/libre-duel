const Players = game:GetService("Players")
const ServerScriptService = game:GetService("ServerScriptService")

const drop = require(ServerScriptService.ServerPackages.drop)
const initialize_player_data = require(script.Parent.initialize_player_data)
const player_store = require(ServerScriptService.player_data.player_store)
const active_session_keys = require(script.Parent.active_session_keys)
const run_session_stopping_callbacks = require(script.Parent.run_session_stopping_callbacks)

const function player_added(player: Player): ()
	const key = tostring(player.UserId)
	const function start_session(): ()
		drop.startsession(player_store, key)
	end
	const ok = pcall(start_session)

	if not ok then
		-- let's give it another shot
		task.wait(1)
		const ok_retry = pcall(start_session)
		if not ok_retry then
			player:Kick("Your data failed to load! :(")
			return
		end
	end

	drop.waitforsession(player_store, key)
	active_session_keys[key] = true
	initialize_player_data(key)
end

const function player_removing(player: Player): ()
	const key = tostring(player.UserId)
	const had_active_session = run_session_stopping_callbacks(player)
	if not had_active_session then
		return
	end

	const function on_error(message: unknown)
		warn(`Could not stop session for {key}: {message}`)
	end
	-- errors if shutdown already stopped it
	xpcall(drop.stopsessionasync, on_error, player_store, key)
end

Players.PlayerAdded:Connect(player_added)
Players.PlayerRemoving:Connect(player_removing)

for _, player in Players:GetPlayers() do
	task.spawn(player_added, player)
end
