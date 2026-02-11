local ReplicatedStorage = game:GetService("ReplicatedStorage")

local signal = require(ReplicatedStorage.vendor.signal)

export type notification = {
	id: number,
	message: string,
	created_at: number,
}

local current_id = 0
local existing_notifications: {notification} = {}
local on_change = signal.new()

local function notification_add(message: string): ()
	current_id += 1
	
	local new_notification: notification = {
		id = current_id,
		message = message,
		created_at = tick(),
	}

	table.insert(existing_notifications, new_notification)
	on_change:Fire()
end

local function notification_find(id: number): number?
	for index, notification in existing_notifications do
		if notification.id == id then
			return index
		end
	end
	return nil
end

local function notification_remove(id: number): ()
	local index = notification_find(id)
	assert(index ~= nil, `Could not find index of notification of id {id}.`)
	table.remove(existing_notifications, index)
	on_change:Fire()
end

local notification_management = {
	add = notification_add,
	on_change = on_change,
	existing = existing_notifications,
	remove = notification_remove,
}

return notification_management
