-- run `zap network.zap` after editing this!!!

-- do NOT edit the outputs by hand, edit this
opt server_output = "src/ServerScriptService/network/zap_server_network.luau"
opt client_output = "src/ReplicatedStorage/client/network/zap_client_network.luau"
opt casing = "snake_case"
opt remote_scope = "LIBRE_DUEL"

-- the client only says where it aimed and when it was seeing everyone, what got hit is decided on the server (welcome to game security brother 💀)
event melee_swing = {
	from: Client,
	type: Reliable,
	call: SingleSync,
	data: struct {
		origin: Vector3,
		direction: Vector3,
		render_times: struct {
			player: Instance.Player?,
			time: f64,
		}[..32],
	},
}
