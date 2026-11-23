export type info_field = {
	id: string,
	label: string,
	value: string,
	-- makes the value a link, like a guild name that opens the guild
	on_activated: (() -> ())?,
}
export type stat = { id: string, icon: string, label: string, value: string }
-- a stat shown big and coloured, for the few numbers worth showing off
export type highlight_stat = { id: string, icon: string?, label: string, value: string, colour: Color3? }
-- unix seconds, rank 1 is the best
export type rank_point = { time: number, rank: number }
export type stat_group = { id: string, title: string, stats: { stat } }
-- a titled group of numbers on a stats page
export type stat_section = {
	id: string,
	title: string,
	title_colour: Color3?,
	stats: { highlight_stat },
}

return {}
