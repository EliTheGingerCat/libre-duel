const ReplicatedStorage = game:GetService("ReplicatedStorage")

const guild_state = require(script.Parent.guild_state)
const zap_client_network = require(ReplicatedStorage.client.network.zap_client_network)

zap_client_network.guild_state.set_callback(guild_state.set_guild)
zap_client_network.incoming_guild_invites.set_callback(guild_state.set_incoming_invites)
