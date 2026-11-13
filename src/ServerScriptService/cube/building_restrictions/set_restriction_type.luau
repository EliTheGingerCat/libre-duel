const building_restriction_type = require(script.Parent.building_restriction_type)

const function set_restriction_type(restriction: building_restriction_type.restriction_types): ()
	building_restriction_type.current = restriction
end

return set_restriction_type
