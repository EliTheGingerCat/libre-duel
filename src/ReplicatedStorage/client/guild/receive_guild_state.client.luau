const ReplicatedStorage = game:GetService("ReplicatedStorage")

const guild_state = require(script.Parent.guild_state)

const guild_remotes = ReplicatedStorage.remotes.guild

guild_remotes.guild_state.OnClientEvent:Connect(guild_state.set_guild)
guild_remotes.incoming_guild_invites.OnClientEvent:Connect(guild_state.set_incoming_invites)
