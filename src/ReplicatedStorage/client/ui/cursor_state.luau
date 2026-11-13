-- Menus that need a free mouse cursor register here. The crosshair is the only code that writes the cursor state.
local free_reasons: { [string]: boolean } = {}

const function set_free(reason: string, free: boolean): ()
	free_reasons[reason] = if free then true else nil
end

const function is_free(): boolean
	return next(free_reasons) ~= nil
end

return {
	is_free = is_free,
	set_free = set_free,
}
