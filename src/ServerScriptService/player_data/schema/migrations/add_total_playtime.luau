const ServerScriptService = game:GetService("ServerScriptService")

const add_total_playtime = require(ServerScriptService.player_data.schema.migrations.add_total_playtime)

export type with_player_banner = add_total_playtime.with_total_playtime & {
	equipped_banner: string,
}

const function add_player_banners(data: add_total_playtime.with_total_playtime): with_player_banner
	const new_data = table.clone(data) :: with_player_banner
	new_data.equipped_banner = "default"
	return new_data
end

return add_player_banners
