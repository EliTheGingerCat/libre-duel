const ReplicatedStorage = game:GetService("ReplicatedStorage")

const PLAYER_BANNER_ATTRIBUTE = require(ReplicatedStorage.shared.player_profile.PLAYER_BANNER_ATTRIBUTE)

const function set_player_banner_attribute(player: Player, banner: string): ()
	player:SetAttribute(PLAYER_BANNER_ATTRIBUTE, banner)
end

return set_player_banner_attribute
