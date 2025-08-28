local gui_manager = {}

local current_visible_gui = nil
local gui_setters = {}

function gui_manager.register_gui(gui_name: string, set_visible_func)
	gui_setters[gui_name] = set_visible_func
end

function gui_manager.show_gui(gui_name: string)
	-- hide the currently visible gui
	if current_visible_gui and current_visible_gui ~= gui_name then
		local current_setter = gui_setters[current_visible_gui]
		if current_setter then
			current_setter(false)
		end
	end
	
	--show the requested gui
	local setter = gui_setters[gui_name]
	if setter then
		setter(true)
		current_visible_gui = gui_name
	end
end

function gui_manager.hide_gui(gui_name: string)
	if current_visible_gui == gui_name then
		current_visible_gui = nil
	end
	local setter = gui_setters[gui_name]
	if setter then
		setter(false)
	end
end

function gui_manager.hide_all_guis()
	for gui_name, setter in gui_setters do
		setter(false)
	end
	current_visible_gui = nil
end

return gui_manager
