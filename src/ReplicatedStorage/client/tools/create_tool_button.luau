-- the lifecycle of a mouse button, so that every handler's start and stop always come in pairs
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const tool_registry = require(ReplicatedStorage.shared.tools.registry)
const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

-- a handler without `stop` is instant, it's over as soon as it starts
export type handler = {
	start: (tool: tool_types.tool) -> (),
	-- `was_released` is false when the handler got interrupted, like by switching tools
	stop: ((was_released: boolean) -> ())?,
}

export type tool_button = {
	press: (tool: tool_types.tool?) -> (),
	release: () -> (),
	interrupt: () -> (),
	on_tool_changed: (tool: tool_types.tool?) -> (),
}

const function create_tool_button(handlers: { [tool_types.behaviour]: handler }): tool_button
	local button_held: boolean = false
	local tool_in_use: tool_types.tool? = nil

	-- handlers can yield, so they each get a thread to not hold up the caller
	const function start_handlers(tool: tool_types.tool, include_instant_handlers: boolean): ()
		tool_in_use = tool
		for behaviour: tool_types.behaviour, handler in handlers do
			if tool_registry.has_behaviour(tool, behaviour) and (include_instant_handlers or handler.stop ~= nil) then
				task.spawn(handler.start, tool)
			end
		end
	end

	const function stop_handlers(was_released: boolean): ()
		const tool = tool_in_use
		if tool == nil then
			return
		end
		tool_in_use = nil
		for behaviour: tool_types.behaviour, handler in handlers do
			const stop = handler.stop
			if stop ~= nil and tool_registry.has_behaviour(tool, behaviour) then
				task.spawn(stop, was_released)
			end
		end
	end

	const function press(tool: tool_types.tool?): ()
		-- the release can go missing, for example if it happens while the Roblox menu is open
		stop_handlers(false)
		button_held = true
		if tool ~= nil then
			start_handlers(tool, true)
		end
	end

	const function release(): ()
		button_held = false
		stop_handlers(true)
	end

	const function interrupt(): ()
		button_held = false
		stop_handlers(false)
	end

	const function on_tool_changed(tool: tool_types.tool?): ()
		-- switching to another stack of the same item carries on using it
		if tool_in_use ~= nil and (tool == nil or tool.id ~= tool_in_use.id) then
			stop_handlers(false)
		end
		-- buffer clicks support, though only for lasting handlers so that switching to a cube doesn't place one
		if button_held and tool_in_use == nil and tool ~= nil then
			start_handlers(tool, false)
		end
	end

	return {
		press = press,
		release = release,
		interrupt = interrupt,
		on_tool_changed = on_tool_changed,
	}
end

return create_tool_button
