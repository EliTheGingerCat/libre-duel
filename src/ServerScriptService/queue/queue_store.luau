const MemoryStoreService = game:GetService("MemoryStoreService")

const QUEUE_CONFIG = require(script.Parent.QUEUE_CONFIG)
const queue_record = require(script.Parent.queue_record)

type record = queue_record.record
type mode = queue_record.mode
export type result = { ok: boolean, entry: record? }
export type transform = (record?) -> record?

const handles: { [string]: MemoryStoreSortedMap? } = {}

local function get_map(mode: mode, shard: number): MemoryStoreSortedMap
	const name = `{QUEUE_CONFIG.map_prefix}_{mode}_s{shard}`
	const existing = handles[name]
	if existing then
		return existing
	end
	const map = MemoryStoreService:GetSortedMap(name)
	handles[name] = map
	return map
end

local function get_shard(id: string): number
	local hash = 0
	for index = 1, #id do
		hash = (hash * 31 + string.byte(id, index)) % QUEUE_CONFIG.shards
	end
	return hash + 1
end

local function get(mode: mode, id: string): result
	const map = get_map(mode, get_shard(id))
	const ok, value = pcall(map.GetAsync, map, id)
	const entry = queue_record.decode(value)
	return { ok = ok, entry = if entry and entry.id == id and entry.mode == mode then entry else nil }
end

local function update(mode: mode, id: string, transform: transform): result
	const map = get_map(mode, get_shard(id))
	local function on_update(value: unknown): record?
		const entry = queue_record.decode(value)
		if value ~= nil and (entry == nil or entry.mode ~= mode or entry.id ~= id) then
			return nil
		end
		return transform(entry)
	end
	const ok, value = pcall(map.UpdateAsync, map, id, on_update, QUEUE_CONFIG.entry_lifetime)
	return { ok = ok, entry = queue_record.decode(value) }
end

local function fuller_first(left: record, right: record): boolean
	return queue_record.count_members(left) > queue_record.count_members(right)
end

local function find(mode: mode): { ok: boolean, entries: { record } }
	const entries: { record } = {}
	for shard = 1, QUEUE_CONFIG.shards do
		const map = get_map(mode, shard)
		local lower_bound: { key: string, sortKey: unknown }? = nil
		local candidates = 0
		-- Closed entries stay briefly for arrival validation and must not hide the next page.
		for _ = 1, QUEUE_CONFIG.scan_pages_per_shard do
			const ok, items = pcall(
				map.GetRangeAsync,
				map,
				Enum.SortDirection.Ascending,
				QUEUE_CONFIG.candidates_per_shard,
				lower_bound
			)
			if not ok then
				return { ok = false, entries = {} }
			end
			for _, item in items do
				const entry = queue_record.decode(item.value)
				if entry and entry.mode == mode and entry.id == item.key and entry.matchmaking_type == game.MatchmakingType.Value then
					queue_record.prune(entry, os.time())
					if entry.status == "waiting" then
						table.insert(entries, entry)
						candidates += 1
					end
				end
			end
			if #items < QUEUE_CONFIG.candidates_per_shard or candidates >= QUEUE_CONFIG.candidates_per_shard then
				break
			end
			const last = items[#items]
			lower_bound = { key = last.key, sortKey = last.sortKey }
		end
	end
	table.sort(entries, fuller_first)
	return { ok = true, entries = entries }
end

local function release(mode: mode, id: string, user_id: number, token: string): ()
	local function remove_member(entry: record?): record?
		if entry then
			queue_record.release(entry, user_id, token)
		end
		return entry
	end
	update(mode, id, remove_member)
end

return {
	find = find,
	get = get,
	release = release,
	update = update,
}
