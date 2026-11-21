const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const pending_popups = require(script.Parent.pending_popups)
const sanitise_popup_text_input_values = require(script.Parent.sanitise_popup_text_input_values)

const respond_to_popup = ReplicatedStorage.remotes.respond_to_popup

const function is_valid_button_index(button_index: unknown, button_count: number): boolean
	return type(button_index) == "number"
		and button_index % 1 == 0
		and button_index >= 1
		and button_index <= button_count
end

-- button_index is nil when the player closed the popup without pressing a button
const function on_response(player: Player, id: unknown, button_index: unknown, text_input_values: unknown): ()
	if type(id) ~= "number" then
		return
	end
	const pending_popup = pending_popups[id]
	if pending_popup == nil or pending_popup.player ~= player then
		return
	end
	pending_popups[id] = nil

	const on_button_pressed = pending_popup.on_button_pressed
	if on_button_pressed == nil or not is_valid_button_index(button_index, pending_popup.button_count) then
		return
	end
	const sanitised_values = sanitise_popup_text_input_values(text_input_values, pending_popup.text_input_ids)
	-- spawned so an erroring callback cannot break the handler
	task.spawn(on_button_pressed, player, button_index :: number, sanitised_values)
end

const function on_player_removing(player: Player): ()
	for id, pending_popup in pending_popups do
		if pending_popup.player == player then
			pending_popups[id] = nil
		end
	end
end

respond_to_popup.OnServerEvent:Connect(on_response)
Players.PlayerRemoving:Connect(on_player_removing)
