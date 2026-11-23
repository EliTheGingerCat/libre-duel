const TextService = game:GetService("TextService")

-- yields, nil when filtering failed, in which case the text must not be shown to anyone
const function filter_text(author: Player, text: string): string?
	if text == "" then
		return ""
	end
	const ok, result =
		pcall(TextService.FilterStringAsync, TextService, text, author.UserId, Enum.TextFilterContext.PublicChat)
	if not ok then
		warn(`Could not filter text: {result}`)
		return nil
	end
	const broadcast_ok, filtered = pcall(result.GetNonChatStringForBroadcastAsync, result)
	if not broadcast_ok then
		warn(`Could not filter text: {filtered}`)
		return nil
	end
	return filtered
end

return filter_text
