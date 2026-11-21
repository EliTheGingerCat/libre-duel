const ReplicatedStorage = game:GetService("ReplicatedStorage")

const popup_types = require(ReplicatedStorage.shared.popup.popup_types)
const signal = require(ReplicatedStorage.Packages.signal)

type popup_params = popup_types.popup_params
type popup_text_input_values = popup_types.popup_text_input_values

-- button_index is nil when the popup was closed without pressing a button
export type on_popup_response = (button_index: number?, text_input_values: popup_text_input_values) -> ()

export type popup = {
	id: number,
	params: popup_params,
	on_response: on_popup_response?,
}

local current_id = 0
const existing_popups: { popup } = {}
const on_change = signal.new()

const function popup_add(params: popup_params, on_response: on_popup_response?): number
	current_id += 1

	table.insert(existing_popups, {
		id = current_id,
		params = params,
		on_response = on_response,
	})
	on_change:Fire()

	return current_id
end

const function popup_find(id: number): number?
	for index, popup in existing_popups do
		if popup.id == id then
			return index
		end
	end
	return nil
end

const function popup_respond(id: number, button_index: number?, text_input_values: popup_text_input_values): ()
	const index = popup_find(id)
	if index == nil then
		return
	end
	const popup = table.remove(existing_popups, index) :: popup
	on_change:Fire()

	if popup.on_response then
		popup.on_response(button_index, text_input_values)
	end
end

-- oldest first, a copy so callers cannot change the popups without firing on_change
const function popup_get_all(): { popup }
	return table.clone(existing_popups)
end

const popup_management = {
	add = popup_add,
	get_all = popup_get_all,
	on_change = on_change,
	respond = popup_respond,
}

return popup_management
