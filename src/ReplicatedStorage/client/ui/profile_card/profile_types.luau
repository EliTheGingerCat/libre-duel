export type info_field = { id: string, label: string, value: string }
export type stat = { id: string, icon: string, label: string, value: string }
-- a stat shown big and coloured, for the few numbers worth showing off
export type highlight_stat = { id: string, icon: string?, label: string, value: string, colour: Color3? }
-- unix seconds, rank 1 is the best
export type rank_point = { time: number, rank: number }
export type stat_group = { id: string, title: string, stats: { stat } }

return {}
