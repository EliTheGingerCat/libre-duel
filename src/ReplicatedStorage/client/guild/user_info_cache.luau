const ReplicatedStorage = game:GetService("ReplicatedStorage")
const UserService = game:GetService("UserService")

const Signal = require(ReplicatedStorage.Packages.signal)

export type user_info = { username: string, display_name: string }

const loaded = Signal.new()
const cached_infos: { [number]: user_info } = {}
const requested_ids: { [number]: true } = {}

const function fetch(user_ids: { number }): ()
	const ok, infos = pcall(UserService.GetUserInfosByUserIdsAsync, UserService, user_ids)
	if not ok then
		-- let a later call try again
		for _, user_id in user_ids do
			requested_ids[user_id] = nil
		end
		return
	end
	for _, info in infos do
		cached_infos[info.Id] = { username = info.Username, display_name = info.DisplayName }
	end
	loaded:Fire()
end

-- never yields, unknown ids get fetched in the background and nil is returned until they arrive
const function get(user_id: number): user_info?
	return cached_infos[user_id]
end

const function request(user_ids: { number }): ()
	const missing = {}
	for _, user_id in user_ids do
		if cached_infos[user_id] == nil and not requested_ids[user_id] then
			requested_ids[user_id] = true
			table.insert(missing, user_id)
		end
	end
	if #missing > 0 then
		task.spawn(fetch, missing)
	end
end

-- seeds the cache from data that already came with names, like search results
const function remember(user_id: number, info: user_info): ()
	cached_infos[user_id] = info
end

const function subscribe(callback: () -> ()): () -> ()
	const connection = loaded:Connect(callback)
	const function disconnect(): ()
		connection:Disconnect()
	end
	return disconnect
end

return {
	get = get,
	request = request,
	remember = remember,
	subscribe = subscribe,
}
