const LAG_COMPENSATION_CONSTANTS = {
	-- hard cap on how far back a target can be rewound, players laggier than this just get less help
	-- this is also the most a client can backtrack by lying about what it saw
	maximum_rewind_seconds = 0.35,
	-- room for chrono's interpolation buffer on top of the round trip
	interpolation_buffer_allowance_seconds = 0.15,
}

return LAG_COMPENSATION_CONSTANTS
