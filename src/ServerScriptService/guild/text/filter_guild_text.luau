const TextService = game:GetService("TextService")

-- yields, nil when filtering failed, in which case the text must not be shown to anyone
const function filter_guild_text(author: Player, text: string): string?
	if text == "" then
		return ""
	end
	const ok, result =
		pcall(TextService.FilterStringAsync, TextService, text, author.UserId, Enum.TextFilterContext.PublicChat)
	if not ok then
		warn(`Could not filter guild text: {result}`)
		return nil
	end
	const broadcast_ok, filtered = pcall(result.GetNonChatStringForBroadcastAsync, result)
	if not broadcast_ok then
		warn(`Could not filter guild text: {filtered}`)
		return nil
	end
	return filtered
end

return filter_guild_text
