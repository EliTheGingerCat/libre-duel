const ServerScriptService = game:GetService("ServerScriptService")
const drop = require(ServerScriptService.ServerPackages.drop)
const player_store = require(ServerScriptService.player_data.player_store)

const function initialize_player_data(player): ()
    const data = drop.view(player_store, player)
    print(data)
    if data.first_joined == 0 then
        data.first_joined = os.clock()
    end
end

return initialize_player_data
