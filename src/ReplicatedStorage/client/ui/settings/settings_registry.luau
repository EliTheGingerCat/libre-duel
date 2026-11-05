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

local function register_category(category: category): ()
	for _, existing in categories do
		assert(existing.id ~= category.id, "Duplicate settings category: " .. category.id)
	end
	table.insert(categories, category)
	changed:Fire()
end

local function register(entry: entry)
	assert(not by_id[entry.id], "Duplicate setting: " .. entry.id)
	local found = false
	for _, category in categories do
		if category.id == entry.category then
			found = true
			break
		end
	end
	assert(found, "Unknown settings category: " .. entry.category)
	local default = settings_value.default(entry)
	if default ~= nil then
		settings_value.validate(entry, default)
	end
	by_id[entry.id] = entry
	values[entry.id] = default
	table.insert(entries, entry)
	changed:Fire()
	local function unregister(): ()
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

local function get(id: string): value?
	return values[id]
end

local function set(id: string, value: value): ()
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

local function is_visible(entry: entry): boolean
	local visible = entry.visible :: (() -> boolean)?
	return visible == nil or visible()
end

-- For settings whose visibility depends on something outside the registry.
local function refresh(): ()
	changed:Fire()
end

local function subscribe(callback: () -> ())
	local connection = changed:Connect(callback)
	local function disconnect(): ()
		connection:Disconnect()
	end
	return disconnect
end

return {
	categories = categories,
	entries = entries,
	get = get,
	is_visible = is_visible,
	refresh = refresh,
	register = register,
	register_category = register_category,
	set = set,
	subscribe = subscribe,
}
