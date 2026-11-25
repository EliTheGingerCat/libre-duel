const ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const menu_navigation = require(script.Parent.menu_navigation)

-- keeps menu_navigation's history in step with a menu that can also be opened and closed outside of it
-- the topbar starts a new history at topbar_destination, escape and the gamepad close button end it
const function use_menu_navigation_history(
	enabled: boolean,
	kind: menu_navigation.destination_kind,
	topbar_destination: menu_navigation.destination
): ()
	const topbar_destination_ref = React.useRef(topbar_destination)
	topbar_destination_ref.current = topbar_destination

	const function follow_enabled(): ()
		const showing = menu_navigation.is_showing(kind)
		if enabled and not showing then
			menu_navigation.reset_to(topbar_destination_ref.current)
		elseif not enabled and showing then
			menu_navigation.close_all()
		end
	end
	React.useEffect(follow_enabled, { enabled })
end

return use_menu_navigation_history
