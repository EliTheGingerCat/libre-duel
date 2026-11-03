const QUEUE_CONFIG = {
	map_prefix = "queue",
	ready_topic = "queue_ready",
	shards = 1,
	candidates_per_shard = 25,
	scan_pages_per_shard = 4,
	entry_lifetime = 90,
	slot_lifetime = 45,
	heartbeat_interval = 10,
	poll_interval = 2,
	arrival_timeout = 90,
	teleport_attempts = 3,
	join_interval = 2,
	modes = {
		solo = { teams = 2, entities_per_team = 1 },
		duo = { teams = 2, entities_per_team = 2 },
	},
}

return QUEUE_CONFIG
