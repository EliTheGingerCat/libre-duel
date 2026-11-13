local settings_types = require(script.Parent.settings_types)

const function default(entry: settings_types.entry): settings_types.value?
	if
		entry.kind == "switch"
		or entry.kind == "checkbox"
		or entry.kind == "text"
		or entry.kind == "dropdown"
		or entry.kind == "slider"
		or entry.kind == "colour"
	then
		return entry.default
	end
	return nil
end

const function validate(entry: settings_types.entry, value: settings_types.value): ()
	if entry.kind == "switch" or entry.kind == "checkbox" then
		assert(typeof(value) == "boolean", "Expected a boolean for " .. entry.id)
	elseif entry.kind == "text" or entry.kind == "dropdown" then
		assert(typeof(value) == "string", "Expected text for " .. entry.id)
	elseif entry.kind == "slider" then
		assert(
			typeof(value) == "number" and value == value and math.abs(value) < math.huge,
			"Expected a finite number for " .. entry.id
		)
	elseif entry.kind == "colour" then
		assert(
			typeof(value) == "table"
				and typeof(value.colour) == "Color3"
				and typeof(value.alpha) == "number"
				and value.alpha >= 0
				and value.alpha <= 1,
			"Expected a colour and alpha for " .. entry.id
		)
	else
		error("Setting has no value: " .. entry.id)
	end
end

const function changed(entry: settings_types.entry, value: settings_types.value): ()
	if entry.kind == "switch" or entry.kind == "checkbox" then
		if entry.on_changed then
			entry.on_changed(value :: boolean)
		end
	elseif entry.kind == "text" or entry.kind == "dropdown" then
		if entry.on_changed then
			entry.on_changed(value :: string)
		end
	elseif entry.kind == "slider" then
		if entry.on_changed then
			entry.on_changed(value :: number)
		end
	elseif entry.kind == "colour" then
		if entry.on_changed then
			entry.on_changed(value :: settings_types.colour_value)
		end
	end
end

return { default = default, validate = validate, changed = changed }
