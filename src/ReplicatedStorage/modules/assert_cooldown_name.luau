local allowed_names = {
	"attack_melee", "attack_melee_mitigation",
	"place_cube", "place_cube_mitigation",
}

local function assert_cooldown_name(name: string): ()
	assert(table.find(allowed_names, name) ~= nil, `Name "{name}" is not a valid cooldown name.`)
end

return assert_cooldown_name
