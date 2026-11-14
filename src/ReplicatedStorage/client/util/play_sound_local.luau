
const SOUNDS = {
	cube_place = { 85161431209506, 81267447775418, }, --multiple sounds can be added for variety
	player_blocked_hit = { 123708037954860, },
	player_damaged = { 100142736511056, 134987476311578, 117153113208513, },
	item_pickup = { 130630772203993, },
	block_mined = { 82317605097458, 87539576563962, },
	arrow_flyby = { 136641423349108, },
}

const function play_sound_local(name: string, position: Vector3): ()
	local list = SOUNDS[name]
	assert(list, `Sound list "{name}" was not found.`)

	local id = list[math.random(1, #list)]
	assert(id, `No ids were found in sound list "{name}".`)

	local part = Instance.new("Part")
	part.Position = position

	local sound = Instance.new("Sound")
	sound.PlayOnRemove = true
	sound.SoundId = `rbxassetid://{id}`
	sound.Parent = part

	part.Parent = workspace

	part:Destroy()
end

return play_sound_local
