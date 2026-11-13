-- whether the play button is on screen and pressable, so its gamepad glyph only shows when it does something
const play_button_state = {
	available = false,
}

const function set_available(available: boolean): ()
	play_button_state.available = available
end

play_button_state.set_available = set_available

return play_button_state
