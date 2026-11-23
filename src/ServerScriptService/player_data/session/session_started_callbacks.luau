export type session_started_callback = (player: Player) -> ()

const session_started_callbacks: { session_started_callback } = {}

return session_started_callbacks
