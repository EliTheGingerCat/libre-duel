const MarketplaceService = game:GetService("MarketplaceService")

const IMAGE_ASSET_TYPE_ID = 1

-- yields, true for "" (no image) and for real image assets
-- decal ids are rejected since they don't render in an ImageLabel, the image id behind the decal has to be used
-- this does not moderate the image, Roblox moderation of the upload is all we get
const function validate_guild_asset(asset: string): boolean
	if asset == "" then
		return true
	end
	const asset_id = tonumber(string.match(asset, "^rbxassetid://(%d+)$"))
	if asset_id == nil then
		return false
	end
	const ok, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, asset_id, Enum.InfoType.Asset)
	return ok and info.AssetTypeId == IMAGE_ASSET_TYPE_ID
end

return validate_guild_asset
