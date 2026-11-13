local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.signal)

local settings_types = require(script.Parent.settings_types)
local settings_value = require(script.Parent.settings_value)

export type category = settings_types.category
export type entry = settings_types.entry
export type value = settings_types.value

local changed = Signal.new()
local categories: { category } = {}
local entries: { entry } = {}
local values: { [string]: value? } = {}
local by_id: { [string]: entry } = {}

const function register_category(category: category): ()
	for _, existing in categories do
		assert(existing.id ~= category.id, "Duplicate settings category: " .. category.id)
	end
	table.insert(categories, category)
	changed:Fire()
end

const function register(entry: entry)
	assert(not by_id[entry.id], "Duplicate setting: " .. entry.id)
	local found = false
	for _, category in categories do
		if category.id == entry.category then
			found = true
			break
		end
	end
	assert(found, "Unknown settings category: " .. entry.category)
	local parent = entry.parent :: string?
	assert(parent == nil or by_id[parent], "Unknown parent setting for: " .. entry.id)
	local default = settings_value.default(entry)
	if default ~= nil then
		settings_value.validate(entry, default)
	end
	by_id[entry.id] = entry
	values[entry.id] = default
	table.insert(entries, entry)
	changed:Fire()
	const function unregister(): ()
		local index = table.find(entries, entry)
		if not index then
			return
		end
		table.remove(entries, index)
		by_id[entry.id] = nil
		values[entry.id] = nil
		changed:Fire()
	end
	return unregister
end

const function get(id: string): value?
	return values[id]
end

const function set(id: string, value: value): ()
	local entry = by_id[id]
	assert(entry, "Unknown setting: " .. id)
	settings_value.validate(entry, value)
	if values[id] == value then
		return
	end
	values[id] = value
	settings_value.changed(entry, value)
	changed:Fire()
end

const function is_visible(entry: entry): boolean
	local visible = entry.visible :: (() -> boolean)?
	return visible == nil or visible()
end

const function get_children(id: string): { entry }
	local children = {}
	for _, entry in entries do
		if (entry.parent :: string?) == id then
			table.insert(children, entry)
		end
	end
	return children
end

-- For settings whose visibility depends on something outside the registry.
const function refresh(): ()
	changed:Fire()
end

const function subscribe(callback: () -> ())
	local connection = changed:Connect(callback)
	const function disconnect(): ()
		connection:Disconnect()
	end
	return disconnect
end

return {
	categories = categories,
	entries = entries,
	get = get,
	get_children = get_children,
	is_visible = is_visible,
	refresh = refresh,
	register = register,
	register_category = register_category,
	set = set,
	subscribe = subscribe,
}
