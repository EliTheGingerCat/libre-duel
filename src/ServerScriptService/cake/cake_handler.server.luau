const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const CAKE_EATING_DURATION = require(script.Parent.CAKE_EATING_DURATION)

const set_cake_state = ReplicatedStorage.remotes.set_cake_state

type eating_session = {
	character: Model,
}

const eating_sessions: { [Player]: eating_session } = {}

local function on_invoke(player: Player, new_state: unknown): boolean
	if type(new_state) ~= "boolean" then
		return false
	end
	if not new_state then
		print(`{player} stopped eating`)
		eating_sessions[player] = nil
		return false
	end

	const character = player.Character
	const humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
	if player.Parent ~= Players or character == nil or humanoid == nil or humanoid.Health <= 0 then
		return false
	end

	const session: eating_session = { character = character }
	eating_sessions[player] = session
	print(`{player} started eating`)
	task.wait(CAKE_EATING_DURATION)

	-- A cancelled request must not finish a later eating session.
	if eating_sessions[player] ~= session then
		return false
	end
	eating_sessions[player] = nil
	if player.Parent ~= Players or player.Character ~= session.character or humanoid.Health <= 0 then
		return false
	end
	humanoid.Health = 100
	return true
end

set_cake_state.OnServerInvoke = on_invoke
