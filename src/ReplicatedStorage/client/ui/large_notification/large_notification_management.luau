const ReplicatedStorage = game:GetService("ReplicatedStorage")

const large_notification_types = require(ReplicatedStorage.shared.large_notification.large_notification_types)
const signal = require(ReplicatedStorage.Packages.signal)

type large_notification_params = large_notification_types.large_notification_params

-- button_index is nil when the notification was closed without pressing a button
export type on_large_notification_response = (button_index: number?) -> ()

export type large_notification = {
	id: number,
	params: large_notification_params,
	on_response: on_large_notification_response?,
}

local current_id = 0
const existing_large_notifications: { large_notification } = {}
const on_change = signal.new()

const function large_notification_add(
	params: large_notification_params,
	on_response: on_large_notification_response?
): number
	current_id += 1

	table.insert(existing_large_notifications, {
		id = current_id,
		params = params,
		on_response = on_response,
	})
	on_change:Fire()

	return current_id
end

const function large_notification_find(id: number): number?
	for index, large_notification in existing_large_notifications do
		if large_notification.id == id then
			return index
		end
	end
	return nil
end

const function large_notification_respond(id: number, button_index: number?): ()
	const index = large_notification_find(id)
	if index == nil then
		return
	end
	const large_notification = table.remove(existing_large_notifications, index) :: large_notification
	on_change:Fire()

	if large_notification.on_response then
		large_notification.on_response(button_index)
	end
end

-- a copy, so callers cannot change the notifications without firing on_change
const function large_notification_get_all(): { large_notification }
	return table.clone(existing_large_notifications)
end

const large_notification_management = {
	add = large_notification_add,
	get_all = large_notification_get_all,
	on_change = on_change,
	respond = large_notification_respond,
}

return large_notification_management
