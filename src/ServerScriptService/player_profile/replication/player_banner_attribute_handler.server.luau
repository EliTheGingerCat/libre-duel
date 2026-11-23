const ServerScriptService = game:GetService("ServerScriptService")

const get_cached_player_data = require(ServerScriptService.player_data.get_cached_player_data)
const on_session_started = require(ServerScriptService.player_data.session.on_session_started)
const set_player_banner_attribute = require(script.Parent.set_player_banner_attribute)

const function publish_banner(player: Player): ()
	const data = get_cached_player_data(player)
	if data then
		set_player_banner_attribute(player, data.player_banner_id)
	end
end

on_session_started(publish_banner)
