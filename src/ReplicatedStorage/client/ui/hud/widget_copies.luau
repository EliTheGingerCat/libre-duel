export type factory = (on_remove: () -> ()) -> () -> ()

local copies: { [() -> ()]: boolean } = {}

const function add(create: factory): ()
	local disconnect: (() -> ())? = nil
	const function remove(): ()
		local cleanup = disconnect
		if cleanup then
			copies[cleanup] = nil
			disconnect = nil
			cleanup()
		end
	end
	local cleanup = create(remove)
	disconnect = cleanup
	copies[cleanup] = true
end

const function clear(): ()
	for disconnect in table.clone(copies) do
		copies[disconnect] = nil
		disconnect()
	end
end

return {
	add = add,
	clear = clear,
}
