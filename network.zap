-- run `zap network.zap` after editing this!!!

-- do NOT edit the outputs by hand, edit this file
opt server_output = "src/ServerScriptService/network/zap_server_network.luau"
opt client_output = "src/ReplicatedStorage/client/network/zap_client_network.luau"
opt casing = "snake_case"
opt remote_scope = "LIBRE_DUEL"

-- Sad Mango: this file must be monolithic (zap doesn't let you split files up :/)
-- i did think of splitting it up and making a lune wrapper script to merge it all in one right before `zap network.zap` would be ran, sounds jank tho :(

type mode_stats = struct {
	wins: u32,
	goals: u32,
	kills: u32,
	losses: u32,
	deaths: u32,
}

type rank_point = struct {
	time: f64,
	rank: u32,
}

type action_result = struct {
	ok: boolean,
	error: string.binary?,
}

-- negative ids are studio test players, so this can't be an unsigned int
type user_id = f64

-- HttpService:GenerateGUID(false), the exact format is checked on the server
type guild_id = string.utf8(36)

------------------------------------------------------------------------------------------------------------------------
-- combat
------------------------------------------------------------------------------------------------------------------------

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

event knockback = {
	from: Server,
	type: Unreliable,
	call: SingleSync,
	data: (knockback_vector: Vector3, strength_x: f32, strength_y: f32),
}

-- the origin is the server's own eye position, so only the direction is sent
event shoot_bow = {
	from: Client,
	type: Reliable,
	call: SingleAsync,
	data: (direction: Vector3, draw_time: f32),
}

event update_blocking = {
	from: Client,
	type: Reliable,
	call: SingleAsync,
	data: boolean,
}

-- resolves with whether the cake got eaten, which only happens once the eating time has passed
funct set_cake_state = {
	call: Async,
	args: boolean,
	rets: boolean,
}

event mouse_click = {
	from: Client,
	type: Unreliable,
	call: SingleAsync,
	data: enum { attack, use },
}

------------------------------------------------------------------------------------------------------------------------
-- cubes
------------------------------------------------------------------------------------------------------------------------

-- the cell is worked out on the server from the aim, resolves once the server is done so the preview can go
funct place_cube = {
	call: Async,
	args: (origin: Vector3, direction: Vector3),
	rets: boolean,
}

-- the cube is nil when it was placed locally and doesn't exist on the server yet
event mine_cube = {
	from: Client,
	type: Reliable,
	call: SingleAsync,
	data: (mining_id: u32, cube: Instance.Part?, origin: Vector3, direction: Vector3),
}

event mine_stop = {
	from: Client,
	type: Reliable,
	call: SingleAsync,
	data: u32,
}

event mine_finished = {
	from: Server,
	type: Reliable,
	call: SingleSync,
	data: u32,
}

event mine_failed = {
	from: Server,
	type: Reliable,
	call: SingleSync,
	data: u32,
}

-- the cube can be nil when it hasn't replicated to this client yet
event mine_progress = {
	from: Server,
	type: Reliable,
	call: SingleSync,
	data: (cube: Instance.Part?, time_fraction: f32),
}

------------------------------------------------------------------------------------------------------------------------
-- inventory
------------------------------------------------------------------------------------------------------------------------

type inventory_action = enum { swap_items, move_item, quick_move }

-- the game uses the string "empty" for empty slots, which zap can't express next to a struct, so it gets converted
-- data is tool overrides, which can hold roblox enums that zap has no type for
type network_inventory_slot = enum "kind" {
	empty {},
	item {
		item_id: string.binary,
		amount: u16,
		data: unknown,
	},
}

type network_inventory = network_inventory_slot[..64]

event select_slot = {
	from: Client,
	type: Reliable,
	call: SingleAsync,
	data: u8,
}

event request_inventory_action = {
	from: Client,
	type: Reliable,
	call: SingleAsync,
	data: struct {
		action: inventory_action,
		from: u8,
		to: u8,
		id: u32,
	},
}

-- id is the request this answers, nil for server pushes, inventory is nil when it got deleted (e.g. on death)
event update_inventory = {
	from: Server,
	type: Reliable,
	call: SingleSync,
	data: struct {
		inventory: network_inventory?,
		id: u32?,
	},
}

-- target is nil when the player the request was made for already left
event request_invsee_action = {
	from: Client,
	type: Reliable,
	call: SingleAsync,
	data: struct {
		action: inventory_action,
		target: Instance.Player?,
		from: u8,
		to: u8,
		id: u32,
	},
}

event stop_invsee = {
	from: Client,
	type: Reliable,
	call: SingleAsync,
	data: (),
}

-- like update_inventory, target is nil once the session has ended
event update_invsee = {
	from: Server,
	type: Reliable,
	call: SingleSync,
	data: struct {
		target: Instance.Player?,
		inventory: network_inventory?,
		id: u32?,
	},
}

------------------------------------------------------------------------------------------------------------------------
-- match
------------------------------------------------------------------------------------------------------------------------

funct join_queue = {
	call: Async,
	args: string.utf8(..32),
	rets: boolean,
}

funct leave_queue = {
	call: Async,
	args: (),
	rets: boolean,
}

event game_is_active = {
	from: Server,
	type: Reliable,
	call: SingleSync,
	data: boolean,
}

event map_name = {
	from: Server,
	type: Reliable,
	call: ManySync,
	data: string.binary,
}

-- nothing fires this yet, the infoboard already listens for it
event kills = {
	from: Server,
	type: Reliable,
	call: ManySync,
	data: u16,
}

event score_self = {
	from: Server,
	type: Reliable,
	call: ManySync,
	data: (),
}

event score_team = {
	from: Server,
	type: Reliable,
	call: ManySync,
	data: u8,
}

------------------------------------------------------------------------------------------------------------------------
-- ui
------------------------------------------------------------------------------------------------------------------------

event send_notification = {
	from: Server,
	type: Reliable,
	call: SingleSync,
	data: string.binary,
}

event show_title = {
	from: Server,
	type: Reliable,
	call: ManySync,
	data: (
		fade_in: f32,
		stay: f32,
		fade_out: f32,
		top_text: string.binary,
		bottom_text: string.binary?,
		colour: Color3?,
	),
}

event send_popup = {
	from: Server,
	type: Reliable,
	call: SingleSync,
	data: (
		popup_id: u32,
		params: struct {
			icon: string.binary,
			text: string.binary,
			text_inputs: struct {
				id: string.binary,
				placeholder_text: string.binary,
			}[]?,
			buttons: struct {
				text: string.binary,
				colour: Color3,
				button_progress_time: f32?,
			}[]?,
		},
	),
}

-- button_index is nil when the popup was closed without pressing a button
-- the value limit is POPUP_TEXT_INPUT_MAX_LENGTH from shared/popup, the client cuts the text to it before sending
event respond_to_popup = {
	from: Client,
	type: Reliable,
	call: SingleAsync,
	data: (
		popup_id: u32,
		button_index: u8?,
		text_input_values: map { [string.utf8(..200)]: string.utf8(..200) },
	),
}

event send_large_notification = {
	from: Server,
	type: Reliable,
	call: SingleSync,
	data: (
		large_notification_id: u32,
		params: struct {
			icon: string.binary,
			text: string.binary,
			buttons: struct {
				text: string.binary,
				text_colour: Color3,
			}[]?,
		},
	),
}

-- button_index is nil when the notification was closed without pressing a button
event respond_to_large_notification = {
	from: Client,
	type: Reliable,
	call: SingleAsync,
	data: (large_notification_id: u32, button_index: u8?),
}

event play_sound = {
	from: Server,
	type: Reliable,
	call: SingleSync,
	data: (name: string.binary, position: Vector3),
}

funct server_location = {
	call: Async,
	args: (),
	rets: enum "status" {
		loading {},
		fail {},
		success {
			result: string.binary,
		},
	},
}

------------------------------------------------------------------------------------------------------------------------
-- debug
------------------------------------------------------------------------------------------------------------------------

event ping = {
	from: Client,
	type: Reliable,
	call: SingleAsync,
	data: (),
}

event pong = {
	from: Server,
	type: Reliable,
	call: SingleSync,
	data: (),
}

event debug_server = {
	from: Client,
	type: Reliable,
	call: SingleAsync,
	data: (),
}

------------------------------------------------------------------------------------------------------------------------
-- guild
------------------------------------------------------------------------------------------------------------------------

type guild_snapshot = struct {
	id: string.binary,
	owner_id: f64,
	created: f64,
	name: string.binary,
	tag: string.binary,
	description: string.binary,
	icon: string.binary,
	banner: string.binary,
	discord_invite: string.binary,
	members: struct {
		user_id: f64,
		joined: f64,
		banner: string.binary,
		playtime: f64,
		stats: map { [string.utf8(..32)]: mode_stats },
	}[],
	banned: struct {
		user_id: f64,
		banned_at: f64,
	}[],
	outgoing_invites: struct {
		user_id: f64,
		invited_at: f64,
	}[],
	totals: map { [string.utf8(..32)]: mode_stats },
	total_playtime: f64,
	rank: u32?,
	rank_history: rank_point[],
}

-- the limit is MAX_DESCRIPTION_LENGTH from shared/guild/GUILD_LIMITS, the server checks the real limit of each field
type guild_info_input = struct {
	name: string.utf8(..10000),
	tag: string.utf8(..10000),
	description: string.utf8(..10000),
	icon: string.utf8(..10000),
	banner: string.utf8(..10000),
	discord_invite: string.utf8(..10000),
}

type guild_info_changes = struct {
	name: string.utf8(..10000)?,
	tag: string.utf8(..10000)?,
	description: string.utf8(..10000)?,
	icon: string.utf8(..10000)?,
	banner: string.utf8(..10000)?,
	discord_invite: string.utf8(..10000)?,
}

event guild_state = {
	from: Server,
	type: Reliable,
	call: SingleSync,
	data: guild_snapshot?,
}

event incoming_guild_invites = {
	from: Server,
	type: Reliable,
	call: SingleSync,
	data: struct {
		guild_id: string.binary,
		guild_name: string.binary,
		guild_tag: string.binary,
		guild_icon: string.binary,
		guild_banner: string.binary,
		member_count: u32,
		inviter_id: f64,
		invited_at: f64,
	}[],
}

funct create_guild = {
	call: Async,
	args: guild_info_input,
	rets: action_result,
}

funct edit_guild_info = {
	call: Async,
	args: guild_info_changes,
	rets: action_result,
}

-- only asks for a confirmation popup, nothing gets deleted yet
funct delete_guild = {
	call: Async,
	args: (),
	rets: action_result,
}

funct request_guild_image_change = {
	call: Async,
	args: enum { icon, banner },
	rets: action_result,
}

funct leave_guild = {
	call: Async,
	args: (),
	rets: action_result,
}

funct invite_to_guild = {
	call: Async,
	args: user_id,
	rets: action_result,
}

funct cancel_guild_invite = {
	call: Async,
	args: user_id,
	rets: action_result,
}

funct kick_guild_member = {
	call: Async,
	args: user_id,
	rets: action_result,
}

funct ban_guild_member = {
	call: Async,
	args: user_id,
	rets: action_result,
}

funct unban_guild_member = {
	call: Async,
	args: user_id,
	rets: action_result,
}

funct accept_guild_invite = {
	call: Async,
	args: guild_id,
	rets: action_result,
}

funct decline_guild_invite = {
	call: Async,
	args: guild_id,
	rets: action_result,
}

-- nil when rate limited
funct search_guild_invite_candidate = {
	call: Async,
	args: string.utf8(..10000),
	rets: struct {
		user_id: f64,
		username: string.binary,
		display_name: string.binary,
	}[]?,
}

-- nil when rate limited or the guild doesn't exist
funct fetch_guild_info = {
	call: Async,
	args: guild_id,
	rets: guild_snapshot?,
}

------------------------------------------------------------------------------------------------------------------------
-- player profile
------------------------------------------------------------------------------------------------------------------------

-- nil when rate limited or the player never played
funct fetch_player_profile = {
	call: Async,
	args: user_id,
	rets: struct {
		user_id: f64,
		first_joined: f64,
		last_online: f64,
		banner: string.binary,
		bio: string.binary,
		playtime: f64,
		stats: map { [string.utf8(..32)]: mode_stats },
		rank: u32?,
		rank_history: rank_point[],
		guild: struct {
			id: string.binary,
			name: string.binary,
			tag: string.binary,
		}?,
	}?,
}

-- the limit is MAX_BIO_LENGTH from shared/player_profile/PLAYER_PROFILE_LIMITS
funct edit_player_bio = {
	call: Async,
	args: string.utf8(..2000),
	rets: action_result,
}

funct request_player_banner_change = {
	call: Async,
	args: (),
	rets: action_result,
}

funct report_player = {
	call: Async,
	args: user_id,
	rets: action_result,
}

-- tells the player their own profile changed so an open profile menu fetches it again
event player_profile_changed = {
	from: Server,
	type: Reliable,
	call: ManySync,
	data: (),
}
