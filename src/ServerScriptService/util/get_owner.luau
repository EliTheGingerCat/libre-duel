const MarketplaceService = game:GetService("MarketplaceService")
const GroupService = game:GetService("GroupService")
const Players = game:GetService("Players")

const place_info = MarketplaceService:GetProductInfo(game.PlaceId)

const function get_owner(return_type: "username" | "userid"): number | string
    if game.CreatorType == Enum.CreatorType.Group then
        local group_info = GroupService:GetGroupInfoAsync(place_info.Creator.CreatorTargetId)
        local group_owner_id = group_info.Owner.Id
        if return_type == "username" then
            return Players:GetNameFromUserIdAsync(group_owner_id)
        else
            return group_owner_id
        end
    else
        if return_type == "username" then
            return Players:GetNameFromUserIdAsync(game.CreatorId)
        else
            return game.CreatorId
        end
    end
end

return get_owner
