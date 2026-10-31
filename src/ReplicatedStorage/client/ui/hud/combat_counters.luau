local players = game:GetService("Players")
local replicated_storage = game:GetService("ReplicatedStorage")

local hit_feedback = require(replicated_storage.client.combat.hit_feedback)

local local_player = players.LocalPlayer

local combo = 0
local reach = 0
local listeners: { (number, number) -> () } = {}
local disconnect_tracking: (() -> ())? = nil

local function notify(): ()
	for _, callback in table.clone(listeners) do
		callback(combo, reach)
	end
end

local function track_character()
	local health_connection: RBXScriptConnection? = nil
	local child_connection: RBXScriptConnection? = nil

	local function reset_combo(): ()
		combo = 0
		notify()
	end

	local function reset_counters(): ()
		reach = 0
		reset_combo()
	end

	local function on_hit(distance: number): ()
		combo += 1
		reach = distance
		notify()
	end

	local function detach_character(): ()
		if health_connection then
			health_connection:Disconnect()
			health_connection = nil
		end
		if child_connection then
			child_connection:Disconnect()
			child_connection = nil
		end
	end

	local function on_character_added(character: Model): ()
		detach_character()
		reset_counters()

		local function watch_humanoid(child: Instance): ()
			if not child:IsA("Humanoid") or health_connection then
				return
			end
			local previous_health = child.Health
			local function on_health_changed(health: number): ()
				if health < previous_health then
					reset_combo()
				end
				previous_health = health
			end
			health_connection = child.HealthChanged:Connect(on_health_changed)
		end

		child_connection = character.ChildAdded:Connect(watch_humanoid)
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			watch_humanoid(humanoid)
		end
	end

	local function on_character_removing(): ()
		detach_character()
		reset_counters()
	end

	reset_counters()
	local disconnect_hit = hit_feedback.subscribe(on_hit)
	local added_connection = local_player.CharacterAdded:Connect(on_character_added)
	local removing_connection = local_player.CharacterRemoving:Connect(on_character_removing)
	if local_player.Character then
		on_character_added(local_player.Character)
	end

	local function disconnect(): ()
		detach_character()
		disconnect_hit()
		added_connection:Disconnect()
		removing_connection:Disconnect()
	end

	return disconnect
end

local function subscribe(callback: (number, number) -> ())
	table.insert(listeners, callback)
	if disconnect_tracking then
		callback(combo, reach)
	else
		disconnect_tracking = track_character()
	end
	local active = true
	local function disconnect(): ()
		if not active then
			return
		end
		active = false
		local index = table.find(listeners, callback)
		if index then
			table.remove(listeners, index)
		end
		if #listeners == 0 and disconnect_tracking then
			disconnect_tracking()
			disconnect_tracking = nil
		end
	end
	return disconnect
end

return { subscribe = subscribe }
