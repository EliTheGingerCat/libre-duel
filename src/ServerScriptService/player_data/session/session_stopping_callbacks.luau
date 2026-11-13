export type session_stopping_callback = (player: Player) -> ()

const session_stopping_callbacks: { session_stopping_callback } = {}

return session_stopping_callbacks
