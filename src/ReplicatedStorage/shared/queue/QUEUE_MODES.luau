export type mode = "solo" | "duo"

-- The single source of truth for queue modes, in the order they are shown to players.
const QUEUE_MODES: { mode } = {
	"solo",
	"duo",
}

return QUEUE_MODES
