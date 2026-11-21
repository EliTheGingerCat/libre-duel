const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Signal = require(ReplicatedStorage.Packages.signal)

const camera_view_state = { third_person = false, changed = Signal.new() }

const function set_third_person(third_person: boolean): ()
	if camera_view_state.third_person == third_person then
		return
	end
	camera_view_state.third_person = third_person
	camera_view_state.changed:Fire(third_person)
end

camera_view_state.set_third_person = set_third_person

return camera_view_state
