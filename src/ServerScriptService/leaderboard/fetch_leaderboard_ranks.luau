const PAGE_SIZE = 100

-- pages through the top of an OrderedDataStore, highest score first, nil when any read fails so a half read never replaces good ranks
-- keys past max_rank are left out, OrderedDataStore can't tell us more without paging forever
const function fetch_leaderboard_ranks(store: OrderedDataStore, max_rank: number): { [string]: number }?
	const ok, pages = pcall(store.GetSortedAsync, store, false, PAGE_SIZE)
	if not ok then
		warn(`Could not read {store.Name} ranks: {pages}`)
		return nil
	end
	const ranks: { [string]: number } = {}
	local rank = 0
	while true do
		for _, entry in pages:GetCurrentPage() do
			rank += 1
			ranks[entry.key] = rank
		end
		if pages.IsFinished or rank >= max_rank then
			return ranks
		end
		const advanced, message = pcall(pages.AdvanceToNextPageAsync, pages)
		if not advanced then
			warn(`Could not read {store.Name} ranks: {message}`)
			return nil
		end
	end
end

return fetch_leaderboard_ranks
